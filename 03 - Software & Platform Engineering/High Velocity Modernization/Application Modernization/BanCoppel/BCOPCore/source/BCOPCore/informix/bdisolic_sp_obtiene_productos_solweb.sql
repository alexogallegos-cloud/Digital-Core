CREATE PROCEDURE "informix".sp_obtiene_productos_solweb(	pEmpresa 		CHAR(3),	-- Cod. de empresa
																pSucursal 		CHAR(4),	-- Cod de Sucursal
																pEjecutivo 		CHAR(8),    -- Ejecutivo
																pPuesto_local 	CHAR(2),  	-- Puesto local del ejecutivo
																pNumcte 		CHAR(20), 	-- Num. de Cliente
																pCoppel 		CHAR (1), 	-- Indica si el cte ya tiene un credito coppel efectuado en tienda.
																							-- (1:Tiene credito coppel, 0: No tiene credito coppel)
																pPrecalCoppel 	CHAR(1), 	--Indica el resultado de la precalificacion del cte en coppel
																							-- (1: Mala eficiencia, 0: Buena eficiencia)
																pPrecalBco 		CHAR(1),    -- Indica el resultado de la precalificacion del cte en banco
																							-- (1:Mala eficiencia del cte en Banco, 0: Buena eficiencia del cte)
																pDigiDomicilio 	CHAR(1), 	-- Indica si el cte digitalizo un comprobante de domicilio.
																pIdentificacion CHAR(1),	-- Indica si el cte digitalizo una identificacion oficial
																pOfertaProdCred CHAR(1))	--Indica si oferta o no productos de credito)
	RETURNING 	CHAR(6), -- Codigo de retorno
				CHAR(4), -- Cod de producto a ofrecer al cte
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
	-- Peticion: Alta Unica Paso 4
	-- Fecha: 28-01-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para validar que los productos a ofrecer al cliente
	--               sean los productos que la sucursal esta ofreciendo en ese momento.
	-- Peticion: RQM 10 108 Prestamo Personal.
	-- Fecha: 16-02-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- Modificacion: Se modifica para que los productos a ofertar se validen por el puesto del ejecutivo,
	-- 				 mismo que se recibe como parametro.
	-- Peticion: Alta Unica paso 04
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
	--Fecha de modificacion: 22-04-2013
	------------------------------------------------------------------------------------- 
	--Modifico: Carlos Aguirre Vega
	--Descripcion: Se modifica el nombre de sp_obtiene_productos_cjunk_02 a sp_obtiene_productos_cjunk
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de modificacion: 07-05-2013
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
	DEFINE cprod_final      	CHAR(4);
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	VARCHAR(60);
	DEFINE CodRet           	CHAR(6);
	DEFINE cTpSolicitudOfr  	CHAR(1);
	DEFINE icont				INTEGER;
	-- Asignacion variables
	LET cdescripcion        	= "";
	LET cPrioridad          	= "";
	LET cprod_final         	= "";
	LET sql_err             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET CodRet              	= '000000';
	LET cTpSolicitudOfr     	= "";
	LET icont					= 0;

	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			DELETE FROM "informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
			LET CodRet = sql_err;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END EXCEPTION;

		--SET DEBUG FILE TO "/ifxsif01/aldo/ofertamiento/sp_obtiene_productos_solweb.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		FOREACH
			EXECUTE PROCEDURE "informix".sp_obtiene_productos_cub
			(pEmpresa, pSucursal, pEjecutivo, pPuesto_local, pNumcte,pCoppel, 
			pPrecalCoppel, pPrecalBco, pDigiDomicilio , pIdentificacion, pOfertaProdCred, 0, 0) 
			INTO CodRet,cprod_final,cTpSolicitudOfr,cdescripcion,cPrioridad
		
			IF cprod_final IN ('6001','6500') THEN 
				LET icont = icont +1;
				RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'') WITH RESUME;	
			ELSE 
				CONTINUE FOREACH;
			END IF;
		
		END FOREACH;
		
		IF icont = 0 THEN 
			LET CodRet='000001';
			LET cprod_final ='';
			LET cTpSolicitudOfr ='';
			LET cdescripcion ='';
			LET cPrioridad ='';
			RETURN CodRet, cprod_final,cTpSolicitudOfr,cdescripcion,cPrioridad;
		END IF;
END;	
END PROCEDURE
