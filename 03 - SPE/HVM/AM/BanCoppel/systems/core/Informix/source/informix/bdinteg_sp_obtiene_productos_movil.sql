CREATE PROCEDURE "informix".sp_obtiene_productos_movil(	pEmpresa 		CHAR(3),	-- CÃ?ÃÂ³d. de empresa
																pSucursal 		CHAR(4),	-- CÃ?ÃÂ³d de Sucursal
																pEjecutivo 		CHAR(8),    -- Ejecutivo
																pPuesto_local 	CHAR(2),  	-- Puesto local del ejecutivo
																pNumcte 		CHAR(20), 	-- NÃ?ÃÂºm. de Cliente
																pCoppel 		CHAR (1), 	-- Indica si el cte ya tiene un crÃ?ÃÂ©dito coppel efectuado en tienda.
																							-- (1:Tiene crÃ?ÃÂ©dito coppel, 0: No tiene crÃ?ÃÂ©dito coppel)
																pPrecalCoppel 	CHAR(1), 	--Indica el resultado de la precalificaciÃ?ÃÂ³n del cte en coppel
																							-- (1: Mala eficiencia, 0: Buena eficiencia)
																pPrecalBco 		CHAR(1),    -- Indica el resultado de la precalificaciÃ?ÃÂ³n del cte en banco
																							-- (1:Mala eficiencia del cte en Banco, 0: Buena eficiencia del cte)
																pDigiDomicilio 	CHAR(1), 	-- Indica si el cte digitalizÃ?ÃÂ³ un comprobante de domicilio.
																pIdentificacion CHAR(1),	-- Indica si el cte digitalizÃ?ÃÂ³ una identificacion oficial
																pOfertaProdCred CHAR(1))	--Indica si oferta o no productos de credito)
	RETURNING 	CHAR(6), -- CÃ?ÃÂ³digo de retorno
				CHAR(4), -- CÃ?ÃÂ³d de producto a ofrecer al cte
				CHAR(1), -- Tipo de solicitud correspondiente al producto a ofrecer
				CHAR(40),-- DescripciÃ?ÃÂ³n del producto
				CHAR(2); -- Prioridad del producto al momento de mostrarse

	--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se modifica para contemplar el producto PrÃ?ÃÂ©stamo Personal (6300).
	-- PeticiÃ?ÃÂ³n: RQM 10 108 PrÃ?ÃÂ©stamo Personal.
	-- Fecha: 06-09-2009.
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se modifica para que devuelva un cÃ?ÃÂ³digo de retorno cuando no existen
	--              productos a ofrecer para el cliente, y se agrega una condiciÃ?ÃÂ³n por
	--              producto coppel para que los clientes que no digitalizaron comprobante
	--              de domicilio solo puedan solicitar tarjeta de crÃ?ÃÂ©dito coppel cuando
	--              no tenga ya una en trÃ?ÃÂ¡mite o aperturada.
	-- PeticiÃ?ÃÂ³n: RQM 10 108 PrÃ?ÃÂ©stamo Personal.
	-- Fecha: 09-10-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se eliminan validaciones para cÃ?ÃÂ³digos de producto y en su lugar
	--               se realizan por tipo de solicitud, con el fin de dejar parametrizado
	--               el spl para nuevos productos asociados a tipos de solicitud
	--               existentes.
	-- PeticiÃ?ÃÂ³n: RQM 10 108 PrÃ?ÃÂ©stamo Personal.
	-- Fecha: 12-11-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se modifica para optimizar la consulta a la tabla bdidigital:dg_expediente_img
	-- PeticiÃ?ÃÂ³n: Alta Ã?Ã?nica Paso 4
	-- Fecha: 28-01-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se modifica para validar que los productos a ofrecer al cliente
	--               sean los productos que la sucursal estÃ?ÃÂ¡ ofreciendo en ese momento.
	-- PeticiÃ?ÃÂ³n: RQM 10 108 PrÃ?ÃÂ©stamo Personal.
	-- Fecha: 16-02-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ?ÃÂ³n: Se modifica para que los productos a ofertar se validen por el puesto del ejecutivo,
	-- 				 mismo que se recibe como parÃ?ÃÂ¡metro.
	-- PeticiÃ?ÃÂ³n: Alta Ã?Ã?nica paso 04
	-- Fecha: 22-06-2010
	-------------------------------------------------------------------------------
	-- FECHA: 2011/06/08
	-- MODIFICO: JesÃ?ÃÂºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para no ofertar el producto de coppel cuando se tenga una solcititud de prestamo en tramite
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------
	-- FECHA: 2011/08/03
	-- MODIFICO: JesÃ?ÃÂºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel y alguno de banco
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/09/20
	-- MODIFICO: JesÃ?ÃÂºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel
	-- FECHA: 2011/09/27
	-- MODIFICO: JesÃ?ÃÂºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se agrega parametro de entrada para validar que se ahiga digitalizado una identificacion oficial
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/12/28
	-- MODIFICO: JesÃ?ÃÂºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para  e ofertamiento de producto coppel a clientes de sexo femenino menores de edad
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: JesÃ?ÃÂºs Manuel Aguilar Heredia 
	--ModificaciÃ?ÃÂ³n: Se modifica para no ofertar prestamo personal cuando ya se encuente una solicitud de rechazada del mismo
	--PeticiÃ?ÃÂ³n: RQM 09 306
	--Fecha: 12-11-2012
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: JesÃ?ÃÂºs Manuel Aguilar Heredia
	--ModificaciÃ?ÃÂ³n: Se modifica para ofertar TDC a clientes que cuenten con un credito cancelado por peticion del cliente.
	--PeticiÃ?ÃÂ³n: RQI 27 004
	--Fecha: 11-12-2012
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: Guadalupe Payan
	--ModificaciÃ?ÃÂ³n: Se realiza homologaciÃ?ÃÂ³n con fuentes modificados por bancoppel: se agrega validacion para no permitir levantar una nueva solicitud de PrÃ?ÃÂ©stamo cuando el cliente cuente	--              con una solicitud de PrÃ?ÃÂ©stamo personal o de TDC Bancoppel Visa en estatus ?RT?. Tambien se agrega validacion para no permitir levantar una nueva solicitud de PrÃ?ÃÂ©stamo
	--              cuando el cliente cuente con mas de 5 PrÃ?ÃÂ©stamos Personales Activos.
	--				Se quita validacion para que oferte el prestamo personal para cuando se cuenta con una solicitud de coppel en tramite.
	--				Se elimina validacion del sexo, ya que todos seran contemplados como I.
	--				Se elimina validacion de que si se encuentra en tramite un prestamo personal no oferte credito Coppel.
	--PeticiÃ?ÃÂ³n: Contrato-MttoAltaUnica_04.doc
	--Fecha: 15-02-2013
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: Clemente Angulo
	--ModificaciÃ?ÃÂ³n: Se modifica para que se pueda ofertar una cuenta de nomina a un cliente que cuente con una cuenta de nomina cancelada.
	--PeticiÃ?ÃÂ³n: Incidencias productivas AU Paso 5.5.doc
	--Fecha: 22-04-2013
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: Gisela Rivera Llanes
	--ModificaciÃ?ÃÂ³n: Se modifica para evitar el error -284 ya que en la tabla bdisolic:ss_solicitudes el cliente contiene dos status_solicitud diferentes ('AP','RT'), el cual ocaciona
	--	que intente insertar los dos registros en la tabla "informix".ss_productos_ofrecer mostrando dicho error,
	--  tambien se modifico cuando la solicitud contenga el status_solicitud = 'AP' el sistema no debe permitir ofertar el producto de Tarjeta de Credito de Coppel.
	--PeticiÃ?ÃÂ³n: INC 24 006
	--Fecha: 24-02-2014
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: Carlos Aguirre Vega
	--DescripciÃ?ÃÂ³n: Se agrega status EC - "Evaluacion Coppel" en la consulta de productos
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de modificaciÃ?ÃÂ³n: 22-04-2013
	------------------------------------------------------------------------------------- 
	--ModificÃ?ÃÂ³: Carlos Aguirre Vega
	--DescripciÃ?ÃÂ³n: Se modifica el nombre de sp_obtiene_productos_cjunk_02 a sp_obtiene_productos_cjunk
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de modificaciÃ?ÃÂ³n: 07-05-2013
	-------------------------------------------------------------------------------------
	--ModificÃ?ÃÂ³: Eduardo Lopez
	--ModificaciÃ?ÃÂ³n: Se modifica para que reciba un parametro mas y no se oferten productos de credito en base a la comparacion de huellas
	--PeticiÃ?ÃÂ³n: RQI 63 033 EvaluaciÃ?ÃÂ³n de ComparaciÃ?ÃÂ³n de Huella OFI - version 1.1.doc
	--Fecha: 18-09-2013 
	------------------------------------------------------------------------------------- 
	--ModificÃ?ÃÂ³: Obed Vega
	--ModificaciÃ?ÃÂ³n: Se modifica para que se reconosca si el cliente coppel es prospecto y ofertar el credito coppel
	--PeticiÃ?ÃÂ³n: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf
	--Fecha: 01-09-2014
	-------------------------------------------------------------------------------------
	
	-- DeclaraciÃ?ÃÂ³n de variables
	DEFINE cdescripcion     	VARCHAR(60);
	DEFINE cPrioridad       	CHAR (2);
	DEFINE cProdCop         	CHAR(4);
	DEFINE cprod_final      	CHAR(4);
	DEFINE cnomcte          	CHAR(104);
	DEFINE cedadcte         	SMALLINT;
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	VARCHAR(60);
	DEFINE CodRet           	CHAR(6);
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

	-- AsignaciÃ?ÃÂ³n variables
	LET cdescripcion        	= "";
	LET cPrioridad          	= "";
	LET cProdCop            	= "";
	LET cprod_final         	= "";
	LET cnomcte             	= "";
	LET cedadcte            	= 0;
	LET sql_err             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET CodRet              	= '000000';
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
		SET LOCK MODE TO WAIT 5;

		SELECT valor::INTEGER INTO iPrestamosActivos FROM "informix".ss_param WHERE secuencia = '365' AND empresa = '001';
		--obtiene la edad del cliente
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, pNumcte)
		INTO cCodRet, cnomcte, cedadcte;

		IF NVL(cedadcte,"") = "" THEN
			LET CodRet = '000002';
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;

		SELECT puesto
		INTO cPuesto
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;

		IF NVL(cPuesto,"") = "" THEN
			LET CodRet = '000003';
		ELSE
			--FECHA: 06-04-2011
			--IF cPuesto <> '001' AND  cPuesto <>'003' THEN
			IF NOT EXISTS(SELECT perfilprom FROM  bdinteg:"informix".si_perfilproductos WHERE empresa = pEmpresa AND puesto = cPuesto AND activo = '1') THEN
				LET CodRet = '000012';
			END IF;
		END IF;

		IF CodRet = '000003'OR CodRet = '000012' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;

		IF pDigiDomicilio = '1' THEN
			SELECT FIRST 1 NVL(1,0)
			INTO vdoccuantos
			FROM bdidigital@coppelimg_crx:"informix".dg_expediente
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumcte
			AND cod_docto IN ("0012","0015","0016","0017","0018","0031","0032","0033");

			IF (NVL(vdoccuantos,0) <= 0) THEN
				LET cDigiDom = '1';
			END IF;
		END IF;
		IF pIdentificacion = '1' THEN --indica que no digitalizo --JMAH
			SELECT COUNT(*)
			INTO iIdentificacion
			FROM bdidigital@coppelimg_crx:"informix".dg_expediente
			--WHERE empresa = pEmpresa
			WHERE cliente = pNumcte
			AND cod_docto IN ('0001','0003','0013','0014','0022','0027','0028','0029','0030','0047','0061','0050','0092','0049','0048','0090','0938','0084');
			--Se agregan identificacion para menores de edad

			IF (NVL(iIdentificacion,0) <= 0) THEN
				LET CodRet = "000001";
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
		IF EXISTS (SELECT causa FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte AND situacion = "U" AND causa = 62)  THEN 
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
				IF EXISTS(SELECT 1 FROM "informix".ss_producto_credcap WHERE num_producto = cprod_final AND meses_alta IS NOT NULL) THEN
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
			LET CodRet = '000001';
		END IF;

		DELETE FROM "informix".ss_productos_ofrecer  WHERE cliente = pNumcte AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo;

		IF CodRet = '000001' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
	END;
