CREATE PROCEDURE "informix".sp_obtiene_productos_cjunk_club(	pEmpresa 		CHAR(3),	-- Cod. de empresa
																pSucursal 		CHAR(4),	-- Cod de Sucursal
																pEjecutivo 		CHAR(8),    -- Ejecutivo
																pPuesto_local 	CHAR(2),  	-- Puesto local del ejecutivo
																pNumcte 		CHAR(20), 	-- Num. de Cliente
																pCoppel 		CHAR (1), 	-- Indica si el cte ya tiene un crÃ©dito coppel efectuado en tienda.
																							-- (1:Tiene crÃ©dito coppel, 0: No tiene crÃ©dito coppel)
																pPrecalCoppel 	CHAR(1), 	--Indica el resultado de la precalificaciÃ³n del cte en coppel
																							-- (1: Mala eficiencia, 0: Buena eficiencia)
																pPrecalBco 		CHAR(1),    -- Indica el resultado de la precalificaciÃ³n del cte en banco
																							-- (1:Mala eficiencia del cte en Banco, 0: Buena eficiencia del cte)
																pDigiDomicilio 	CHAR(1), 	-- Indica si el cte digitalizÃ³ un comprobante de domicilio.
																pIdentificacion CHAR(1),	-- Indica si el cte digitalizÃ³ una identificacion oficial
																pOfertaProdCred CHAR(1))	--Indica si oferta o no productos de credito)
	RETURNING 	CHAR(6), -- CÃ³digo de retorno
				CHAR(4), -- CÃ³digo de producto a ofrecer al cte
				CHAR(1), -- Tipo de solicitud correspondiente al producto a ofrecer
				CHAR(40),-- DescripciÃ³n del producto
				CHAR(2); -- Prioridad del producto al momento de mostrarse

	--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se modifica para contemplar el producto PrÃ©stamo Personal (6300).
	-- PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal.
	-- Fecha: 06-09-2009.
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se modifica para que devuelva un codigo de retorno cuando no existen
	--              productos a ofrecer para el cliente, y se agrega una condiciÃ³n por
	--              producto coppel para que los clientes que no digitalizaron comprobante
	--              de domicilio solo puedan solicitar tarjeta de crÃ©dito coppel cuando
	--              no tenga ya una en trÃ¡mite o aperturada.
	-- PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal.
	-- Fecha: 09-10-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se eliminan validaciones para cÃ³digos de producto y en su lugar
	--               se realizan por tipo de solicitud, con el fin de dejar parametrizado
	--               el spl para nuevos productos asociados a tipos de solicitud
	--               existentes.
	-- PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal.
	-- Fecha: 12-11-2009.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se modifica para optimizar la consulta a la tabla bdidigital:dg_expediente_img
	-- PeticiÃ³n: Alta unica Paso 4
	-- Fecha: 28-01-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se modifica para validar que los productos a ofrecer al cliente
	--               sean los productos que la sucursal estÃ¡ ofreciendo en ese momento.
	-- PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal.
	-- Fecha: 16-02-2010.
	-------------------------------------------------------------------------------------
	-- Autor: Viridiana Osobampo.
	-- ModificaciÃ³n: Se modifica para que los productos a ofertar se validen por el puesto del ejecutivo,
	-- 				 mismo que se recibe como parÃ¡metro.
	-- PeticiÃ³n: Alta unica paso 04
	-- Fecha: 22-06-2010
	-------------------------------------------------------------------------------
	-- FECHA: 2011/06/08
	-- MODIFICO: JesÃºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para no ofertar el producto de coppel cuando se tenga una solcititud de prestamo en tramite
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------
	-- FECHA: 2011/08/03
	-- MODIFICO: JesÃºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel y alguno de banco
	--se realizan adecuaciones para cumplir con los estandares de codificacion.
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/09/20
	-- MODIFICO: JesÃºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para corregir el ofertamiento de productos cuando el cliente cuente con un producto coppel
	-- FECHA: 2011/09/27
	-- MODIFICO: JesÃºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se agrega parametro de entrada para validar que se ahiga digitalizado una identificacion oficial
	-------------------------------------------------------------------------------------
	-- FECHA: 2011/12/28
	-- MODIFICO: JesÃºs Manuel Aguilar Heredia
	-- COMENTARIOS: Se modifica para  e ofertamiento de producto coppel a clientes de sexo femenino menores de edad
	-------------------------------------------------------------------------------------
	--ModificÃ³: JesÃºs Manuel Aguilar Heredia 
	--ModificaciÃ³n: Se modifica para no ofertar prestamo personal cuando ya se encuente una solicitud de rechazada del mismo
	--PeticiÃ³n: RQM 09 306
	--Fecha: 12-11-2012
	-------------------------------------------------------------------------------------
	--ModificÃ³: JesÃºs Manuel Aguilar Heredia
	--ModificaciÃ³n: Se modifica para ofertar TDC a clientes que cuenten con un credito cancelado por peticion del cliente.
	--PeticiÃ³n: RQI 27 004
	--Fecha: 11-12-2012
	-------------------------------------------------------------------------------------
	--ModificÃ³: Guadalupe Payan
	--ModificaciÃ³n: Se realiza homologaciÃ³n con fuentes modificados por bancoppel: se agrega validacion para no permitir levantar una nueva solicitud de PrÃ©stamo cuando el cliente cuente	--              con una solicitud de PrÃ©stamo personal o de TDC Bancoppel Visa en estatus ?RT?. Tambien se agrega validacion para no permitir levantar una nueva solicitud de PrÃ©stamo
	--              cuando el cliente cuente con mas de 5 PrÃ©stamos Personales Activos.
	--				Se quita validacion para que oferte el prestamo personal para cuando se cuenta con una solicitud de coppel en tramite.
	--				Se elimina validacion del sexo, ya que todos seran contemplados como I.
	--				Se elimina validacion de que si se encuentra en tramite un prestamo personal no oferte credito Coppel.
	--PeticiÃ³n: Contrato-MttoAltaUnica_04.doc
	--Fecha: 15-02-2013
	-------------------------------------------------------------------------------------
	--ModificÃ³: Clemente Angulo
	--ModificaciÃ³n: Se modifica para que se pueda ofertar una cuenta de nomina a un cliente que cuente con una cuenta de nomina cancelada.
	--PeticiÃ³n: Incidencias productivas AU Paso 5.5.doc
	--Fecha: 22-04-2013
	-------------------------------------------------------------------------------------
	--ModificÃ³: Gisela Rivera Llanes
	--ModificaciÃ³n: Se modifica para evitar el error -284 ya que en la tabla bdisolic:ss_solicitudes el cliente contiene dos status_solicitud diferentes ('AP','RT'), el cual ocaciona
	--	que intente insertar los dos registros en la tabla "informix".ss_productos_ofrecer mostrando dicho error,
	--  tambien se modifico cuando la solicitud contenga el status_solicitud = 'AP' el sistema no debe permitir ofertar el producto de Tarjeta de Credito de Coppel.
	--PeticiÃ³n: INC 24 006
	--Fecha: 24-02-2014
	-------------------------------------------------------------------------------------
	--ModificÃ³: Carlos Aguirre Vega
	--DescripciÃ³n: Se agrega status EC - "Evaluacion Coppel" en la consulta de productos
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de ModificaciÃ³n: 22-04-2013
	------------------------------------------------------------------------------------- 
	--ModificÃ³: Carlos Aguirre Vega
	--DescripciÃ³n: Se modifica el nombre de sp_obtiene_productos_cjunk_02 a sp_obtiene_productos_cjunk
	--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
	--Fecha de ModificaciÃ³n: 07-05-2013
	-------------------------------------------------------------------------------------
	--ModificÃ³: Eduardo Lopez
	--ModificaciÃ³n: Se modifica para que reciba un parametro mas y no se oferten productos de credito en base a la comparacion de huellas
	--PeticiÃ³n: RQI 63 033 EvaluaciÃ³n de ComparaciÃ³n de Huella OFI - version 1.1.doc
	--Fecha: 18-09-2013 
	------------------------------------------------------------------------------------- 
	--ModificÃ³: Obed Vega
	--ModificaciÃ³n: Se modifica para que se reconosca si el cliente coppel es prospecto y ofertar el credito coppel
	--PeticiÃ³n: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf
	--Fecha: 01-09-2014
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 888 LÃ­mite de apertura de cuentas de captaciÃ³n
	--Folio: 381
	--Autor: 97893323 Judith Moreno
	--Fecha: 07/03/2018
	--ModificaciÃ³n: Se modifica para validar que si el solicitante sobrepasa el lÃ­mite de cuentas de captaciÃ³n, dado por el sp_limite_cuentas
	--				no se permita ofertar cuentas de captaciÃ³n, unicamente inversion creciente y pagarÃ©
	--Sustento: basado en el requerimiento 5_RQM 10 888 LÃ­mite de apertura
	--Solicita: Abraham Narvaez",
	--BD: bdisolic"
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
	DEFINE solApertRTCPS		CHAR(1);
	DEFINE cStatus_cred  		CHAR(2);
	DEFINE cNum_credito  		CHAR(20);
	DEFINE cPerfilProm 			CHAR(3);
	DEFINE cPerfilActivo 		CHAR(1);
	DEFINE cStatus_cta 		    CHAR(1);
	DEFINE cOfertaNomina		CHAR(1);
	DEFINE cCliente             CHAR(20);
	DEFINE cCteProspecto		CHAR(1);
	-- BCPL Cliente Prospecto Tipo 3
	DEFINE cTipoSol				CHAR(1);
	DEFINE cCteProsp			CHAR(20);
	DEFINE dFechaRespOSCalle	DATE;
	DEFINE cClave				CHAR(1);
	DEFINE cNumsolOs			CHAR(20);
	DEFINE iDiasTrans			INTEGER;
	DEFINE cProductoOfrecer		CHAR(4);
	DEFINE siDiasVigencia		SMALLINT;
	DEFINE inumpPrestamos       SMALLINT;
	DEFINE cStatusSolic       	CHAR(02);
	DEFINE dFechaInsert       	DATE;
	DEFINE iDiasRechazo       	INTEGER;
	DEFINE cVar1       			CHAR(6);
	DEFINE cVar2       			CHAR(20);
	DEFINE cnum_solicitud 		CHAR(20);
	
	
	DEFINE Codret2                   CHAR(6);
	DEFINE iNum_periodos            INTEGER;
	DEFINE dtFecha_cuota            DATE;
	DEFINE dSdo_inicial             MONEY(14,2);
	DEFINE dPago_mensual            MONEY(14,2);
	DEFINE dMto_Interes             MONEY(14,2);
	DEFINE dIva_interes             MONEY(14,2);
	DEFINE dCapital                 MONEY(14,2);
	DEFINE dSdo_final               MONEY(14,2);
	DEFINE sDias_periodo            SMALLINT;
	DEFINE v_diaspromedio           DECIMAL(14,2);
	DEFINE v_salariomin             DECIMAL(14,2);
	DEFINE dMto_min                 DECIMAL(18,2);
	DEFINE dMto_max                 DECIMAL(18,2);		
	DEFINE dtFecha_Aper		        DATE;
	DEFINE cNumMesesPagos           CHAR(3);
	DEFINE iPlazoMax                INTEGER;
	DEFINE cnum_solicitudAux        CHAR(20);
	DEFINE v_capacidad              MONEY(14,2);
	DEFINE v_limite_inferior        DECIMAL(14,2);
	DEFINE v_grupo                  char(01); 
	DEFINE cRFC					CHAR(13);
	DEFINE cCodigoRet 			CHAR(6);
	DEFINE cFechaUltimoPago 	CHAR(13); 
	DEFINE cPrestamoAutorizado 	CHAR(1); 
	DEFINE iMontoAutorizado 	INT8; 
	DEFINE iReprestamo 			INT8; 
	
	DEFINE cSitEsp          	    INTEGER;
