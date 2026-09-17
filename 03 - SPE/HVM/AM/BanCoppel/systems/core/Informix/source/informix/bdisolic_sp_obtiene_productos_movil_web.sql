CREATE PROCEDURE "informix".sp_obtiene_productos_movil_web(	pEmpresa 	CHAR(3),	-- Id. de empresa
														pSucursal 		CHAR(4),	-- Id de Sucursal
														pEjecutivo 		CHAR(8),    -- Ejecutivo
														pPuesto_local 	CHAR(2),  	-- Puesto local del ejecutivo
														pNumcte 		CHAR(20), 	-- Num. de Cliente
														pCoppel 		CHAR (1), 	-- Indica si el cte ya tiene un credito coppel efectuado en tienda.
																					-- (1:Tiene credito coppel, 0: No tiene credito coppel)
														pPrecalCoppel 	CHAR(1), 	-- Indica el resultado de la precalificacion del cte en coppel
																					-- (1: Mala eficiencia, 0: Buena eficiencia)
														pPrecalBco 		CHAR(1),    -- Indica el resultado de la precalificacion del cte en banco
																					-- (1:Mala eficiencia del cte en Banco, 0: Buena eficiencia del cte)
														pDigiDomicilio 	CHAR(1), 	-- Indica si el cte digitaliza un comprobante de domicilio.
														pIdentificacion CHAR(1),	-- Indica si el cte digitalizÃ?Â³ una identificacion oficial
														pOfertaProdCred CHAR(1))	--Indica si oferta o no productos de credito)
	RETURNING 	CHAR(5), -- Codigo de retorno
				CHAR(4), -- id de producto a ofrecer al cte
				CHAR(1), -- Tipo de solicitud correspondiente al producto a ofrecer
				CHAR(40),-- Descripcion del producto
				CHAR(2); -- Prioridad del producto al momento de mostrarse

	--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para contemplar el producto Prestamo Personal (6300).
	-- Peticion: RQM 10 108 Prestamo Personal.
	-- Fecha: 06-09-2009.
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para que devuelva un codigo de retorno cuando no existen
	--              productos a ofrecer para el cliente, y se agrega una condicion por
	--              producto coppel para que los clientes que no digitalizaron comprobante
	--              de domicilio solo puedan solicitar tarjeta de credito coppel cuando
	--              no tenga ya una en tramite o aperturada.
	-- Peticion: RQM 10 108 Prestamo Personal.
	-- Fecha: 09-10-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se eliminan validaciones para codigos de producto y en su lugar
	--               se realizan por tipo de solicitud, con el fin de dejar parametrizado
	--               el spl para nuevos productos asociados a tipos de solicitud
	--               existentes.
	-- Peticion: RQM 10 108 Prestamo Personal.
	-- Fecha: 12-11-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para optimizar la consulta a la tabla bdidigital:dg_expediente_img
	-- Peticion: Alta unica Paso 4
	-- Fecha: 28-01-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para validar que los productos a ofrecer al cliente
	--               sean los productos que la sucursal estÃ?Â¡ ofreciendo en ese momento.
	-- Peticion: RQM 10 108 Prestamo Personal.
	-- Fecha: 16-02-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para que los productos a ofertar se validen por el puesto del ejecutivo,
	-- 				 mismo que se recibe como parametro.
	-- Peticion: Alta unica paso 04
	-- Fecha: 22-06-2010
	-------------------------------------------------------------------------------
	-- FECHA: 2011/06/08
	-- MODIFICO: Jesus Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para no ofertar el producto de coppel cuando se tenga una solcititud de prestamo en tramite
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------
	-- FECHA: 2011/08/03
	-- MODIFICO: Jesus Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel y alguno de banco
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/09/20
	-- MODIFICO: Jesus Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel
	-- FECHA: 2011/09/27
	-- MODIFICO: Jesus Manuel Aguilar Heredia
	-- COMENTARIOS: Se agrega parametro de entrada para validar que se ahiga digitalizado una identificacion oficial
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/12/28
	-- MODIFICO: Jesus Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para  e ofertamiento de producto coppel a clientes de sexo femenino menores de edad
	-------------------------------------------------------------------------------------
	--Modifico: Jesus Manuel Aguilar Heredia 
	--Modificacion: Se modifica para no ofertar prestamo personal cuando ya se encuente una solicitud de rechazada del mismo
	--Peticion: RQM 09 306
	--Fecha: 12-11-2012
	-------------------------------------------------------------------------------------
	--Modifico: Jesus Manuel Aguilar Heredia
	--Modificacion: Se modifica para ofertar TDC a clientes que cuenten con un credito cancelado por peticion del cliente.
	--Peticion: RQI 27 004
	--Fecha: 11-12-2012
	-------------------------------------------------------------------------------------
	--Modifico: Guadalupe Payan
	--Modificacion: Se realiza homologacion con fuentes modificados por bancoppel: se agrega validacion para no permitir levantar una nueva solicitud de Prestamo cuando el cliente cuente	--              con una solicitud de Prestamo personal o de TDC Bancoppel Visa en estatus ?RT?. Tambien se agrega validacion para no permitir levantar una nueva solicitud de Prestamo
	--              cuando el cliente cuente con mas de 5 Prestamos Personales Activos.
	--				Se quita validacion para que oferte el prestamo personal para cuando se cuenta con una solicitud de coppel en tramite.
	--				Se elimina validacion del sexo, ya que todos seran contemplados como I.
	--				Se elimina validacion de que si se encuentra en tramite un prestamo personal no oferte credito Coppel.
	--Peticion: Contrato-MttoAltaUnica_04.doc
	--Fecha: 15-02-2013
	-------------------------------------------------------------------------------------
	--Modifico: Clemente Angulo
	--Modificacion: Se modifica para que se pueda ofertar una cuenta de nomina a un cliente que cuente con una cuenta de nomina cancelada.
	--Peticion: Incidencias productivas AU Paso 5.5.doc
	--Fecha: 22-04-2013
	-------------------------------------------------------------------------------------
	--Modifico: Gisela Rivera Llanes
	--Modificacion: Se modifica para evitar el error -284 ya que en la tabla bdisolic:ss_solicitudes el cliente contiene dos status_solicitud diferentes ('AP','RT'), el cual ocaciona
	--	que intente insertar los dos registros en la tabla "informix".ss_productos_ofrecer mostrando dicho error,
	--  tambien se modifico cuando la solicitud contenga el status_solicitud = 'AP' el sistema no debe permitir ofertar el producto de Tarjeta de Credito de Coppel.
	--Peticion: INC 24 006
	--Fecha: 24-02-2014
	-------------------------------------------------------------------------------------
	--Modifico: Carlos Aguirre Vega
	--Descripcion: Se agrega status EC - "Evaluacion Coppel" en la consulta de productos
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de Modificacion: 22-04-2013
	------------------------------------------------------------------------------------- 
	--Modifico: Carlos Aguirre Vega
	--Descripcion: Se modifica el nombre de sp_obtiene_productos_cjunk_02 a sp_obtiene_productos_cjunk
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de Modificacion: 07-05-2013
	-------------------------------------------------------------------------------------
	--Modifico: Eduardo Lopez
	--Modificacion: Se modifica para que reciba un parametro mas y no se oferten productos de credito en base a la comparacion de huellas
	--Peticion: RQI 63 033 Evaluacion de Comparacion de Huella OFI - version 1.1.doc
	--Fecha: 18-09-2013 
	------------------------------------------------------------------------------------- 
	--Modifico: Obed Vega
	--Modificacion: Se modifica para que se reconosca si el cliente coppel es prospecto y ofertar el credito coppel
	--Peticion: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf
	--Fecha: 01-09-2014
	-------------------------------------------------------------------------------------
	
	-- Declaracion de variables
	DEFINE cdescripcion     	VARCHAR(60);
	DEFINE cPrioridad       	CHAR (2);
	DEFINE cProdCop         	CHAR(4);
	DEFINE cprod_final      	CHAR(4);
	DEFINE cnomcte          	CHAR(104);
	DEFINE cedadcte         	SMALLINT;
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	VARCHAR(60);
	DEFINE CodRet           	CHAR(5);
	DEFINE cExiste          	CHAR(1);
	DEFINE cSucCajaUnica    	CHAR(1);
	DEFINE cDigiDom         	CHAR(1);
	DEFINE ProdActual       	CHAR(20);
	DEFINE cStatus_sol      	CHAR(2);
	DEFINE cSolcred_tramite 	CHAR(1);
	DEFINE sTotal_productos 	SMALLINT;
	DEFINE cNo_ofrecer      	CHAR(1);
	DEFINE cSolcred_tramite_cop CHAR(1);
	DEFINE cTpSolicitudAct  	CHAR(1);
	DEFINE cTpSolicitudOfr  	CHAR(1);
	DEFINE solApert  			CHAR(1);
	DEFINE cCodret          	CHAR(3);
	--
	DEFINE vdoccuantos      	INTEGER; 
	DEFINE cPuesto          	CHAR(3);
	--
	DEFINE dFechaAlta			DATE;
	DEFINE dFechaHoy			DATE;
	DEFINE dEdadAnioMes			CHAR(5);
	DEFINE dFechaNac			DATE;
	DEFINE iMeses				INTEGER;
	DEFINE dFechaValida			DATE;
	DEFINE cOfertar				CHAR(1);
	DEFINE vactiva_insert   	SMALLINT;
	DEFINE cSexo   				CHAR(1);
	DEFINE iIdentificacion  	INTEGER;
	DEFINE iPrestamosActivos  	INTEGER;
	DEFINE iBanderaInserta  	INTEGER;
	DEFINE solApertPP  			CHAR(1);
	DEFINE cStatus_cred  		CHAR(2);
	DEFINE cNum_credito  		CHAR(20);
	DEFINE cPerfilProm 			CHAR(3);
	DEFINE cPerfilActivo 		CHAR(1);
	DEFINE cStatus_cta 		    CHAR(1);
	DEFINE cOfertaNomina		CHAR(1);
	DEFINE cCliente             CHAR(20);
	DEFINE cCteProspecto		CHAR(1);
	-- BCPL Cliente Prospecto Tipo 3
	DEFINE cCteProsp			CHAR(20);
	DEFINE dFechaRespOSCalle	DATE;
	DEFINE cClave				CHAR(1);
	DEFINE iDiasTrans			INTEGER;
	DEFINE cProductoOfrecer		CHAR(4);
	DEFINE siDiasVigencia		SMALLINT;
	DEFINE inumpPrestamos       SMALLINT;

	-- Asignacion variables
	LET cdescripcion        	= "";
	LET cPrioridad          	= "";
	LET cProdCop            	= "";
	LET cprod_final         	= "";
	LET cnomcte             	= "";
	LET cedadcte            	= 0;
	LET sql_err             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET CodRet              	= '00000';
	LET cExiste             	= "";
	LET cSucCajaUnica       	= "";
	LET cDigiDom            	= '0';
	LET ProdActual          	= "";
	LET cStatus_sol         	= "";
	LET cSolcred_tramite    	= "";
	LET sTotal_productos    	= 0;
	LET cNo_ofrecer         	= "";
	LET cSolcred_tramite_cop   	= "";
	LET cTpSolicitudAct     	= "";
	LET cTpSolicitudOfr     	= "";
	LET solApert     			= "";
	LET cCodret             	= "";
	--
	LET vdoccuantos      		= 0; 
	LET cPuesto             	= "";
	--
	LET dFechaAlta				= '';
	LET dFechaHoy				= '';
	LET iMeses					= 0;
	LET dFechaValida			= '';
	LET cOfertar				= 'N';
	LET vactiva_insert 			= 1;
	LET cSexo 					= "I";
	LET dEdadAnioMes        	= "";
	LET dFechaNac 				= MDY(1,1,1900);
	LET iIdentificacion 		= 0;
	LET iPrestamosActivos 		= 0;
	LET iBanderaInserta 		= 1;
	LET solApertPP 				= '0';
	LET cStatus_cred 			= '';
	LET cNum_credito 			= '';
	LET cPerfilProm 			= '';
	LET cPerfilActivo 			= '';
	LET cStatus_cta 			= '';
	LET cOfertaNomina			= '0';
	LET cCliente                = '';
	LET cCteProspecto			= '';
	-- BCPL Cliente Prospecto Tipo 3
	LET cCteProsp				= '';
	LET dFechaRespOSCalle		= MDY(1,1,1900);
	LET cClave					= '';
	LET iDiasTrans				= 0;
	LET cProductoOfrecer		= '';
	LET siDiasVigencia			= 0;
	LET inumpPrestamos          = 0;

	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			DELETE FROM "informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
			LET CodRet = sql_err;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_obtiene_productos_cjunk.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT valor::INTEGER INTO iPrestamosActivos FROM "informix".ss_param WHERE secuencia = '365' AND empresa = '001';
		--obtiene la edad del cliente
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, pNumcte)
		INTO cCodRet, cnomcte, cedadcte;
		LET cCodRet = '00'||cCodRet;		

		IF NVL(cedadcte,"") = "" THEN
			LET CodRet = '00002';
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;

		SELECT puesto
		INTO cPuesto
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;

		IF NVL(cPuesto,"") = "" THEN
			LET CodRet = '00003';
		ELSE
			--FECHA: 06-04-2011
			--IF cPuesto <> '001' AND  cPuesto <>'003' THEN
			IF (SELECT COUNT(perfilprom) FROM  bdinteg:"informix".si_perfilproductos WHERE empresa = pEmpresa AND puesto = cPuesto AND activo = '1') = 0 THEN
				LET CodRet = '00012';
			END IF;
		END IF;

		IF CodRet = '00003'OR CodRet = '00012' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;

		IF pDigiDomicilio = '1' THEN
			SELECT FIRST 1 NVL(1,0)
			INTO vdoccuantos
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumcte
			AND cod_docto IN ("0012","0015","0016","0017","0018","0031","0032","0033");

			IF (NVL(vdoccuantos,0) <= 0) THEN
				LET cDigiDom = '1';
			END IF;
		END IF;
		IF pIdentificacion = '1' THEN --indica que no digitalizo --JMAH
			SELECT COUNT(*)
			INTO iIdentificacion
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente
			WHERE empresa = pEmpresa
			AND cliente = pNumcte
			AND cod_docto IN ('0001','0003','0013','0014','0022','0027','0028','0029','0030','0047','0061','0050','0092','0049','0048','0090','0938','0084');
			--Se agregan identificacion para menores de edad

			IF (NVL(iIdentificacion,0) <= 0) THEN
				LET CodRet = "00001";
				RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
			END IF;
		END IF;

		--dsb-17/04/2013
		--Verificar si no cuenta con una relacion coppel en la tabla si_relacion_ctebcplcpl
		IF pCoppel = '0' THEN
			SELECT NVL(cliente,''), NVL(cliente_prosp,'')
			INTO cCliente, cCteProspecto
			FROM bdinteg:"informix".si_relacion_ctebcplcpl
			WHERE empresa = pEmpresa AND numcte_banco = pNumcte;
			IF cCliente <> '' AND cCteProspecto <> '1' THEN
				LET pCoppel = '1';
			END IF;
		END IF;

		DELETE FROM "informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;

		--IF cDigiDom = '1' THEN
			FOREACH
				SELECT s.num_producto,s.tp_solicitud
				INTO cProdCop,cTpSolicitudOfr
				FROM "informix".ss_solic_producto s
				INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto AND p.sucursal = pSucursal)
				INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = pPuesto_local)
				WHERE s.empresa = pEmpresa
				--AND s.tp_solicitud = 'C'
				AND s.num_producto  IN (	SELECT num_producto
											FROM "informix".ss_solicitudes
											WHERE empresa= pEmpresa
											AND numcte = pNumcte
											AND status_solicitud IN("EA","EE","OA","OS","BC","ST","CE","LC","MC","EC", "PA"))--JMAH RQM 09279 / RQM 18 023

				INSERT INTO "informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cProdCop,cTpSolicitudOfr,'S');
			END FOREACH
		--END IF;
		

		-- Valida si la sucursal puede ofrecer el producto coppel
		SELECT cajaunica
		INTO cSucCajaUnica
		FROM bditarjcop:"informix".sucursalescajaunica
		WHERE empresa = pEmpresa
		AND cvesucursal = pSucursal;

		IF NVL(cSucCajaUnica,'') = "" THEN
			LET cSucCajaUnica = 'F';
		END IF;

		/*-- validacion de NO OFERTAMIENTO de una solicitud Coppel de que si se trata de (un cliente con una solicitud coppel ya existente) o (de que si la sucursal pueda ofertar producto coppel) o (de si ya se encuentra en tramite una solicitud coppel)
		IF pCoppel = '1' OR cSucCajaUnica = 'F' OR cSolcred_tramite_cop = '1' THEN
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('C');
		END IF;

		-- validacion de NO OFERTAMIENTO de una solicitud Banco para cuando ya se cuenta con una solicitud Banco en tramite.
		IF cSolcred_tramite = '1' THEN
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T','P');
		END IF;

		-- Validacion de NO OFERTAMIENTO para una solicitud de Banco para cuando (ya se cuenta con una solicitud Banco rechazada) o (de si ya se cuenta con un credito activo) o (de si ya se cuenta con una reestructura activa)
		IF solApert = '1' THEN
			--JMAH
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T');      --
		END IF;

		-- Validacion de NO OFERTAMIENTO para productos de credito que cuenten con (malos antecedentes en banco) o (malos antecedentes en coppel)
		IF pPrecalBco = '1'  OR pPrecalCoppel = '1' THEN
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr <> 'D';
		END IF;

		-- Validacion de NO OFERTAMIENTO para prestamo personal para cuando (ya se cuente con una solicitud rechaza de credito banco) o (ya se cuente con una solicitu de prestamo personal rechaza)
		IF solApertPP = '1' THEN
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr = '6300';
		END IF;

		-- validacion de NO OFERTAMIENTO para el producto de nomina si es que ya se encuentra con una cuenta 1300 - PRODUCTO NOMINA EMPLEADOS GC que NO este cancelada
		IF cOfertaNomina = '1' THEN
			UPDATE "informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte  AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'D' AND producto_ofr = '1300';
		END IF;
		
		--valida que no OFERTE PRODUCTOS de CREDITO para la comparacion de huella
		IF pOfertaProdCred = 1 THEN 
			UPDATE "informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;

		--valida que no OFERTE PRODUCTOS de CREDITO para clientes con situacion especial U-62
		IF (SELECT COUNT(causa) FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte AND situacion = "U" AND causa = 62) <> 0 THEN 
			UPDATE "informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;
		*/

		LET cTpSolicitudOfr = "";
		LET cprod_final     = "";

		FOREACH
			SELECT DISTINCT (tp.producto_ofr), tp.tp_solicitud_ofr, t.prioridad, 
				(CASE WHEN t.sistema = '01' THEN
					(SELECT UPPER(p.nombre) FROM bdicheq:"informix".sc_producto p
					WHERE empresa = pEmpresa AND p.producto = tp.producto_ofr)
				ELSE
					(CASE WHEN t.sistema = '03' THEN
						(SELECT UPPER(i.nombre) FROM bdinvers:"informix".sv_instrum i
							WHERE empresa = pEmpresa AND i.cod_instrum = tp.producto_ofr)
					ELSE
						(CASE WHEN t.sistema = '06' THEN
							(CASE WHEN tp.tp_solicitud_ofr = 'C' THEN 
								(SELECT UPPER(descripcion) FROM "informix".ss_tp_solicitud 
								WHERE empresa = pEmpresa AND tp_solicitud = 'C')
							ELSE
								(SELECT UPPER(nombre_prod) FROM bdicred:"informix".sd_definicion d
								WHERE empresa = pEmpresa AND d.num_producto = tp.producto_ofr)                          
							END)
						END)
					END)
				END)
			INTO cprod_final, cTpSolicitudOfr, cPrioridad, cdescripcion
			FROM "informix".ss_productos_ofrecer  tp
			INNER JOIN "informix".ss_tramite_productos_clasif t ON (tp.producto_ofr = t.prod_ofrecer)
			WHERE tp.cliente = pNumcte
			AND tp.sucursal = pSucursal
			AND tp.ejecutivo = pEjecutivo
			AND aplica = 'S'
			ORDER BY t.prioridad

			--Valida si el producto a ofrecer es de credito, para validar la fecha alta en caso que lo requiera.
			IF cprod_final = '6400' THEN
				IF (SELECT COUNT(*) FROM "informix".ss_producto_credcap WHERE num_producto = cprod_final AND meses_alta IS NOT NULL) > 0 THEN
					--se valida que debe tener una cuenta con la vigencia valida para ofrecer credinomina.
					--Obtiene meses necesarios de alta para ofrecer el producto
					SELECT fecha_hoy
					INTO dFechaHoy
					FROM bdicred:"informix".sd_fechas 
					WHERE empresa = pEmpresa;

					FOREACH
						SELECT tp2.fecha_alta, cp2.meses_alta
						INTO dFechaAlta, iMeses
						FROM "informix".ss_productos_ofrecer tp2
						INNER JOIN "informix".ss_producto_credcap cp2 ON (cp2.num_producto = cprod_final AND cp2.producto_cap = tp2.producto_act)		
						WHERE tp2.fecha_alta IS NOT NULL	
						CALL bdicred:"informix".monthadd(dFechaHoy,-iMeses) RETURNING dFechaValida;	
						IF NOT dFechaAlta <= dFechaValida THEN
							CONTINUE FOREACH;
						END IF;						
						LET cOfertar = "S";
						EXIT FOREACH;						
					END  FOREACH;

					IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
					END  IF;
				END IF;
			END IF;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET CodRet = '00001';
		END IF;

		DELETE FROM "informix".ss_productos_ofrecer  WHERE cliente = pNumcte AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo;

		IF CodRet = '00001' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
	END;
END PROCEDURE
