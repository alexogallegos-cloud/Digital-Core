CREATE PROCEDURE "informix".sp_premios_instantaneos(iCanal INT,iTpoper INT,iProducto INT, cNumcte CHAR(9),cSucursal CHAR(4),cFoliosuc CHAR(16),mImporte  MONEY(16,2),dFecha DATETIME YEAR TO SECOND, cBoletoMin CHAR(16), cBoletoMax CHAR(16))
RETURNING CHAR(6) AS cCod_Ret,CHAR(16) AS cFolio, CHAR(20) AS cFolio_cupon, CHAR(2) AS cTicket;

--Declaracion de variables

DEFINE iSql_Err			INTEGER;
DEFINE iIsam_Err		INTEGER;
DEFINE cCod_Ret			VARCHAR(6);
DEFINE cFolio 			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE iNumboleto		INTEGER;

DEFINE cCvesorteo		VARCHAR(6);
DEFINE cParam			CHAR(5);
DEFINE iPart1			INTEGER;
DEFINE iPart2			INTEGER;
DEFINE iPart3			INTEGER;
DEFINE iPart4			INTEGER;
DEFINE cStatus			CHAR(1);

--dsb-10/04/2013
DEFINE cNombreCliente	CHAR(50);
DEFINE cNombreSucursal	CHAR(50);
DEFINE cImporte			CHAR(19);
DEFINE cFecha			CHAR(10);
DEFINE cCuenta			CHAR(13);
DEFINE cCuentaClabe		CHAR(19);
DEFINE cHora			CHAR(5);
DEFINE cCajero			CHAR(8);
DEFINE cNumTarjeta		CHAR(17);
DEFINE cNombreProducto	CHAR(40);
DEFINE cTrans			CHAR(4);
DEFINE vNumcteParticipa	CHAR(20);

--Asignacion de variables

LET iSql_Err		=0;
LET iIsam_Err		=0;
LET cCod_Ret		='000000'; --todo correcto
LET cFolio 			='';
LET cFolio_cupon	='';
LET cTicket			='';
LET iNumboleto		=0;

LET cCvesorteo		='';
LET cParam			='';
LET iPart1			=0;
LET iPart2			=0;
LET iPart3			=0;
LET iPart4			=0;
LET cStatus			='0';

--dsb-10/04/2013
LET cNombreCliente	="";
LET cNombreSucursal	="";
LET cImporte		="";
LET cFecha			="";
LET cCuenta			="";
LET cCuentaClabe	="";
LET cHora			="";
LET cCajero			=SUBSTR(cFoliosuc,1,8);
LET cNumTarjeta		="";
LET cNombreProducto	="";
LET cTrans			="";
LET vNumcteParticipa = '';