--Validacion IFE/INE
    DEFINE B_ife            char(01);
    DEFINE B_valida_ife     char(01);
--Validacion IFE/INE

--Validacion limite cuentas de captaciÃ³n
	DEFINE cCodErr CHAR(3);
	DEFINE cNumCueCapt CHAR(2);
--Validacion limite cuentas de captaciÃ³n
	--- ValidaciÃ³n Prestamo Flexible
	DEFINE solApertPPFlex  			CHAR(1);
--jom-26/11/2018
--Verificar que exista como empleado o como cliente Coppel
	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
        DEFINE cEmpresaHuella           CHAR(3);
--jom-26/11/2018

	-- AsignaciÃ³n variables
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
	LET solApertRTCPS 			= '0';
	LET cStatus_cred 			= '';
	LET cNum_credito 			= '';
	LET cPerfilProm 			= '';
	LET cPerfilActivo 			= '';
	LET cStatus_cta 			= '';
	LET cOfertaNomina			= '0';
	LET cCliente                = '';
	LET cCteProspecto			= '';
	-- BCPL Cliente Prospecto Tipo 3
	LET cTipoSol				= '';
	LET cCteProsp				= '';
	LET dFechaRespOSCalle		= MDY(1,1,1900);
	LET cClave					= '';
	LET cNumsolOs				= '';
	LET iDiasTrans				= 0;
	LET cProductoOfrecer		= '';
	LET siDiasVigencia			= 0;
	LET inumpPrestamos          = 0;
	LET cStatusSolic       		= '';
	LET dFechaInsert       		= '';
	LET iDiasRechazo       		= 0;
	LET cVar1       	= '';
	LET cVar2       = '';
	LET cnum_solicitud 			= '';
	LET cnum_solicitudAux 			= '';
	
	LET iNum_periodos           = 0;
	LET dtFecha_cuota           = DATE(1);
	LET dSdo_inicial            = 0;
	LET dPago_mensual           = 0;
	LET dMto_Interes            = 0;
	LET dIva_interes            = 0;
	LET dCapital                = 0;
	LET dSdo_final              = 0;
	LET sDias_periodo           = 0;
	LET v_diaspromedio 			=0;
	LET v_salariomin 			=0;
	LET dMto_min                = 0;
	LET dMto_max                = 0;
	LET Codret2                 = "000000";
	LET dtFecha_Aper            = DATE(1);
	LET v_capacidad             = 0;
	LET iPlazoMax               = 0;
	LET v_limite_inferior       = 0;
	LET v_grupo                 = "";
	LET cRFC =""; 
	LET cCodigoRet ="";
	LET cFechaUltimoPago =""; 
	LET cPrestamoAutorizado =""; 
	LET iMontoAutorizado ="";
	LET iReprestamo ="";
	LET cSitEsp           		= 0;