END PROCEDURE
DOCUMENT
"AUTOR: Viridiana Osobampo",
"FECHA: 30-11-2008",
"DESCRIPCION: Obtiene los productos bancarios y coppel que el cliente tiene actualmente y calcula",
"aquellos para los que el cliente es candidato a obtener.",
"BD: bdisolic", 
"MODIFICO: Abigail Vasavilbazo CaÃ?ÃÂ±edo,JesÃ?ÃÂºs Manuel Aguilar Heredia",
"DESCRIPCION: Se modifica para agregar producto 6400 (validacion de fecha valida para ofrecer este producto y cualquiera que se encuentre en la tabla ss_producto_credcap",
"VERSION: 20110503.1040",
"MODIFICO: JosuÃ?ÃÂ© Remberto Zazueta Acosta",
"DESCRIPCION: Se modifica para  el ofertamiento de producto coppel a clientes hombres menores de edad, y cuando se tenga un producto de prestamo personal.",
"FECHA: 2012/07/13",
"VERSION: 20120713.1725",
"MODIFICO    :  MartÃ?ÃÂ­n Eduardo Miranda																							",
"ModificaciÃ?ÃÂ³n: Se agrega consulta a la tabla 'si_perfilproductos' de la BD 'bdinteg' para consultar el Perfil del Ejecutivo		",
"              ademÃ?ÃÂ¡s de si ese perfil esta 'Activo' o no.																		",
" Fecha: 28/01/2013",
"MODIFICO    :  Victor Hugo NuÃ?ÃÂ±ez																								",
"ModificaciÃ?ÃÂ³n: Se agrega consulta a si_relacion_ctebcplcpl en caso de mandar que no es cliente coppel para marcarlo si existe en",
"              tabla.																											",
" Fecha: 17/04/2013",
"VERSION: 20130417.1925",
"MODIFICO    :  Clemente Angulo Ballardo																						",
"ModificaciÃ?ÃÂ³n: Se modifica para que se pueda ofertar una cuenta de nomina a un cliente que cuente con una cuenta                ",
"              de nomina cancelada.																		                    ",
" Fecha: 22/04/2013",
"VERSION: 20130918.1325",
"MODIFICO    :  Eduardo Lopez																									",
"ModificaciÃ?ÃÂ³n: Se modifica para que reciba un parametro mas y no se oferten productos de credito en base a la comparacion de huellas",
" Fecha: 18/09/2013";