BEGIN

	ON EXCEPTION SET iSql_Err, iIsam_Err
		SET DEBUG FILE TO "/tmp/sp_premios_instantaneos.out";
		TRACE ON;
		LET cCod_Ret = iSql_Err;
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_premios_instantaneos.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Verificar si esta activado el sorteo instantaneo
	SELECT valor INTO cParam
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 117;
	
	IF cParam = '1' THEN
		--Verificar la clave del sorteo
		SELECT valor INTO cParam
		FROM bdinteg:"informix".si_param
		WHERE cod_param = 136; 
		
		--Verificar la fecha se encuentre dentro del rango del sorteo 04 Agosto al 02 de Septiembre y que sea el sorteo indicado
		SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)}
		cve_sorteo
		INTO cCvesorteo
		FROM bdinteg:"informix".si_sorteo
		WHERE  CAST(dFecha AS DATE)  BETWEEN f_ini AND f_fin
		AND cve_sorteo = cParam;
		
		IF cCvesorteo = '' OR cCvesorteo IS NULL THEN
			--'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
		ELSE
			--Verificar que la persona no es persona fisica y se encuentra dentro del catalogo de personas morales
			IF EXISTS (SELECT {+INDEX (bdinteg:"informix".si_cltenoparticipa idx_si_cltenoparticipa)}numcte, tpo_persona
				FROM bdinteg:"informix".si_cltenoparticipa
				WHERE numcte = cNumcte) THEN
				--'LA PERSONA ES MORAL NO PARTICIPA'
			ELSE
				--Verificar que cumpla con el perfil establecido
				SELECT {+INDEX (bdinteg:"informix".si_participa idx_si_participa)}
				SUM(CASE WHEN tipo_participa = '1' AND id_elemento = iProducto THEN 1 ELSE 0 END) prod, --tipo de producto
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = iTpoper THEN 1 ELSE 0 END) trans, --tipo de operacion 
				SUM(CASE WHEN tipo_participa = '3' AND id_elemento = iCanal THEN 1 ELSE 0 END) canal, --tipo de canal
				SUM(CASE WHEN tipo_participa = '4' AND id_elemento = 1 THEN 1 ELSE 0 END) tpo_per, --tipo de persona
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = iTpoper AND mImporte  >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
				INTO iPart1,iPart2,iPart3,iPart4,iNumboleto
				FROM bdinteg:"informix".si_participa
				WHERE cve_sorteo = cCvesorteo;
				
				--Si se cumple con el perfil comprobar que no sea empleado
				IF iPart1 = 1 AND iPart2 = 1 AND iPart3 = 1 AND iPart4 = 1 AND iNumboleto = 1 THEN
					----- SE AGREGA PARA CONSULTAR EN TABLA DE CLIENTES Y EMPLEADOS.
					SELECT {+INDEX (bdinteg:"informix".si_empleado_cliente_coppel idx_cte_emp2)}numcte
					INTO vNumcteParticipa
					FROM bdinteg:"informix".si_empleado_cliente_coppel
					WHERE numcte = cNumcte
					AND status = '1';
					
					IF vNumcteParticipa <> '' OR vNumcteParticipa IS NOT NULL THEN
						--'CLIENTE NO PARTICIPA';
					ELSE
						IF EXISTS(SELECT producto FROM bdicheq:"informix".sc_maechq 
						WHERE num_cte = cNumcte AND producto = '1300' AND empresa = '001') THEN
							--'ES EMPLEADO';
						ELSE
							IF iCanal <> 4 THEN
								--Obtener el/los boleto(s)
								FOREACH 
									SELECT {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} folio, folio_cupon, ticket, estatus 
									INTO cFolio, cFolio_cupon, cTicket, cStatus
									FROM bdinteg:"informix".si_premios_instantaneos
									WHERE folio BETWEEN cBoletoMin AND cBoletoMax AND estatus = 1
									
									RETURN cCod_Ret, cFolio,cFolio_cupon, cTicket WITH RESUME;
								END FOREACH;
							END IF
							
							IF cStatus = 1 THEN
								UPDATE {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} bdinteg:"informix".si_premios_instantaneos 
								SET estatus = '2', sucursal = cSucursal,numcte = cNumcte, foliosuc = cFoliosuc, 
								tipo_operacion = iTpoper, importe = mImporte , f_asignado = dFecha WHERE folio BETWEEN cBoletoMin AND cBoletoMax;
								
								--dsb-10/04/2013
								--Obtener los datos necesarios para la inserccion en la tabla de rezagados
								SELECT  SUBSTR(TRIM(nombre1) ||' '|| TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno),1,50)
								INTO cNombreCliente 
								FROM bdinteg:"informix".si_cliente WHERE numcte = cNumcte;
								
								SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal)} SUBSTR(TRIM(nombre),1,50) INTO cNombreSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;
								
								LET cImporte = TRIM(CAST(mImporte AS CHAR(19)));
								LET cFecha = TO_CHAR(dFecha ,'%d/%m/%Y');
								
								SELECT {+INDEX (bdicheq:"informix".sc_producto idxscproductopba)} nombre INTO cNombreProducto FROM bdicheq:"informix".sc_producto WHERE producto = iProducto;
								IF NVL(cNombreProducto,'') <> '' THEN
									--Producto de captacion
									SELECT FIRST 1 SUBSTR(fech_hor,1,5),cuenta,num_tarjeta,transacc_suc
									INTO cHora,cCuenta,cNumTarjeta,cTrans
									FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFoliosuc AND NVL(transacc_suc,'') <> '' AND monto_tot = mImporte;
									
									--cuenta clabe
									SELECT cuenta_clabe
									INTO cCuentaClabe
									FROM bdicheq:"informix".sc_maechq WHERE cuenta = cCuenta;
								ELSE
									--Producto de credito
									SELECT nombre_prod INTO cNombreProducto FROM bdicred:"informix".sd_definicion WHERE num_producto = iProducto;
									IF NVL(cNombreProducto,'') <> '' THEN
										SELECT SUBSTR(hora_mov,1,5),num_credito,nro_tarjeta,transacc_suc
										INTO cHora,cCuenta,cNumTarjeta,cTrans
										FROM bdicred:"informix".sd_movdia
										WHERE folio_suc = cFoliosuc
										AND codigo_fun IN ('033','336')
										AND codigo_ref = '1';
										
										IF NVL(cCuenta, '') = '' THEN
											SELECT LIMIT 1 SUBSTR(hora_mov,1,5),num_credito,nro_tarjeta,transacc_suc
											INTO cHora,cCuenta,cNumTarjeta,cTrans
											FROM bdicred:"informix".sd_movdiacrd
											WHERE folio_suc = cFoliosuc		 
											AND codigo_ref = '1';
										END IF;										
									ELSE
										--'NO ES UN PRODUCTO REGISTRADO';
									END IF;
								END IF;
								IF NVL(cCuenta,'') <> '' THEN
									FOREACH 
										SELECT {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} folio, folio_cupon
										INTO cFolio,cFolio_cupon
										FROM bdinteg:"informix".si_premios_instantaneos
										WHERE folio BETWEEN cBoletoMin AND cBoletoMax
										
										INSERT INTO bdinteg:"informix".si_premios_rezagados (folio,ticket,estatus,sucursal,foliosuc,tipo_operacion,importe,
										f_asignado,folio_cupon,cuenta,num_cte,cuenta_clabe,nombre_cliente,nombre_sucursal,hora,cajero,num_tarjeta,
										nombre_producto ,boleto_ini,boleto_fin,trans) 
										VALUES(cFolio,cTicket,2,cSucursal,cFoliosuc,iTpoper,cImporte,cFecha,cFolio_cupon,cCuenta,
										cNumcte,cCuentaClabe,cNombreCliente,cNombreSucursal,cHora,cCajero,cNumTarjeta,cNombreProducto,cBoletoMin,
										cBoletoMax,cTrans);
									END FOREACH;
								ELSE
									--'NO SE ENCONTRO LA CUENTA';
								END IF;
							END IF
						END IF;
					END IF;
				ELSE 
					--'NO CUMPLE CON PARAMETROS';
				END IF;
			END IF;
		END IF;
	ELSE
		--'NO ACTIVADO EL SORTEO INSTANTANEO';
	END IF;
	IF cFolio = '' THEN
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Victor Hugo Nuñez',
'FECHA: 03/10/2012',
'BD: bdinteg',
'Objetivo: Sorteo Instantaneo Navidad Millonaria',
'AUTOR: Victor Hugo Nuñez',
'FECHA: 10/04/2013',
'BD: bdinteg',
'Objetivo: Sorteo Instantaneo Renueva tu Hogar 2013',
'Autor: 94565457',
'Fecha: 03/10/2013',
'Modificación: Se adecua sp agregando condicion para verificar cuando el cliente es un empleado(Que se encuentre en la tabla:si_empleado_cliente_coppel) ',
'              si se cumple dicha condicion no se le asigna boleto para el sorteo',
'Sustento:    ',
'Solicita: Israel Flores González',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_premios_instantaneos_web(iCanal INT,iTpoper INT,iProducto INT, cNumcte CHAR(9),cSucursal CHAR(4),cFoliosuc CHAR(16),mImporte  MONEY(16,2),dFecha DATETIME YEAR TO SECOND, cBoletoMin CHAR(16), cBoletoMax CHAR(16))
RETURNING CHAR(6) AS cCod_Ret,CHAR(16) AS cFolio, CHAR(20) AS cFolio_cupon, CHAR(2) AS cTicket;