--Validacion IFE/INE
    LET B_ife                   = '';
    LET B_valida_ife            = '';
--Validacion IFE/INE

--Validacion limite cuentas de captaciÃ³n
	LET cCodErr = '000';
	LET cNumCueCapt = '0';	
--Validacion limite cuentas de captaciÃ³n
	---Valicacion Prestamo Flexible
	LET solApertPPFlex = '0';
--jom-26/11/2018
--Verificar que exista como empleado o como cliente Coppel
    LET cTicket	       = '';
	LET cEdo_proceso   = '';
	LET cNum_men       = '';
        LET cEmpresaHuella = '';
--jom-26/11/2018
	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
			LET CodRet = sql_err;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_obtiene_productos_cjunk_club.out";
--	SET DEBUG FILE TO "/pisa/pisabanco/sp_obtiene_productos_cjunk_club.out";
--	TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		SELECT valor::INTEGER INTO iPrestamosActivos FROM bdisolic:"informix".ss_param WHERE secuencia = '365' AND empresa = '001';
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
				IF (SELECT count(ejecutivo )				
					FROM bdinteg:"informix".si_usuario_movil
					WHERE ejecutivo = pEjecutivo) = 0  THEN
					LET CodRet = '000003';
				END IF;				
			
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
            ELSE
                SELECT ticket 
                INTO cTicket
                FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
                WHERE numcte = pNumcte;
		--jom-26/11/2018
		--Verificar que exista como empleado o como cliente Coppel
                IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
                    SELECT ticket 
                    INTO cTicket
                    FROM bdinteg:"informix".si_huella_linea_hist a   
                    WHERE numcte = pNumcte
                        AND fecha_consulta = (SELECT MAX(fecha_consulta)
                                              FROM bdinteg:"informix".si_huella_linea_hist b 
                                              WHERE numcte = pNumcte)
                        AND secuencia = (SELECT MAX(secuencia)
                                         FROM bdinteg:"informix".si_huella_linea_hist c 
                                         WHERE  numcte = pNumcte);
                END IF;
                
                IF NVL(cTicket,"") <> '' THEN
                    SELECT LIMIT 1 estado_proceso, num_mensaje, empresa
                     INTO cEdo_proceso, cNum_men, cEmpresaHuella
                     FROM bdinteg:"informix".si_huella_linea_resultado 
                     WHERE ticket = cTicket
                         AND estado_proceso = '2'
                         AND empresa IN (0,1,2,3,4)
                         AND num_mensaje = "602";
						 
					 IF nvl(cNum_Men,'') = '' THEN
						 SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
						 INTO cEdo_proceso, cNum_men, cEmpresaHuella
						 FROM bdinteg:"informix".si_huella_linea_resultado_hist 
						 WHERE ticket = cTicket
					   	   AND estado_proceso = '2'
						   AND empresa IN (0,1,2,3,4)
						   AND num_mensaje = "602";
					 END IF;

                     IF NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresaHuella,"") <> "" THEN    
                        LET pCoppel = '1';
                     END IF;
                 END IF;  
		--jom-26/11/2018
			END IF;
		END IF;




		DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;

		IF cDigiDom = '1' THEN
			FOREACH
				SELECT s.num_producto,s.tp_solicitud
				INTO cProdCop,cTpSolicitudOfr
				FROM bdisolic:"informix".ss_solic_producto s
				INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto AND p.sucursal = pSucursal)
				INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = pPuesto_local)
				WHERE s.empresa = pEmpresa
				AND s.tp_solicitud = 'C'
				AND s.num_producto NOT IN (	SELECT num_producto
											FROM bdisolic:"informix".ss_solicitudes
											WHERE empresa= pEmpresa
											AND numcte = pNumcte
											AND status_solicitud IN("EA","EE","AT","AP","CC","OA","OS","BC","ST","CE","LC","MC","EC","PA"))--JMAH RQM 09279 / RQM 18 023

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cProdCop,cTpSolicitudOfr,'S');
			END FOREACH
		ELSE
			-- Obtiene los productos de captacion con los que actualmente cuenta el cliente, se modifica para que se inserte la fecha de alta de la cuenta de captaciÃ³n
			FOREACH
				SELECT producto, noc.fecha_alta, status_cta
				INTO ProdActual, dFechaAlta, cStatus_cta
				FROM bdicheq:"informix".sc_maechq mae
				INNER JOIN bdicheq:"informix".sc_maenoc noc ON (noc.cuenta = mae.cuenta)
				WHERE num_cte = pNumcte
				-- ofertar producto de inversion 
                AND producto <> '1100'

				IF ProdActual = "1300" AND cStatus_cta <> '2' THEN
					LET cOfertaNomina = '1'; -- NO OFERTE EL PRODUCTO 1300 DE NOMINA, YA QUE NO SE ENCUENTRA CANCELADO ACTUALMENTE
				END IF;

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_act,fecha_alta) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual,dFechaAlta);
			END FOREACH