CREATE PROCEDURE "informix".sp_actulizatipocliente (psEmpresa CHAR(3), psNumCliente CHAR(20), piTipoEjecucion INTEGER)
RETURNING	 CHAR(5) AS Retorno

	DEFINE iSqlErr            INTEGER;
	DEFINE cCodRet            CHAR(5);
	DEFINE cCodIdentifi       CHAR(2);
	DEFINE cNumIdentifi       CHAR(30);
	DEFINE iIdentOficial      INTEGER;
	DEFINE iComDomicilio      INTEGER;
	DEFINE dFecha             DATE;
	DEFINE dFechaNacimiento   DATE;
	DEFINE cCodRetFecha       CHAR(5);
	DEFINE iEdad              INTEGER;
	DEFINE iBandera           INTEGER;
	
	----Varibles Mensaje Afore
	DEFINE cNumEmpleado		  CHAR(8);
	DEFINE cSucursal		  CHAR(4);		  
	DEFINE cCurp		 	  CHAR(18);
	DEFINE cApellPaterno	  CHAR(26);
	DEFINE cApellMaterno	  CHAR(26);
	DEFINE cNombre1	 		  CHAR(26);
	DEFINE cNombre2	  		  CHAR(26);
	DEFINE dFechaNac		  DATE;	
	DEFINE cEntidadNac		  CHAR(2);	
	DEFINE cSexo			  CHAR(1);
	DEFINE cAvisoCte		  CHAR(1);
	DEFINE cSucursalEjecut	 CHAR(4);
	
	
	
	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Felipe Urias
	-- FECHA: 14/08/2012
	-- DESCRIPCION: Realiza la validaciones necesarias para que un cliente sea considerado titulas y de 
	--              cumplir con estas realiza la actualizacion del tipo de cliente.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Felipe Urias
	-- FECHA:       02/01/2013
	-- DESCRIPCION: se agrega consultas de fecha de nacimiento del cliente y consulta de la fecha actual
	--              se agrega validacion de edad  para que los menores no validen identificacion.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Rodolfo Tortolero
	-- FECHA:       22/02/2013
	-- DESCRIPCION: se agrega la misma funcionalidad que se utiliza en el sp_valida_aviso_privacidad
	--              para validar si el cliente tiene el aviso de privacidad. 
	--              Se modifica para que consulte los documentos digitalizados en la tabla 
	--              bdidigital@coppelimg_tcp:dg_expediente_img.
	--              Se agrega validaciÃÂ³n para clientes menores de edad no sea abligatorio el campo 
	--              nÃÂ¹mero identificaciÃÂ³n.
	------------------------------------------------------------------------------------------------------

	LET iSqlErr          = 0;
	LET cCodRet          = '00001';
	LET cCodIdentifi     = '';
	LET cNumIdentifi     = '';
	LET iIdentOficial    = 0;
	LET iComDomicilio    = 0;
	LET dFecha           = '';
	LET dFechaNacimiento = '';
	LET cCodRetFecha     = '00000';
	LET iEdad            = 0;
	LET iBandera         = 0;
	
	LET cNumEmpleado  = '';
	LET cSucursal	  = '';
	LET cCurp		  = '';
	LET cApellPaterno = '';
	LET cApellMaterno = ''; 
	LET cNombre1	  = '';
	LET cNombre2	  = '';
	LET dFechaNac	  = DATE(1);
	LET cEntidadNac	  = '';
	LET cSexo		  = '';
	LET cAvisoCte	  = '';
	LET cSucursalEjecut = '';
	
	
	-- SET DEBUG FILE TO "/tmp/sp_actulizatipocliente.out";
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = CAST(iSqlErr AS CHAR(5));
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
        IF  EXISTS(SELECT 1 FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1 AND secuencia = (SELECT MAX(secuencia) FROM si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1))THEN

			SELECT codidentifi, numidentifi, fecha_nac
			INTO cCodIdentifi, cNumIdentifi, dFechaNacimiento
			FROM bdinteg:"informix".si_ctepf
			WHERE empresa = psEmpresa
			AND numcte = psNumCliente;

            SELECT fecha_hoy 
            INTO dFecha
            FROM bdinteg:"informix".si_fechas
			WHERE empresa = psEmpresa;
			
			EXECUTE PROCEDURE sp_ObtenerEdadPersona(dFecha, NVL(dFechaNacimiento, '1900/01/01') )
			INTO cCodRetFecha, iEdad;
			
		    IF TRIM(cCodRetFecha) = '000' THEN
			    IF iEdad >=18 THEN
				    IF TRIM (NVL(cCodIdentifi,'')) <> '' AND TRIM (NVL(cNumIdentifi, '')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    ELSE
			        IF TRIM (NVL(cCodIdentifi,'')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    END IF;
			END IF;
			
			IF iBandera = 1 THEN

				IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A' AND secuencia = (SELECT MAX(secuencia)	FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A')) THEN

					--IF  EXISTS(SELECT 1 FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente)THEN
					IF  EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente
						WHERE numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq  WHERE empresa = psEmpresa AND num_cte = psNumCliente)
						   OR numcte IN (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE empresa = psEmpresa AND num_cte = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdicred:"informix".sd_maecred WHERE empresa = psEmpresa AND numcte  = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdisolic:"informix".ss_solicitudes WHERE empresa = psEmpresa AND numcte  = psNumCliente)
						   OR numcte IN (SELECT numcte  FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1'))THEN
		
						IF piTipoEjecucion = 2 THEN
						
							/*IF EXISTS(SELECT 1 FROM bdidigital:"informix".dg_expediente_envio WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN
								LET iIdentOficial = 1;
							END IF;
							IF EXISTS(SELECT 1 FROM bdidigital:"informix".dg_expediente_envio WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN
								LET iComDomicilio = 1;
							END IF;*/
							
							/*IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN*/
							IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_crx:"informix".dg_expediente WHERE cliente = psNumCliente AND cod_docto IN('0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')) THEN
								LET iIdentOficial = 1;
							END IF;
							
							/*IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN*/
							IF EXISTS(SELECT 1 FROM bdidigital@coppelimg_crx:"informix".dg_expediente WHERE cliente = psNumCliente AND cod_docto IN('0012','0015','0016','0017','0018','0031','0032','0033')) THEN
								LET iComDomicilio = 1;
							END IF;
							
							IF iIdentOficial = 1 AND iComDomicilio = 1 THEN
								
								UPDATE bdinteg:"informix".si_cliente 
								SET tipo_cliente = '1' 
								WHERE empresa = psEmpresa
								AND numcte = psNumCliente;
								
								LET cCodRet = '00000';
							
							END IF;
							
						ELIF piTipoEjecucion = 1 THEN
						
							UPDATE bdinteg:"informix".si_cliente 
							SET tipo_cliente = '1' 
							WHERE empresa = psEmpresa
							AND numcte = psNumCliente;
							
							LET cCodRet = '00000';
							
						END IF;	
					END IF;
				END IF;
			END IF;
		END IF;
		
		IF cCodRet = '00000' THEN 
		
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1') THEN
				
				IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente) THEN
					
					--Obtenemos los datos del cliente 
					SELECT  FIRST 1 c.ejecutivo,c.sucursal,c.apell_paterno,c.apell_materno,c.nombre1,c.nombre2,
						   f.curp,f.fecha_nac,f.lugar_nac,f.sexo
					INTO cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,
						 cCurp,dFechaNac,cEntidadNac,cSexo
					FROM  bdinteg:"informix".si_cliente c,
						  bdinteg:"informix".si_ctepf f
					WHERE c.numcte =  psNumCliente
					AND c.empresa =  psEmpresa
					AND c.numcte = f.numcte;
					
					SELECT FIRST 1 sucursal INTO cSucursal 
					FROM bdinteg:"informix".si_ejecut WHERE empresa=psEmpresa AND ejecutivo=cNumEmpleado;
					
					-- Notifica a afore
					INSERT INTO "informix".si_ws_mensajeafore(numcte,ejecutivo,sucursal,apell_paterno,apell_materno,nombre1,nombre2,curp,fecha_nac,lugar_nac,sexo,fecha_insert) 
					VALUES(psNumCliente,cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cCurp,dFechaNac,cEntidadNac,cSexo,CURRENT);
				END IF;
			END IF;	
		END IF;
		
		RETURN cCodRet;
		
	END
END PROCEDURE;