--Declaracion de variables

DEFINE iSql_Err			INTEGER;
DEFINE iIsam_Err		INTEGER;
DEFINE cCod_Ret			VARCHAR(5);
DEFINE cFolio 			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE iNumboleto		INTEGER;

DEFINE cCvesorteo		VARCHAR(6);
DEFINE cParam			CHAR(5);
DEFINE iPart1			INTEGER;
DEFINE iPart2			INTEGER;
DEFINE iPart3			INTEGER;
DEFINE iPart4			INTEGER;
DEFINE cStatus			CHAR(1);

--dsb-10/04/2013
DEFINE cNombreCliente	CHAR(50);
DEFINE cNombreSucursal	CHAR(50);
DEFINE cImporte			CHAR(19);
DEFINE cFecha			CHAR(10);
DEFINE cCuenta			CHAR(13);
DEFINE cCuentaClabe		CHAR(19);
DEFINE cHora			CHAR(5);
DEFINE cCajero			CHAR(8);
DEFINE cNumTarjeta		CHAR(17);
DEFINE cNombreProducto	CHAR(40);
DEFINE cTrans			CHAR(4);
DEFINE vNumcteParticipa	CHAR(20);

--Asignacion de variables

LET iSql_Err		=0;
LET iIsam_Err		=0;
LET cCod_Ret		='00000'; --todo correcto
LET cFolio 			='';
LET cFolio_cupon	='';
LET cTicket			='';
LET iNumboleto		=0;

LET cCvesorteo		='';
LET cParam			='';
LET iPart1			=0;
LET iPart2			=0;
LET iPart3			=0;
LET iPart4			=0;
LET cStatus			='0';

--dsb-10/04/2013
LET cNombreCliente	="";
LET cNombreSucursal	="";
LET cImporte		="";
LET cFecha			="";
LET cCuenta			="";
LET cCuentaClabe	="";
LET cHora			="";
LET cCajero			=SUBSTR(cFoliosuc,1,8);
LET cNumTarjeta		="";
LET cNombreProducto	="";
LET cTrans			="";
LET vNumcteParticipa = '';