-- Validacion ife/ine ini

            -- Valida identificacion presentada por el cliente IFE/INE

            IF EXISTS (select numcte from bdinteg:"informix".si_ctepf where numcte = pNumcte and  codidentifi = 'A') THEN
            -- Extrae bandera de validacion de IFE
                SELECT nvl(valor,'')
                  INTO B_valida_ife
                  FROM bdisolic:"informix".ss_param
                 WHERE empresa = pEmpresa
                   AND secuencia = 376;
            -- Valida IFE/INE
                IF (B_valida_ife = '1') THEN
                    select nvl(case when upper(resultado) = 'VERDADERO' then '1' else '0' end,'1')
                      into B_ife
                      from bdinteg:"informix".si_bitacora_ife 
                     where numcte = pNumcte and fecha = (select max(fecha) from bdinteg:"informix".si_bitacora_ife where numcte = pNumcte);

                    IF ( B_ife <> '1') THEN
                        LET cSolcred_tramite = '1'; -- No ofrecer productos Credito Banco
                        -- Registra mensaje en bitacora
                        INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                                                                            causa,motivo,tipo_rechazo,codret,mensaje,saldomuebles,saldoropa,saldoprestamos,causa_solicitud,vencidototalmuebles,
                                                                            vencidototalropa,vencidoprestamos,abonomuebles,abonoropa,abonoprestamos,puntualidad,grupo, saldototalaire, 
																			vencidototalaire, abonomensualaire, saldototalafiliados, vencidototalafiliados, abonomensualafiliados, 
																			saldototalreestructura, vencidototalreestructura, abonomensualreestructura, scorepuntualidad)
                        --VALUES (pEmpresa,today,'6001',pSucursal,cnomcte,pEjecutivo,'Validacion IFE/INE','VIF');
                        VALUES (pEmpresa,today,'6001',pSucursal,cnomcte,'','',pEjecutivo,'0','','0','0','B','','005','Validacion IFE/INE','0','0','0','VIF','0','0','0','0','0','0','','','0','0','0','0','0','0','0','0','0','0');
                    END IF;
                END IF;
            END IF;