BEGIN

	ON EXCEPTION SET iSql_Err, iIsam_Err
		SET DEBUG FILE TO "/tmp/sp_premios_instantaneos.out";
		TRACE ON;
		LET cCod_Ret = iSql_Err;
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_premios_instantaneos.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Verificar si esta activado el sorteo instantaneo
	SELECT valor INTO cParam
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 117;
	
	IF cParam = '1' THEN
		--Verificar la clave del sorteo
		SELECT valor INTO cParam
		FROM bdinteg:"informix".si_param
		WHERE cod_param = 136; 
		
		--Verificar la fecha se encuentre dentro del rango del sorteo 04 Agosto al 02 de Septiembre y que sea el sorteo indicado
		SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)}
		cve_sorteo
		INTO cCvesorteo
		FROM bdinteg:"informix".si_sorteo
		WHERE  CAST(dFecha AS DATE)  BETWEEN f_ini AND f_fin
		AND cve_sorteo = cParam;
		
		IF cCvesorteo = '' OR cCvesorteo IS NULL THEN
			--'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
		ELSE
			--Verificar que la persona no es persona fisica y se encuentra dentro del catalogo de personas morales
			IF(SELECT count(numcte)
				FROM bdinteg:"informix".si_cltenoparticipa
				WHERE numcte = cNumcte) > 0 THEN
				--'LA PERSONA ES MORAL NO PARTICIPA'
			ELSE
				--Verificar que cumpla con el perfil establecido
				SELECT {+INDEX (bdinteg:"informix".si_participa idx_si_participa)}
				SUM(CASE WHEN tipo_participa = '1' AND id_elemento = iProducto THEN 1 ELSE 0 END) prod, --tipo de producto
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = iTpoper THEN 1 ELSE 0 END) trans, --tipo de operacion 
				SUM(CASE WHEN tipo_participa = '3' AND id_elemento = iCanal THEN 1 ELSE 0 END) canal, --tipo de canal
				SUM(CASE WHEN tipo_participa = '4' AND id_elemento = 1 THEN 1 ELSE 0 END) tpo_per, --tipo de persona
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = iTpoper AND mImporte  >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
				INTO iPart1,iPart2,iPart3,iPart4,iNumboleto
				FROM bdinteg:"informix".si_participa
				WHERE cve_sorteo = cCvesorteo;
				
				--Si se cumple con el perfil comprobar que no sea empleado
				IF iPart1 = 1 AND iPart2 = 1 AND iPart3 = 1 AND iPart4 = 1 AND iNumboleto = 1 THEN
					----- SE AGREGA PARA CONSULTAR EN TABLA DE CLIENTES Y EMPLEADOS.
					SELECT {+INDEX (bdinteg:"informix".si_empleado_cliente_coppel idx_cte_emp2)}numcte
					INTO vNumcteParticipa
					FROM bdinteg:"informix".si_empleado_cliente_coppel
					WHERE numcte = cNumcte
					AND status = '1';
					
					IF vNumcteParticipa <> '' OR vNumcteParticipa IS NOT NULL THEN
						--'CLIENTE NO PARTICIPA';
					ELSE
						IF(SELECT count(producto) FROM bdicheq:"informix".sc_maechq 
						WHERE num_cte = cNumcte AND producto = '1300' AND empresa = '001') > 0 THEN
							--'ES EMPLEADO';
						ELSE
							IF iCanal <> 4 THEN
								--Obtener el/los boleto(s)
								FOREACH 
									SELECT {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} folio, folio_cupon, ticket, estatus 
									INTO cFolio, cFolio_cupon, cTicket, cStatus
									FROM bdinteg:"informix".si_premios_instantaneos
									WHERE folio BETWEEN cBoletoMin AND cBoletoMax AND estatus = 1
									
									RETURN cCod_Ret, cFolio,cFolio_cupon, cTicket WITH RESUME;
								END FOREACH;
							END IF
							
							IF cStatus = 1 THEN
								UPDATE {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} bdinteg:"informix".si_premios_instantaneos 
								SET estatus = '2', sucursal = cSucursal,numcte = cNumcte, foliosuc = cFoliosuc, 
								tipo_operacion = iTpoper, importe = mImporte , f_asignado = dFecha WHERE folio BETWEEN cBoletoMin AND cBoletoMax;
								
								--dsb-10/04/2013
								--Obtener los datos necesarios para la inserccion en la tabla de rezagados
								SELECT  SUBSTR(TRIM(nombre1) ||' '|| TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno),1,50)
								INTO cNombreCliente 
								FROM bdinteg:"informix".si_cliente WHERE numcte = cNumcte;
								
								SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal)} SUBSTR(TRIM(nombre),1,50) INTO cNombreSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;
								
								LET cImporte = TRIM(CAST(mImporte AS CHAR(19)));
								LET cFecha = TO_CHAR(dFecha ,'%d/%m/%Y');
								
								SELECT {+INDEX (bdicheq:"informix".sc_producto idxscproductopba)} nombre INTO cNombreProducto FROM bdicheq:"informix".sc_producto WHERE producto = iProducto;
								IF NVL(cNombreProducto,'') <> '' THEN
									--Producto de captacion
									SELECT FIRST 1 SUBSTR(fech_hor,1,5),cuenta,num_tarjeta,transacc_suc
									INTO cHora,cCuenta,cNumTarjeta,cTrans
									FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFoliosuc AND NVL(transacc_suc,'') <> '' AND monto_tot = mImporte;
									
									--cuenta clabe
									SELECT cuenta_clabe
									INTO cCuentaClabe
									FROM bdicheq:"informix".sc_maechq WHERE cuenta = cCuenta;
								ELSE
									--Producto de credito
									SELECT nombre_prod INTO cNombreProducto FROM bdicred:"informix".sd_definicion WHERE num_producto = iProducto;
									IF NVL(cNombreProducto,'') <> '' THEN
										SELECT SUBSTR(hora_mov,1,5),num_credito,nro_tarjeta,transacc_suc
										INTO cHora,cCuenta,cNumTarjeta,cTrans
										FROM bdicred:"informix".sd_movdia
										WHERE folio_suc = cFoliosuc
										AND codigo_fun IN ('033','336')
										AND codigo_ref = '1';
										
										IF NVL(cCuenta, '') = '' THEN
											SELECT LIMIT 1 SUBSTR(hora_mov,1,5),num_credito,nro_tarjeta,transacc_suc
											INTO cHora,cCuenta,cNumTarjeta,cTrans
											FROM bdicred:"informix".sd_movdiacrd
											WHERE folio_suc = cFoliosuc		 
											AND codigo_ref = '1';
										END IF;										
									ELSE
										--'NO ES UN PRODUCTO REGISTRADO';
									END IF;
								END IF;
								IF NVL(cCuenta,'') <> '' THEN
									FOREACH 
										SELECT {+INDEX (bdinteg:"informix".si_premios_instantaneos idx_premios_instantaneos)} folio, folio_cupon
										INTO cFolio,cFolio_cupon
										FROM bdinteg:"informix".si_premios_instantaneos
										WHERE folio BETWEEN cBoletoMin AND cBoletoMax
										
										INSERT INTO bdinteg:"informix".si_premios_rezagados (folio,ticket,estatus,sucursal,foliosuc,tipo_operacion,importe,
										f_asignado,folio_cupon,cuenta,num_cte,cuenta_clabe,nombre_cliente,nombre_sucursal,hora,cajero,num_tarjeta,
										nombre_producto ,boleto_ini,boleto_fin,trans) 
										VALUES(cFolio,cTicket,2,cSucursal,cFoliosuc,iTpoper,cImporte,cFecha,cFolio_cupon,cCuenta,
										cNumcte,cCuentaClabe,cNombreCliente,cNombreSucursal,cHora,cCajero,cNumTarjeta,cNombreProducto,cBoletoMin,
										cBoletoMax,cTrans);
									END FOREACH;
								ELSE
									--'NO SE ENCONTRO LA CUENTA';
								END IF;
							END IF
						END IF;
					END IF;
				ELSE 
					--'NO CUMPLE CON PARAMETROS';
				END IF;
			END IF;
		END IF;
	ELSE
		--'NO ACTIVADO EL SORTEO INSTANTANEO';
	END IF;
	IF cFolio = '' THEN
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Victor Hugo Nuñez',
'FECHA: 03/10/2012',
'BD: bdinteg',
'Objetivo: Sorteo Instantaneo Navidad Millonaria',
'AUTOR: Victor Hugo Nuñez',
'FECHA: 10/04/2013',
'BD: bdinteg',
'Objetivo: Sorteo Instantaneo Renueva tu Hogar 2013',
'Autor: 94565457',
'Fecha: 03/10/2013',
'Modificación: Se adecua sp agregando condicion para verificar cuando el cliente es un empleado(Que se encuentre en la tabla:si_empleado_cliente_coppel) ',
'              si se cumple dicha condicion no se le asigna boleto para el sorteo',
'Sustento:    ',
'Solicita: Israel Flores González',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_compara_huellas_ctes(pEmpresa CHAR(3),pFecha DATE)
RETURNING CHAR(5), CHAR(100);

	--DEFINICION DE VARIABLES
	DEFINE vCodret			CHAR(5);
	DEFINE vSqlerr			INTEGER;
	DEFINE cNumCteMatch		CHAR(20);
	DEFINE cMatch			CHAR(4);
	DEFINE iContador		INTEGER;
	DEFINE iCtesRevAut		INTEGER;
	DEFINE cDescripcion		CHAR(100);
	DEFINE dFecha_actual	DATETIME YEAR TO SECOND;
	DEFINE sExiste			SMALLINT;
	DEFINE sVar				SMALLINT;
	DEFINE sCont			SMALLINT;
	DEFINE iPonSE_ini		INTEGER;
	DEFINE iPonSE_fin		INTEGER;
	DEFINE cCteMatch		INTEGER;
	DEFINE cSituacionMatch	CHAR(1);
	DEFINE iCausaMatch		SMALLINT;
	DEFINE cNombreOperador	CHAR(45);
	DEFINE cNumCteRefCoinc	CHAR(8);
	DEFINE cSecuenciacpl	CHAR(2);
	
	
	--Variables de tabla temporal
	DEFINE cNumCte			CHAR(20);
	DEFINE cSucursal		CHAR(4);
	DEFINE cPromotor		CHAR(8);
	DEFINE cTicket			CHAR(20);
	DEFINE cStatusCons		CHAR(1);
	DEFINE cNumMen			CHAR(3);
	DEFINE cEmpresa			CHAR(4);
	DEFINE iCliente			INTEGER;
	
	--VARIABLES DE PARENTESCO
	DEFINE cCodRetParen		CHAR(5);
	DEFINE cNomCte1 		CHAR(40);
	DEFINE cNomCte2 		CHAR(40);
	DEFINE cApPatCte 		CHAR(40);
	DEFINE cApMatCte 		CHAR(40);
	DEFINE cFecNacCte 		CHAR(10);
	DEFINE cSituacionCte 	CHAR(1);
	DEFINE sCausaCte 		SMALLINT;
	
	--VARIABLES PARA COMPARACION
	DEFINE cNomCte1_1 		CHAR(104);
	DEFINE cNomCte2_1  		CHAR(40);
	DEFINE cApPatCte_1  	CHAR(40);
	DEFINE cApMatCte_1  	CHAR(40);
	DEFINE cFecNacCte_1  	CHAR(10);
	DEFINE cSituacionCte_1 	CHAR(1);
	DEFINE cNomCte1_2 		CHAR(40);
	DEFINE cNomCte2_2  		CHAR(40);
	DEFINE cApPatCte_2  	CHAR(40);
	DEFINE cApMatCte_2  	CHAR(40);
	DEFINE cFecNacCte_2  	CHAR(10);
	DEFINE cSituacionCte_2 	CHAR(1);
	DEFINE sCausaCte_2 		SMALLINT;
	DEFINE cSit_ini			CHAR(1);
	DEFINE cSit_fin			CHAR(1);
	DEFINE sCausa_ini		SMALLINT;
	DEFINE sCausa_fin		SMALLINT;
	DEFINE sCausaCte_1 		SMALLINT;
	
	DEFINE cCodRet_par		CHAR(5);
	DEFINE dPorcentaje		DECIMAL(14,2);
	DEFINE cPorcDecAut		CHAR(100);
	DEFINE cOperador		CHAR(8);
	DEFINE cCodRetSP 		CHAR(5);
	DEFINE sPonderacion 	CHAR(6);
	DEFINE cCausa 			CHAR(6);
	DEFINE cSituacion 		CHAR(1);
	DEFINE sBitComp			SMALLINT;
	DEFINE iDictaminados	SMALLINT;
	
	DEFINE cTipoCte			CHAR(1);
	
	--INICIALIZACION DE VARIABLES
	LET vCodret			= '00002';
	LET vSqlerr			= 0;
	LET cNumcte			= '';
	LET cNumCteMatch	= '';
	LET cTicket			= '';
	LET iContador		= 0;
	LET cDescripcion	= 'Clientes sin situacion especial';
	LET cSucursal		= '';
	LET cEmpresa		= '';
	LET cSit_fin		= '';
	LET sExiste			= 0;
	LET sCausa_fin		= 0;
	LET sCont			= 0;
	LET cSituacionMatch	= '';
	LET iCausaMatch		= 0;
	LET cCteMatch		= 0;
	LET cNumCteRefCoinc = '';
	LET cSecuenciacpl	= '';
	
	LET cNombreOperador = '';	
	
	--VARIABLES DE PARENTESCO	
	LET cCodRetParen	= '00000';
	LET cNomCte1 		= '';
	LET cNomCte2 		= '';
	LET cApPatCte 		= '';
	LET cApMatCte 		= '';
	LET cFecNacCte 		= '';
	LET cSituacionCte 	= '';
	LET sCausaCte 		= 0;
	
	--VARIABLES PARA COMPARACION
	LET cNomCte1_1 		= '';
	LET cNomCte2_1	 	= '';
	LET cApPatCte_1 	= '';
	LET cApMatCte_1 	= '';
	LET cFecNacCte_1 	= '';
	
	LET cSit_ini		= '';
	LET sCausa_ini		= 0;
		
	LET cCodRet_par		= '';
	LET dPorcentaje		= 0.0;
	LET cPorcDecAut		= '';
	LET cOperador		= '';
	LET cCodRetSP		= '';
	LET sPonderacion 	= '';
	LET cCausa 			= '';
	LET cSituacion 		= '';
	LET sBitComp		= 0;
	LET iDictaminados 	= 0;
	
	LET cTipoCte		= '';
	
	--SET DEBUG FILE TO '/informix/jfponce/sp_compara_huellas_ctes2.out';
    --TRACE ON;	
	
    BEGIN    
		ON EXCEPTION SET vSqlerr
			IF vSqlerr <> 0 THEN
				LET vCodret = vSqlerr;
				IF sCont < 1000 and sCont > 0 THEN
					COMMIT WORK;
				END IF;				
				RETURN vCodret, 'Error en cliente: ' || TRIM(cNumcte) || ' con match: '||TRIM(cNumCteMatch);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		-- Se eliminan datos de tabla de paso
	    TRUNCATE TABLE "informix".tmp_si_comphuella;
		
		BEGIN WORK;		
			-- Ejecucion especial para limpiar U 61 de clientes prospectos
			IF pFecha == '01-01-2099' THEN
				FOREACH WITH HOLD
				
					SELECT a.numcte INTO cNumCte FROM bdinteg:"informix".si_cliente a INNER JOIN bdisitesp:"informix".se_ctessitespcte b ON a.numcte=b.numcte 
					AND a.tipo_cliente='2' WHERE b.situacion = 'U' AND b.causa = 61
									
					UPDATE bdisitesp:"informix".se_ctessitespcte SET situacion = 'U',causa=65,usrmodifica ='informix',fchmodifica=current,
				    motivo_desmarcaje= 'por solicitud del area sos'  WHERE numcte = cNumCte;
					
					LET sCont = sCont + 1;
					
					IF sCont = 1000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
								
				END FOREACH;
				COMMIT WORK;
				LET vCodret  = '00000';
				LET cDescripcion	= 'Clientes actualizados con exito';
				RETURN vCodret, cDescripcion;
				
			END IF;
		
			SELECT fecha_hoy::DATE 
			INTO dFecha_actual
			FROM "informix".si_fechas
			where empresa = pEmpresa;
			
			IF NVL(pEmpresa,'') = '' THEN		  
				LET vCodret  = '00001';
				LET cDescripcion = 'Parametro Empresa vacio';
			END IF;		

			-- CONSULTAMOS EL PORCENTAJE DE DECISION AUTOMATICA
			SELECT TRIM(Valor)
			INTO cPorcDecAut
			FROM "informix".si_param
			WHERE cod_param = '160';
			
				
			-- PARA SITUACIONES ESPECIALES NORMALES
			LET vCodret  		= '00000';
			LET iContador   	= 0;
			LET cNumcte			= '';
			LET cEmpresa		= '';
			LET cNumCteMatch	= '';
			LET cOperador		= '';
			LET cSucursal		= '';
			LET cTicket			= '';
			LET cCodRetParen	= '';
			LET iCtesRevAut		= 0;
			
			FOREACH WITH HOLD
			
				SELECT sit.numcte, sit.sucursal, sit.empleadoefectuo, lin.ticket,lin.status_consulta,res.num_mensaje,res.empresa,res.cliente,res.secuenciacpl
				INTO cNumCte,cSucursal,cPromotor,cTicket,cStatusCons,cNumMen,cEmpresa,iCliente,cSecuenciacpl
				FROM bdisitesp:"informix".se_ctessitespcte sit,
				bdinteg:"informix".si_huella_linea lin,
				bdinteg:"informix".si_huella_linea_resultado res
				WHERE sit.situacion = 'U' AND sit.causa = 61 AND sit.empresa = '001'
				AND sit.fchalta::DATE = pFecha
				AND lin.numcte = sit.numcte
				AND lin.status_consulta = '3'
				AND lin.ticket = res.ticket
								
				INSERT INTO "informix".tmp_si_comphuella(numcte,sucursal,promotor,ticket,status_consulta,num_mensaje,empresa,cliente,secuenciacpl) VALUES(TRIM(cNumCte),TRIM(cSucursal),TRIM(cPromotor),TRIM(cTicket),TRIM(cStatusCons),TRIM(cNumMen),TRIM(cEmpresa),iCliente,TRIM(cSecuenciacpl));
				
				LET sCont = sCont + 1;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
							
			END FOREACH;
			
			IF sCont < 1000 and sCont > 0 THEN
				COMMIT WORK;
				LET sCont = 0;
				BEGIN WORK;
			END IF;
						
			FOREACH WITH HOLD
				
				SELECT {+INDEX("informix".tmp_si_comphuella idx_comphuella)} numcte,sucursal,promotor,ticket
				INTO cNumCte,cSucursal,cOperador,cTicket
				FROM tmp_si_comphuella
				WHERE numcte = numcte
				GROUP BY numcte,sucursal,promotor,ticket
				ORDER BY numcte
				
				SELECT count(cliente) 
				INTO iContador
				FROM table(multiset(
									SELECT cliente,empresa,max(secuenciacpl)
									FROM "informix".tmp_si_comphuella
									WHERE numcte=cNumcte
									AND cliente not in  ('0',TRIM(cNumCte))
                                    and num_mensaje='602'
									group by cliente,empresa
								)	
				);
					
					

				
				LET sCont = sCont + 1;
				
				LET iCtesRevAut = 0;
				
				IF NVL(iContador,0) = 0 THEN -- Solo existe un registro con num_mensaje = 601

					--SIN COINCIDENCIAS(U-65), CLIENTE REVISADO
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,'','','')
					INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
					IF CAST(cCodRetSP AS INTEGER)  <> 0 THEN
						LET vCodret = cCodRetSP;
						LET cDescripcion = 'Error al actualizar situacion especial';
					END IF
				
				ELSE	-- Se procesa cliente con uno o dos match de huella 
					
					LET iContador = 0;
					
					FOREACH WITH HOLD
			
						SELECT cliente,empresa,max(secuenciacpl)
						INTO cCteMatch,cEmpresa,cSecuenciacpl
						FROM "informix".tmp_si_comphuella
						WHERE numcte=cNumcte
						AND procesado <> 'V'
						AND cliente not in  ('0',TRIM(cNumCte))
						and num_mensaje='602'
						group by cliente,empresa
									
									
						
						LET iContador = iContador + 1;
						
						IF cEmpresa = '5' THEN
							-- COINCIDENCIA CON CLIENTE BANCOPPEL.
							-- VERIFICAMOS SI TIENE PARENTESCO PADRE O HIJO.
							
							LET cNumCteMatch = LPAD(TRIM(cCteMatch::CHAR(20)),9,'0');
							
							IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_fuscliente WHERE numcte = cNumCteMatch) THEN
								
								EXECUTE PROCEDURE "informix".sp_obtieneparentesco( cNumcte, cNumCteMatch )
								INTO cCodRetParen, cNomCte1, cNomCte2, cApPatCte, cApMatCte, cFecNacCte, cSituacionCte, sCausaCte;
								
								-- EVALUAMOS EL RETORNO EN LA VARIABLE cCodRetParen
								IF cCodRetParen::INTEGER = 1 THEN
									
									LET iContador = iContador - 1; -- Se descarta match por parentesco		
									LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
									
								ELSE
									-- NO EXISTE PARENTESCO,  SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE BANCOPPEL.							
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1
									FROM "informix".si_cliente a, "informix".si_ctepf b
									WHERE a.numcte = cNumcte AND a.numcte = b.numcte;
									
									-- SE ASIGNA FORMATO DE FECHA COMO DD/MM/YYYY PARA COMPARACION DE NOMBRE Y FECHA
									LET cFecNacCte_1 =  LPAD( TRIM(DAY(cFecNacCte_1)::CHAR(2)),2,'0') || '/' || LPAD(TRIM(MONTH(cFecNacCte_1)::CHAR(2)),2,'0') || '/' || YEAR(cFecNacCte_1);
									
									-- SE REALIZA AL COMPARACION DE LOS NOMBRES DE LOS CLIENTES PARA OBTENER EL PORCENTAJE DE SIMILITUD.
									EXECUTE PROCEDURE "informix".sp_validanombrefn(cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1,cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,0)
									INTO cCodRet_par, dPorcentaje;
									
									-- COMPARANDO EL PROCENTAJE DE SIMILITUD DE AMBOS CLIENTES
									IF dPorcentaje >= cPorcDecAut::DECIMAL(6,0) THEN
									
										-- COINCIDENCIA BANCOPPEL Y CLIENTE SON LA MISMA PERSONA, SE MARCA COMO CLIENTE CON COINCIDENCIA EN HUELLA
										IF cNumcte <> cNumCteMatch THEN
											EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',3,'M','2',cSucursal,"informix",'','','')
											INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
												LET vCodret = '00000';
											ELSE
												LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
											END IF;
											
											-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
											INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
											VALUES(cNumcte,'U','3',cNumCteMatch, NVL(cSituacionCte,''), NVL(sCausaCte,0),dPorcentaje,cEmpresa, cSucursal,'informix','2',CURRENT,'1',CURRENT,CURRENT);
										
										ELSE
											---Se asigna la situacion especial U-65 debido a que se hizo match con mismo cliente
											EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
											INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
												LET vCodret = '00000';
											ELSE
												LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
											END IF;
											
											SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} NVL(situacion,'U'),NVL(causa,65) INTO cSituacion,cCausa 
											FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = cNumcte;
											
											-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
											INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
											VALUES(cNumcte,NVL(cSituacion,'U'), NVL(cCausa,65), cNumCteMatch, NVL(cSituacionCte,''), NVL(sCausaCte,0),dPorcentaje,cEmpresa, cSucursal,'informix','2',CURRENT,'2',CURRENT,CURRENT);
											
										END IF;
										
										
										UPDATE "informix".si_huella_linea_resultado SET nombre= TRIM(TRIM(cNomCte1)||' '||TRIM(cNomCte2))||' '||TRIM(TRIM(cApPatCte)||' '||TRIM(cApMatCte)) , fecha_nac=cFecNacCte WHERE ticket=cTicket and num_mensaje='602' and empresa=cEmpresa and cliente = cNumCteMatch;
										
										LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
										
									END IF;
									
								END IF;
							ELSE 
							
								LET iContador = iContador - 1; -- Se descarta match con cliente fusionado
								LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
								
								UPDATE "informix".tmp_si_comphuella set fusionado='V'  WHERE numcte=cNumCte and empresa=cEmpresa and cliente=cCteMatch;
								--UPDATE "informix".tmp_si_comphuella set fusionado='V'  WHERE CURRENT OF curso;
							END IF;
							
						ELIF cEmpresa = '4' THEN
							
							-- SE OBTIENE EL NOMBRE, FECHA DE NACIMIENTO Y SITUACION ESPECIAL DEL CLIENTE COPPEL.							
							SELECT LIMIT 1 TRIM(nombre),TRIM(fecha_nac),TRIM(situacion),causa
							INTO cNomCte1_1,cFecNacCte_1,cSituacionCte_1,sCausaCte_1
							FROM "informix".si_huella_linea_resultado
							WHERE ticket = cTicket
							and empresa = cEmpresa
							and num_mensaje = '602'
							and cliente = cCteMatch;
							
							IF (NVL(cNomCte1_1,'') <> '') AND (NVL(cFecNacCte_1,'') <> '') THEN 
							
								-- SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE BANCOPPEL.							
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte
									FROM "informix".si_cliente a, "informix".si_ctepf b
									WHERE a.numcte = cNumcte AND a.numcte = b.numcte; 
									
									-- SE ASIGNA FORMATO DE FECHA COMO DD/MM/YYYY PARA COMPARACION DE NOMBRE Y FECHA
									LET cFecNacCte =  LPAD( TRIM(DAY(cFecNacCte)::CHAR(2)),2,'0') || '/' || LPAD(TRIM(MONTH(cFecNacCte)::CHAR(2)),2,'0') || '/' || YEAR(cFecNacCte);
									
								
								-- SE REALIZA AL COMPARACION DE LOS NOMBRES DE LOS CLIENTES PARA OBTENER EL PORCENTAJE DE SIMILITUD.
								EXECUTE PROCEDURE "informix".sp_validanombrefn(cNomCte1_1,"","","",cFecNacCte_1,cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,0)
								INTO cCodRet_par, dPorcentaje;
								
								-- COMPARANDO EL PROCENTAJE DE SIMILITUD DE AMBOS CLIENTES
								IF dPorcentaje >= cPorcDecAut::DECIMAL(6,0) THEN
									--Validos cliente referencia
									--Que nos retorne el numero de cliente con el que hizo coincidencia
									EXECUTE PROCEDURE bdinteg:"informix".sp_valida_relacion_huella(1,cNumCte,cCteMatch, "001",USER, 4, 'Huella en Linea')
									INTO cCodRet_par,cNumCteRefCoinc;					
									
									IF CAST(cCodRet_par AS INTEGER)  = 0 THEN
										--Guardamos en bitacora relaciones 
										EXECUTE PROCEDURE bdinteg:"informix".sp_bit_ctes_rel(cNumCte, cNumCteRefCoinc,NVL(cCteMatch,''),cSucursal,USER)
										INTO cCodRet_par;
										
										IF CAST(cCodRet_par AS INTEGER)  = 0 THEN
											    
												SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} first 1 situacion,causa INTO cSituacion,cCausa FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = cNumcte;
												
												-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
												INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
												VALUES(cNumcte,cSituacion,cCausa,cCteMatch, NVL(cSituacionCte_1,''), NVL(sCausaCte_1,0),dPorcentaje,cEmpresa, cSucursal,USER,'2',CURRENT,'1',CURRENT,CURRENT);
												
												LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
												
										END IF;
									END IF;		
									
								END IF;
							END IF;
						END IF;
						
					END FOREACH;
					
					IF (iContador = 0) OR (iCtesRevAut = iContador) THEN 
						
						--SIN COINCIDENCIAS(U-65), CLIENTE REVISADO
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,'','','')
						INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
						IF CAST(cCodRetSP AS INTEGER)  <> 0 THEN
							LET vCodret = cCodRetSP;
							LET cDescripcion = 'Error al actualizar situacion especial';
						END IF
						
					ELIF (iCtesRevAut) < iContador  THEN-- se verifica si ambos match se dictaminaron
						
						SELECT {+INDEX(bdinteg:"informix".si_cliente idx_si_cliente5)} tipo_cliente INTO cTipoCte FROM bdinteg:"informix".si_cliente WHERE empresa='001' and numcte=cNumCte;
					
						-- SOLO SE GENERAN ALERTAS A PREVENCION DE FRAUDES DE CLIENTES TITULARES
						IF cTipoCte <> '1' THEN
							--CUANDO EL CLIENTE ES PROSPECTO SE LE ACTUALIZA LA SITUACIÃN ESPECIAL POR DEFECTO A U65
							IF cTipoCte = '2' THEN
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
								INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
								UPDATE "informix".tmp_si_comphuella set procesado='P' WHERE numcte=cNumCte;
								CONTINUE FOREACH;
							ELSE
							--DE LO CONTRARIO CONTINUA CON EL PROCESO HABITUAL
								UPDATE "informix".tmp_si_comphuella set procesado='P' WHERE numcte=cNumCte;
								CONTINUE FOREACH;
							END IF;
						END IF;
						
						-- CLIENTE PENDIENTE DE DICTAMEN DEL DEPARTAMENTO DE FRAUDES.
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
						INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET vCodret = '00000';
						ELSE
							LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
						END IF;
						
						-- SE LEVANTA LA ALERTA PARA EL SISTEMA CENTRAL DE FRAUDES.
						IF EXISTS(SELECT {+AVOID("informix".si_bitacora_comparaciones)} numcte FROM "informix".si_bitacora_comparaciones WHERE numcte=cNumcte) THEN
							UPDATE "informix".si_bitacora_comparaciones SET origen='2',sucursal=cSucursal,num_huellas=iContador-iCtesRevAut,numemp=cOperador,status_alerta='1',fecha_insert=current WHERE numcte=cNumcte;
						ELSE
							INSERT INTO "informix".si_bitacora_comparaciones( numcte, origen, sucursal, num_huellas, numemp, status_alerta, fecha_insert)
							VALUES( cNumcte, '2', cSucursal, iContador-iCtesRevAut, cOperador, '1', CURRENT);
						END IF;		
						
					END IF
				END IF;
				
				UPDATE "informix".tmp_si_comphuella set procesado='V' WHERE numcte=cNumCte;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
			IF sCont < 1000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
		
			IF TRIM(vCodret) = '00000' THEN LET cDescripcion= 'Exito'; END IF
			RETURN vCodret, cDescripcion;	

	END;
END PROCEDURE;