-- Validacion ife/ine  FIN
			-- Obtiene los productos de crÃ©dito con los que cuenta el cliente
			FOREACH
				SELECT num_producto,num_solicitud, status_solicitud, tipo_solicitud
				INTO ProdActual,cnum_solicitud, cStatus_sol,cTpSolicitudAct
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa= pEmpresa
				AND numcte= pNumcte
				AND status_solicitud IN ("BC","CC","ST","EA","EE","OA","OS","CE","AT","AP","RT","LC","MC","EC","PA") --JMA RQM 09279/RQM 18 023
				GROUP BY 1,2,3,4

				LET vactiva_insert = 1;

				IF cStatus_sol = "AP" OR cStatus_sol = "RT" THEN
					IF cTpSolicitudAct IN ('T','P') THEN
						IF cStatus_sol = "RT" AND cTpSolicitudAct = 'T' THEN
							LET solApert = '1';
							LET solApertPP = '1';
						ELIF cStatus_sol = "RT" AND cTpSolicitudAct = 'P' THEN
						--GJEVGJEV --RQM 10 713
						LET solApertRTCPS = '0';
						
						IF ProdActual IN ('6300','7600','7700') THEN
							IF  (
							select count(*) from bdisolic:"informix".ss_autorizacion where num_solicitud = cnum_solicitud
							AND status_solicitud = 'RT'
							AND causa_solicitud = 'CPS') > 0 THEN--capacidad de pago saturada							
							
								LET solApertRTCPS = '1';
								LET cnum_solicitudAux= cnum_solicitud;
							END IF;
							
						END IF;
						--GJEV FIN --RQM 10 713
						LET solApertPP = '1';
							
						END IF;	
						IF cTpSolicitudAct = 'T' THEN
							IF (SELECT COUNT(numcte) FROM bdicred:"informix".sd_maecred
								WHERE empresa = pEmpresa
								AND numcte = pNumcte
								AND status_cred NOT IN ('FC','FF')) > 0 THEN
								
								IF ProdActual ='7800' THEN
									LET solApert = '0';
								ELSE								
									LET solApert = '1';
								END If
								
							ELSE
								IF (SELECT COUNT(a.numcte) FROM bdicred:"informix".sd_maecredcrd a, bdisolic:"informix".ss_solic_producto b
									WHERE a.empresa = pEmpresa
									AND a.empresa = b.empresa
									AND a.num_producto = b.num_producto
									AND numcte = pNumcte
									AND tp_solicitud = 'R'
									AND status_cred <> 'FF') > 0 THEN
									LET solApert = '1';
								ELSE
									LET vactiva_insert = 0;
								END IF;
							END IF;
						END IF;
					ELSE
						IF cTpSolicitudAct = 'A' THEN
							IF (SELECT COUNT(a.numcte) FROM bdicred:"informix".sd_maecredcrd a, bdisolic:"informix".ss_solic_producto b
								WHERE a.empresa = pEmpresa
								AND a.empresa = b.empresa
								AND a.num_producto = b.num_producto
								AND numcte = pNumcte
								AND tp_solicitud = 'R'
								AND status_cred <> 'FF') = 0 THEN
								LET vactiva_insert = 0;
							END IF;
						-- * INC 24 006 (Valida cuando una solicitud esta en status_solicitud = 'AP' no permita oferta el producto
						--      de Tarjeta de Credito Coppel ya que el cliente ya tiene ese producto)
						ELIF cTpSolicitudAct = 'C' THEN
							LET cSolcred_tramite_cop = '1';
							LET vactiva_insert = 0;
						END IF;
					END IF;

						IF vactiva_insert = 1 THEN
							SELECT 1
							INTO cExiste
							FROM bdisolic:"informix".ss_productos_ofrecer
							WHERE cliente = pNumcte
							AND sucursal = pSucursal
							AND ejecutivo = pEjecutivo
							AND producto_act = ProdActual;

								IF NVL(cExiste,'') = '' THEN				
										INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
								END IF;	
						END IF;
				ELSE
					IF cTpSolicitudAct = 'C' THEN
						LET cSolcred_tramite_cop = '1';
					ELSE
						LET cSolcred_tramite = '1';
					END IF;
				END IF
			END FOREACH

			-- Verifica si el cliente presenta un crÃ©dito en reestructura
			FOREACH
				SELECT num_producto
				INTO ProdActual
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = pNumcte
				AND status_CRED <> 'FF'
				AND num_producto NOT IN (SELECT num_producto 
										FROM bdisolic:"informix".ss_solic_producto
										WHERE tp_solicitud = 'P')

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer(cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
			END FOREACH

			-- FMV 22-FEB-11 Verifica si el cliente presenta de CrÃ©dito Activo, previo a la Solicitud
			FOREACH
				SELECT num_producto,status_cred,num_credito
				INTO ProdActual,cStatus_cred,cNum_credito  
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND numcte = pNumcte
				AND status_cred NOT IN ('FC')
				AND num_producto NOT IN (SELECT producto_act FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo)

				IF cStatus_cred = "FF"  THEN ---JMAH 11/12/2012
					IF NOT EXISTS ( SELECT num_credito
									FROM bdicred:"informix".sd_cred_can
									WHERE empresa = pEmpresa
									AND num_credito= cNum_credito
									AND motivo_can ='FF2') THEN	
						LET iBanderaInserta =0;
					ELSE
						LET iBanderaInserta =1;
					END IF;
				ELSE
					LET iBanderaInserta =1;
				END IF;
				IF iBanderaInserta = 1 THEN
					INSERT INTO bdisolic:"informix".ss_productos_ofrecer(cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
				END IF;
			END FOREACH
			
			SELECT COUNT(num_credito)
			into solApertPPFlex
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa = pEmpresa
			AND numcte = pNumcte
			AND num_producto IN ('6800','7100')
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			
			IF(solApertPPFlex>0) THEN
				LET solApertPPFlex = '1';
			END IF;
			-- FMV
			--JMAH
			-- AAME 20150303 RQM 10 550 Se agregan nuevos productos de prestamo, considerando que se limitarÃ¡n al numero de prestamos activos que puede tener el cliente sobre prestamo personal actual (6300)  
			SELECT COUNT(num_credito)
            into inumpPrestamos
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa = pEmpresa
			AND numcte = pNumcte
			AND num_producto IN ('6300','7600','7700','6800', '7100')
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');

-- EM 2017/05/25
			
			SELECT RFC
				INTO cRFC
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumcte;
				
			IF cRFC <> "" THEN

				EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
				INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
			
			ELSE
				LET cFechaUltimoPago = '1900-01-01';
				LET cPrestamoAutorizado = '0';
				LET iMontoAutorizado = '0';
				LET iRePrestamo = '0';
				LET cCodigoRet = '000000';	
			END IF;
			
			
	
            IF (inumpPrestamos >= iPrestamosActivos) THEN
				--se inserta en la bitacora_precal
                LET solApertPP ='1';
				INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,ejecutivo,mensaje,causa_solicitud)
					VALUES (pEmpresa,today,'6300',pSucursal,cnomcte,pEjecutivo,'El Cliente cuenta con el tope mÃ³ximo de PrÃ³stamos Personales permitidos','RFP',cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo);
			END IF;
			--JMAH
			--JOM VALIDA PRESTAMOS CON LA REGLA DE PAGO SOSTENIDO INI
            IF ( inumpPrestamos > 0 ) THEN
                select count(*) 
                into inumpPrestamos
                from bdicred:"informix".sd_amortiza_creditocrd a
                where empresa = pEmpresa
                  and num_credito = (select max(num_credito) from bdicred:"informix".sd_maecredcrd b
                                    where a.empresa = empresa
                                      and numcte = pNumcte
                                      and fecha_apertura = (select max(fecha_apertura) 
                                                              from bdicred:"informix".sd_maecredcrd 
                                                             where b.empresa = empresa 
                                                               and b.numcte = numcte 
                                                               and status_cred in ('AA','BA','BT','E1','E2','E3')))
                  and num_pago >= (select max(num_pago) from bdicred:"informix".sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status <> '3') - 3
                  and capital_status = '5'
                  and capital_status_ant = '1';

                IF (inumpPrestamos < 3) THEN 
                    LET solApertPP ='1';
                    --se inserta en la bitacora_precal
                    INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,ejecutivo,mensaje,causa_solicitud,fechaultimopago,prestamoautorizado,montoautorizado,represtamo)
                        VALUES (pEmpresa,today,'6300',pSucursal,cnomcte,pEjecutivo,'El cliente no cumple la regla de pago sostenido','RFP',cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo);
                END IF;
             END IF;
            --JOM VALIDA PRESTAMOS CON LA REGLA DE PAGO SOSTENIDO FIN

			SELECT COUNT(producto_act)
			INTO sTotal_productos
			FROM bdisolic:"informix".ss_productos_ofrecer
			WHERE cliente = pNumcte
			AND sucursal = pSucursal
			AND ejecutivo = pEjecutivo;

			-- Obtiene los productos que un cliente puede solicitar en base a los productos con los que cuenta
			IF sTotal_productos > 0 THEN
				FOREACH
					SELECT b.prod_ofrecer
					INTO cprod_final
					FROM bdisolic:"informix".ss_tramite_productos a
					INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif b	ON (a.empresa = b.empresa AND a.clasificacion = b.clasificacion)
					INNER JOIN bdinteg:"informix".si_prod_sucursal p	ON (p.empresa = b.empresa AND p.sucursal = pSucursal AND p.num_producto = b.prod_ofrecer)
					INNER JOIN bdisolic:"informix".ss_productos_ofrecer c		ON (c.cliente = pNumcte AND c.sucursal = pSucursal AND c.ejecutivo = pEjecutivo AND a.prod_actual = c.producto_act)
					INNER JOIN bdinteg:"informix".si_prod_ejecut e		ON (b.empresa = e.empresa AND b.prod_ofrecer = e.num_producto AND e.perfil = pPuesto_local)
					AND a.empresa= pEmpresa
					AND (edad_min <= cedadcte AND edad_max >= cedadcte)
					AND a.sexo = cSexo --se agrega validacion del sexo
					AND a.prod_actual = c.producto_act
					AND NVL(restriccion_prod,'') NOT IN ( SELECT producto_act
														  FROM bdisolic:"informix".ss_productos_ofrecer
														  WHERE cliente    = pNumcte
														  AND sucursal   = pSucursal
														  AND ejecutivo  = pEjecutivo
														  AND producto_act IS NOT NULL)
					--                 AND b.prod_ofrecer NOT IN ( SELECT prod_ofrecer FROM "informix".ss_tramite_productos_clasif WHERE sistema='06' AND prod_ofrecer = b.prod_ofrecer
					--                 AND restriccion_prod = '6001' or restriccion_prod = '6600')
					SELECT tp_solicitud
					INTO cTpSolicitudOfr
					FROM bdisolic:"informix".ss_solic_producto
					WHERE num_producto = cprod_final;

					IF cTpSolicitudOfr IS NULL THEN
						LET cTpSolicitudOfr = 'D';
					END IF;

					IF cTpSolicitudOfr IN ('T','C') THEN
						SELECT 1
						INTO cNo_ofrecer
						FROM bdisolic:"informix".ss_productos_ofrecer
						WHERE cliente = pNumcte
						AND sucursal = pSucursal
						AND ejecutivo = pEjecutivo
						AND producto_act = cprod_final;
					END IF;

					IF NVL(cNo_ofrecer,'') <> '1' THEN
						SELECT 1
						INTO cExiste
						FROM bdisolic:"informix".ss_productos_ofrecer
						WHERE cliente = pNumcte
						AND sucursal = pSucursal
						AND ejecutivo = pEjecutivo
						AND producto_ofr = cprod_final;

						IF NVL(cExiste,'') = '' THEN
							INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cprod_final,cTpSolicitudOfr,'S');
						END IF;
					END IF;
					LET cNo_ofrecer ="";
				END FOREACH
			ELSE

				FOREACH
					SELECT b.prod_ofrecer,NVL(tp_solicitud,"D")
					INTO cprod_final,cTpSolicitudOfr
					FROM bdisolic:"informix".ss_tramite_productos a
					INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif b ON (a.empresa = b.empresa AND a.clasificacion = b.clasificacion)
					INNER JOIN bdinteg:"informix".si_prod_sucursal p	ON (p.empresa = a.empresa AND p.sucursal = pSucursal AND p.num_producto = b.prod_ofrecer)
					INNER JOIN bdinteg:"informix".si_prod_ejecut e		ON (b.empresa = e.empresa AND b.prod_ofrecer = e.num_producto AND e.perfil = pPuesto_local)
					LEFT JOIN bdisolic:"informix".ss_solic_producto c			ON (b.empresa = c.empresa AND b.prod_ofrecer = c.num_producto)
					WHERE a.empresa = pEmpresa
					AND (edad_min <= cedadcte AND edad_max >= cedadcte)
					AND prod_actual= ""
					AND a.sexo = cSexo --se agrega validacion del sexo

					SELECT 1
					INTO cExiste
					FROM bdisolic:"informix".ss_productos_ofrecer
					WHERE cliente    = pNumcte
					AND sucursal   = pSucursal
					AND ejecutivo  = pEjecutivo
					AND producto_ofr = cprod_final;

					IF NVL(cExiste,'') = '' THEN
						INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cprod_final,cTpSolicitudOfr,'S');
					END IF;
				END FOREACH
			END IF;
		END IF;
		
		-- BCPL Se consulta si es Cliente Prospecto, para validar la Respuesta de la OSCalle y obtener que Productos se pueden Ofertar
		SELECT numcte_pros INTO cCteProsp FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = pNumcte;

			--Si bandera_os estÃ³ activa se aplica vigencia de la OS calle, si la bandera_os estÃ¡ inactiva no se aplicarÃ¡Â¡ la vigencia de la OS calle 
			IF EXISTS (SELECT num_producto FROM bdicred:"informix".sd_definicion WHERE bandera_os='1') THEN		
				FOREACH
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
					SELECT LIMIT 1 b.fecharespuesta,b.clave,a.num_solicitud,'T' tipo_sol
					INTO dFechaRespOSCalle, cClave,cNumsolOs, cTipoSol 
					FROM  bdisolic:"informix".ss_solicitudes a
					JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
					WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) from bdisolic:"informix".ss_osclientesupervisar AS d WHERE d.num_solicitud = b.num_solicitud)
					AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte =pNumcte 
					UNION 
					SELECT fecharespuesta,clave,num_solicitud,'P' tipo_sol
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = '001' AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp)
					ORDER BY fecharespuesta DESC
				END FOREACH;	
			END IF;
		IF NVL(cCteProsp,'') <> '' THEN
			SELECT fecharespuesta, clave INTO dFechaRespOSCalle, cClave
			FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pEmpresa AND num_solicitud = cCteProsp
			AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud = cCteProsp);
	
		
			IF NVL(cClave,'') = 'R' THEN
				SELECT MAX(fecha_hoy) - MIN(dFechaRespOSCalle) INTO iDiasTrans FROM bdinteg:"informix".si_fechas;

				FOREACH
					SELECT clave_producto INTO cProductoOfrecer FROM bdisolic:"informix".ss_oscalle_vigencia WHERE vigrespos_oferta = 1

					IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_productos_ofrecer 
						WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr = cProductoOfrecer) THEN
						SELECT dias_vigencia INTO siDiasVigencia FROM bdisolic:"informix".ss_oscalle_plazovigencia 
						WHERE clave_producto = cProductoOfrecer AND resp_oscalle = cClave;

						IF NVL(iDiasTrans,0) <= NVL(siDiasVigencia,0) THEN
							UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' 
								WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr = cProductoOfrecer;
						END IF;
					END IF
				END FOREACH;
			END IF;
			
			-- CONSULTAMOS EL ULTIMO ESTATUS DEL CLIENTE PROSPECTO.
			FOREACH
				SELECT LIMIT 1 status_solicitud, fecha_insert INTO cStatusSolic, dFechaInsert
				FROM bdiprospectos:"informix".pr_autorizacion WHERE num_solicitud = cCteProsp
				ORDER BY fecha_hora DESC
				/*
				-- OBTENEMOS LA FECHA ACTUAL.
				SELECT fecha_hoy
				INTO dFechaHoy
				FROM bdicred:"informix".sd_fechas 
				WHERE empresa = pEmpresa;
				*/
				-- VALIDAMOS SI EL ULTIMO ESTATUS DEL CLIENTE PROSPECTO ES RECHAZADO "RT".
				IF cStatusSolic = "RT" THEN
					
					-- CALCULAMOS LOS DIAS QUE TIENE EL CLIENTE PROSPECTO CON ESTATUS DE SOLICITUD RECHAZADA "RT".
					--LET iDiasRechazo = (dFechaHoy - dFechaInsert);
					
					-- SI LA SOLICITUD TIENE 180 DIAS O MENOS DE RECHAZO NO SE LE OFERTARA TARJETA COPPEL 6500.
					--IF iDiasRechazo <= 180 THEN
						UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo 
						AND producto_ofr = '6500'; --IN ('6001','6500');
				--	END IF
				END IF
			END FOREACH;		
					
		END IF;				
		-- Valida si la sucursal puede ofrecer el producto coppel
		SELECT cajaunica
		INTO cSucCajaUnica
		FROM bditarjcop:"informix".sucursalescajaunica
		WHERE empresa = pEmpresa
		AND cvesucursal = pSucursal;

		IF NVL(cSucCajaUnica,'') = "" THEN
			LET cSucCajaUnica = 'F';
		END IF;

		-- validacion de NO OFERTAMIENTO de una solicitud Coppel de que si se trata de (un cliente con una solicitud coppel ya existente) o (de que si la sucursal pueda ofertar producto coppel) o (de si ya se encuentra en tramite una solicitud coppel)
		IF pCoppel = '1' OR cSucCajaUnica = 'F' OR cSolcred_tramite_cop = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('C');
		END IF;

		-- Validacion de NO OFERTAMIENTO para una solicitud de Banco para cuando (ya se cuenta con una solicitud Banco rechazada) o (de si ya se cuenta con un credito activo) o (de si ya se cuenta con una reestructura activa)
		IF solApert = '1' THEN
			--JMAH RQM 10 617
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T') and producto_ofr <> '7800';      --
		END IF;

		-- Validacion de NO OFERTAMIENTO para productos de credito que cuenten con (malos antecedentes en banco) o (malos antecedentes en coppel)
		IF pPrecalBco = '1'  OR pPrecalCoppel = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr <> 'D';
		END IF;

		IF solApertPPFlex = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('6800','7100');
		END IF;
		-- Validacion de NO OFERTAMIENTO para prestamo personal para cuando (ya se cuente con una solicitud rechaza de credito banco) o (ya se cuente con una solicitu de prestamo personal rechaza) AAME 02032015 RQM 10 550 Se agregan nuevos prestamos 7600 y 7700
		IF solApertPP = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('6300','7600','7700','6800','7100');
		END IF;
		
		-- Validacion de OFERTAMIENTO para prestamo personal para cuando (ya se cuente con una solicitud rechaza de credito banco) rechazada por capacidad de pago se oferten los productos de 18 y 24
		IF solApertRTCPS = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'S' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('7600','7700');
		END IF;
		
		-- validacion de NO OFERTAMIENTO de una solicitud Banco para cuando ya se cuenta con una solicitud Banco en tramite.
		IF cSolcred_tramite = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T','P');
		END IF;

		-- validacion de NO OFERTAMIENTO para el producto de nomina si es que ya se encuentra con una cuenta 1300 - PRODUCTO NOMINA EMPLEADOS GC que NO este cancelada
		IF cOfertaNomina = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte  AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'D' AND producto_ofr = '1300';
		END IF;
		
		--valida que no OFERTE PRODUCTOS de CREDITO para la comparacion de huella
		IF pOfertaProdCred = 1 THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;
		
		--valida que no OFERTE PRODUCTOS de DEBITO para la comparacion de huella - match cliente coppel con sit esp P - (9,10,13,18,19,21,49,51,55) T-16, V-40
		IF pOfertaProdCred = 2 THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr = 'D';
		END IF;

		--valida que no OFERTE PRODUCTOS de CREDITO para clientes con situacion especial U-62
		IF EXISTS (SELECT causa FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte AND situacion = "U" AND causa = 62)  THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;
		
		--P-109
		SELECT count(*)
		INTO cSitEsp
		FROM bdisitesp:"informix".se_ctessitespcte
		WHERE numcte=pNumCte AND situacion = "P" AND causa = 109;
		
		
		--valida que no OFERTE PRODUCTOS de CREDITO y DEBITO para clientes con situacion especial P-109
		IF NVL(cSitEsp,0) > 0 THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C','D');
		END IF;
		
				
		--valida que no OFERTE PRODUCTOS de CAPTACIÃ?N para clientes que sobrepase el LÃ­mite maximo de cuenta .
		EXECUTE PROCEDURE BDICHEQ: "informix".sp_limite_cuentas(pNumcte) INTO cCodErr, cNumCueCapt;
		IF cCodErr = '000' AND cNumCueCapt = '1'  THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica= 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo  = pEjecutivo 
			AND producto_ofr IN( SELECT producto FROM bdicheq: "informix".sc_producto WHERE producto NOT IN( '1100','3000') );
		END IF;
		
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
								(SELECT UPPER(descripcion) FROM bdisolic:"informix".ss_tp_solicitud 
								WHERE empresa = pEmpresa AND tp_solicitud = 'C')
							ELSE
								(SELECT UPPER(nombre_prod) FROM bdicred:"informix".sd_definicion d
								WHERE empresa = pEmpresa AND d.num_producto = tp.producto_ofr)                          
							END)
						END)
					END)
				END)
			INTO cprod_final, cTpSolicitudOfr, cPrioridad, cdescripcion
			FROM bdisolic:"informix".ss_productos_ofrecer  tp
			INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif t ON (tp.producto_ofr = t.prod_ofrecer)
			WHERE tp.cliente = pNumcte
			AND tp.sucursal = pSucursal
			AND tp.ejecutivo = pEjecutivo
			AND aplica = 'S'
			ORDER BY t.prioridad

			--Valida si el producto a ofrecer es de credito, para validar la fecha alta en caso que lo requiera.
			IF cprod_final  = '6400' THEN 
				IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto = cprod_final AND meses_alta IS NOT NULL) THEN
					--se valida que debe tener una cuenta con la vigencia valida para ofrecer credinomina.
					--Obtiene meses necesarios de alta para ofrecer el producto
					SELECT fecha_hoy
					INTO dFechaHoy
					FROM bdicred:"informix".sd_fechas 
					WHERE empresa = pEmpresa;

					FOREACH
						SELECT tp2.fecha_alta, cp2.meses_alta
						INTO dFechaAlta, iMeses
						FROM bdisolic:"informix".ss_productos_ofrecer tp2
						INNER JOIN bdisolic:"informix".ss_producto_credcap cp2 ON (cp2.num_producto = cprod_final AND cp2.producto_cap = tp2.producto_act)		
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
			
			
			IF cTpSolicitudOfr = 'P' AND cprod_final  <> '6400' AND solApertRTCPS = '1'   THEN--JMAH RQM 09 408-2
				
				SELECT valor_rab, grupo
				INTO v_capacidad,v_grupo		
				FROM bdisolic:"informix".ss_revision_determinacion
				WHERE empresa = pEmpresa
				AND num_solicitud = cnum_solicitudAux;
			
					LET cOfertar ='N';
				LET dPago_mensual=0;
				IF v_capacidad > 0 THEN 	
					SELECT NVL(plazo_max_cred,0)
					INTO iPlazoMax
					FROM bdicred:"informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cprod_final;
					   
					SELECT valor::DECIMAL(14,2)
					  INTO v_salariomin -- Salario Minimo Base
					  FROM bdisolic:"informix".ss_param
					 WHERE empresa = pEmpresa
					   AND secuencia = 354;					

					SELECT valor::DECIMAL(14,2)
					  INTO v_diaspromedio -- Salario Minimo Base
					  FROM bdisolic:"informix".ss_param
					 WHERE empresa = pEmpresa
					   AND secuencia = 355;   
					   
					SELECT (sum(round(cant_smb_inf * v_salariomin * v_diaspromedio,-2)))
					INTO v_limite_inferior			
					FROM bdisolic:"informix".ss_scoring_solic
					WHERE empresa = pEmpresa
					AND tp_solicitud = cTpSolicitudOfr
					AND seccion = '2'
					AND activa = '1'
					AND grupo = v_grupo; 
					  
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (NVL(v_limite_inferior,3300),iPlazoMax,0,cprod_final,pSucursal,0,0,'',"",1)
					INTO Codret2,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
					dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;

					IF Codret2 <> "000000" THEN
						CONTINUE FOREACH;
					END IF;	
					IF (  v_capacidad >= dPago_mensual  ) then
						LET cOfertar = "S";					
					END IF;					
				END IF;
				
				
				IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
				END  IF;
					
			END IF;		
			
			
			IF cprod_final  = '7800' THEN --JMAH RQM 10 617
				   LET cOfertar ='N';
			       FOREACH
						EXECUTE PROCEDURE "informix".sp_adn_obtienectas('001', pNumcte)											
						INTO cVar1,cVar2
						IF cVar1::INTEGER = 0 THEN
							LET cOfertar = "S";
							EXIT FOREACH;
						END IF 
					END  FOREACH;

					IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
					END  IF;
				
			END IF;
			
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET CodRet = '000001';
		END IF;

		DELETE FROM bdisolic:"informix".ss_productos_ofrecer  WHERE cliente = pNumcte AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo;

		IF CodRet = '000001' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
	END;
END PROCEDURE
