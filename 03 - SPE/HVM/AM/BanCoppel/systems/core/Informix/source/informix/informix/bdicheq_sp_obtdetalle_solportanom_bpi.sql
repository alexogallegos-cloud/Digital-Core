CREATE PROCEDURE "informix".sp_obtdetalle_solportanom_bpi(pEmpresa CHAR(3),pCliente CHAR(20),pFolioSol CHAR(30))
RETURNING
	CHAR(5)   AS	vcCodRet,
	CHAR(20)  AS 	vcNumcliente,
	CHAR(30)  AS 	vcFolioSolicitud,
	CHAR(1)   AS	vcEstatuspPortabilidad,
	CHAR(100) AS	vcDescripcionEstatus,
	CHAR(100) AS	vcCuentaOrdenante,
	CHAR(40)  AS   vcNomProductoOrd,
	CHAR(50)  AS	vcClabeCtaOrdenante,
	CHAR(50)  AS	vcBancoOrdenante,
	CHAR(100) AS 	vcCuentaReceptora,
	CHAR(40)  AS   vcNomProductoRec,
	CHAR(50)  AS	vcClabeCtaReceptora,
	CHAR(50)  AS	vcBancoReceptor,
	CHAR(50)  AS	vcNomBcoOrdLargo;
	
	-- Creador: MoisÃ©s Soriano
	-- Objetivo: Obtiene detalle de las solicitudes de portabilidad de nÃ³mina del cliente.
	-- SolicitÃ³: Alejandro Vazquez
	-- Fecha: 10/02/2016
	-- Se agrega la utilizaciÃ³n de Ã­ndices para reducir costos
	-- Bibiana Gaxiola Verdugo
	-- Fecha: 30/03/2016
	-- Se agrega validaciÃ³n de TDC
	-- Gabriela Aguilar
	-- 19/05/2020
	
	
	--DECLARA VARIABLES
	DEFINE cCodRet					CHAR (5);
	DEFINE cSqlErr					SMALLINT;
	DEFINE vcNumCliente				CHAR(20);
	DEFINE vcFolioSolicitud			CHAR(30);
	DEFINE vcEstatuspPortabilidad	CHAR(1);
	DEFINE vcDescripcionEstatus		CHAR(100);
	DEFINE vcCuentaOrdenante		CHAR(100);
	DEFINE vcClabeCtaOrdenante		CHAR(50);
	DEFINE vcBancoOrdenante			CHAR(50);
	DEFINE vcCuentaReceptora		CHAR(100);
	DEFINE vcClabeCtaReceptora		CHAR(50);
	DEFINE vcBancoReceptor			CHAR(50);
	DEFINE vcClaveOrigen			CHAR(1);
	DEFINE vcClaveSentido			CHAR(1);
	DEFINE viTamanioFolio			INT;
	DEFINE vcCuenta					CHAR(20);
	DEFINE vcNumProducto			CHAR(4);
	DEFINE vcNomProducto			CHAR(40);
	DEFINE vcCuentaConcat			CHAR(100);
	DEFINE vcCuentaClabe			CHAR(18);
	DEFINE viTamanioCta				INT;
	DEFINE vcNomProductoOrd 		CHAR(40);
	DEFINE vcNomProductoRec 		CHAR(40);
	DEFINE vcBancoAux				CHAR(5);
	DEFINE vcNomBcoOrdLargo			CHAR(50);
		
	--INICIALIZA VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vcNumCliente			= '';
	LET vcFolioSolicitud		= '';
	LET vcEstatuspPortabilidad	= '';
	LET vcDescripcionEstatus	= '';
	LET vcCuentaOrdenante		= '';
	LET vcClabeCtaOrdenante		= '';
	LET vcBancoOrdenante		= '';
	LET vcCuentaReceptora		= '';
	LET vcClabeCtaReceptora		= '';
	LET vcBancoReceptor			= '';
	LET vcClaveOrigen			= '';
	LET vcClaveSentido			= '';
	LET viTamanioFolio			= 0;
	LET vcCuenta				= '';
	LET vcNumProducto			= '';
	LET vcNomProducto			= '';
	LET vcCuentaConcat			= '';
	LET vcCuentaClabe			= '';
	LET viTamanioCta			= 0;
	LET vcNomProductoOrd 		= '';
	LET vcNomProductoRec 		= '';
	LET vcBancoAux				= '';
	LET vcNomBcoOrdLargo			= '';
	
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet,vcNumCliente,vcFolioSolicitud,vcEstatuspPortabilidad,vcDescripcionEstatus,vcCuentaOrdenante,vcNomProductoOrd,vcClabeCtaOrdenante,vcBancoOrdenante,vcCuentaReceptora,vcNomProductoRec,vcClabeCtaReceptora,vcBancoReceptor,vcNomBcoOrdLargo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/gaby/portabilidad/sp_obtdetalle_solportanom_bpi.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;
		
		
		LET viTamanioFolio = LENGTH(TRIM(pFolioSol));
		--Consulta con cuenta debito como pFolioSol para cancelaciÃ³n, sentido 1 PN bancoppel a otro bco
		IF (viTamanioFolio=11) THEN
			IF EXISTS(SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta = pFolioSol)THEN
				--Cuenta ordenante = cuenta clabe
				IF EXISTS(SELECT {+INDEX (sc_portacec_solicitud, idx_cte_ctaord)} num_cte FROM bdicheq:"informix".sc_portacec_solicitud WHERE num_cte = pCliente AND cta_ordenante = (SELECT cuenta_clabe FROM bdicheq:"informix".sc_maechq WHERE num_cte= pCliente AND cuenta = pFolioSol))THEN
					 SELECT {+INDEX (sc_portacec_solicitud, idx_emp_cte_ctaord)} num_cte,folio_solicitud,estatus_portabilidad,cta_ordenante,bco_ordenante,cta_receptora,bco_receptor,clave_origen,clave_sentido
					 INTO vcNumcliente, vcFolioSolicitud, vcEstatuspPortabilidad, vcCuentaOrdenante, vcBancoOrdenante, vcCuentaReceptora, vcBancoReceptor, vcClaveOrigen, vcClaveSentido
					 FROM bdicheq:"informix".sc_portacec_solicitud 
					 WHERE empresa = '001' AND num_cte = pCliente AND cta_ordenante = (SELECT cuenta_clabe FROM bdicheq:"informix".sc_maechq where cuenta=pFolioSol) AND clave_sentido='1';
						 
					 SELECT {+INDEX (sc_relacion_estatus, idx_estatus_cve)} descripcion INTO vcDescripcionEstatus
					 FROM bdicheq:"informix".sc_relacion_estatus 
					 WHERE estatus_portabilidad = vcEstatuspPortabilidad AND clave_origen = vcClaveOrigen AND clave_sentido = vcClaveSentido;
					 
					 SELECT cuenta,producto,cuenta_clabe INTO vcCuenta, vcNumProducto, vcCuentaClabe
					 FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta_clabe = vcCuentaOrdenante;
					
					 SELECT nombre INTO vcNomProducto
					 FROM bdicheq:"informix".sc_producto WHERE producto = vcNumProducto;
				
					 --LET vcCuentaOrdenante = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||'  CLABE: ' || TRIM(vcCuentaClabe);
					 LET vcCuentaOrdenante = TRIM(vcCuenta);					 LET vcClabeCtaOrdenante = TRIM(vcCuentaClabe);
					 --LET vcNomProductoOrd = TRIM(vcNomProducto);
					 LET vcNomProductoOrd = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
					 
					 --BANCO NOMBRE LARGO
					 LET vcBancoAux = SUBSTRING(vcBancoOrdenante FROM 3 FOR 3);
					 SELECT descripcion INTO vcNomBcoOrdLargo FROM bdinteg:"informix".si_bancos WHERE  banco = vcBancoAux;
					 
					 RETURN cCodRet,NVL(vcNumCliente,''),NVL(vcFolioSolicitud,''),NVL(vcEstatuspPortabilidad,''),NVL(vcDescripcionEstatus,''),NVL(vcCuentaOrdenante,''),NVL(vcNomProductoOrd,''),NVL(vcClabeCtaOrdenante,''),NVL(vcBancoOrdenante,''),NVL(vcCuentaReceptora,''),NVL(vcNomProductoRec,''),NVL(vcClabeCtaReceptora,''),NVL(vcBancoReceptor,''),NVL(vcNomBcoOrdLargo,'');
				--Cuenta ordenante = numero de tarjeta	
				ELIF EXISTS(SELECT {+INDEX (sc_portacec_solicitud, idx_cte_ctaord)} num_cte FROM bdicheq:"informix".sc_portacec_solicitud WHERE num_cte = pCliente )THEN-- AND cta_ordenante = (SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE numcte= pCliente AND cuenta = pFolioSol and num_tarjeta=vcCuentaOrdenante))THEN
					 SELECT {+INDEX (sc_portacec_solicitud, idx_emp_cte_ctaord)} num_cte,folio_solicitud,estatus_portabilidad,cta_ordenante,bco_ordenante,cta_receptora,bco_receptor,clave_origen,clave_sentido
					 INTO vcNumcliente, vcFolioSolicitud, vcEstatuspPortabilidad, vcCuentaOrdenante, vcBancoOrdenante, vcCuentaReceptora, vcBancoReceptor, vcClaveOrigen, vcClaveSentido
					 FROM bdicheq:"informix".sc_portacec_solicitud 
					 WHERE empresa = '001' AND num_cte = pCliente AND clave_sentido='1';						 
					 SELECT {+INDEX (sc_relacion_estatus, idx_estatus_cve)} descripcion INTO vcDescripcionEstatus
					 FROM bdicheq:"informix".sc_relacion_estatus 
					 WHERE estatus_portabilidad = vcEstatuspPortabilidad AND clave_origen = vcClaveOrigen AND clave_sentido = vcClaveSentido;
					 
					 SELECT cuenta,producto,cuenta_clabe INTO vcCuenta, vcNumProducto, vcCuentaClabe
					 FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta = pFolioSol;
					
					 SELECT nombre INTO vcNomProducto
					 FROM bdicheq:"informix".sc_producto WHERE producto = vcNumProducto;
				
					 --LET vcCuentaOrdenante = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||'  CLABE: ' || TRIM(vcCuentaClabe);
					 LET vcCuentaOrdenante = TRIM(vcCuenta);					 LET vcClabeCtaOrdenante = TRIM(vcCuentaClabe);
					 --LET vcNomProductoOrd = TRIM(vcNomProducto);
					 LET vcNomProductoOrd = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
					  
					 --BANCO NOMBRE LARGO
					 LET vcBancoAux = SUBSTRING(vcBancoOrdenante FROM 3 FOR 3);
					 SELECT descripcion INTO vcNomBcoOrdLargo FROM bdinteg:"informix".si_bancos WHERE  banco = vcBancoAux;
					  
					 RETURN cCodRet,NVL(vcNumCliente,''),NVL(vcFolioSolicitud,''),NVL(vcEstatuspPortabilidad,''),NVL(vcDescripcionEstatus,''),NVL(vcCuentaOrdenante,''),NVL(vcNomProductoOrd,''),NVL(vcClabeCtaOrdenante,''),NVL(vcBancoOrdenante,''),NVL(vcCuentaReceptora,''),NVL(vcNomProductoRec,''),NVL(vcClabeCtaReceptora,''),NVL(vcBancoReceptor,''),NVL(vcNomBcoOrdLargo,'');
						
				ELSE
					LET cCodRet = '00003';					RETURN cCodRet,NVL(vcNumCliente,''),NVL(vcFolioSolicitud,''),NVL(vcEstatuspPortabilidad,''),NVL(vcDescripcionEstatus,''),NVL(vcCuentaOrdenante,''),NVL(vcNomProductoOrd,''),NVL(vcClabeCtaOrdenante,''),NVL(vcBancoOrdenante,''),NVL(vcCuentaReceptora,''),NVL(vcNomProductoRec,''),NVL(vcClabeCtaReceptora,''),NVL(vcBancoReceptor,''),NVL(vcNomBcoOrdLargo,'');
				END IF;
			ELSE
				LET cCodRet= '00002';				RETURN cCodRet,NVL(vcNumCliente,''),NVL(vcFolioSolicitud,''),NVL(vcEstatuspPortabilidad,''),NVL(vcDescripcionEstatus,''),NVL(vcCuentaOrdenante,''),NVL(vcNomProductoOrd,''),NVL(vcClabeCtaOrdenante,''),NVL(vcBancoOrdenante,''),NVL(vcCuentaReceptora,''),NVL(vcNomProductoRec,''),NVL(vcClabeCtaReceptora,''),NVL(vcBancoReceptor,''),NVL(vcNomBcoOrdLargo,'');
			END IF;	
		--Consulta con folio pFolioSol para estatus
		ELSE	
				 SELECT num_cte,folio_solicitud,estatus_portabilidad,cta_ordenante,bco_ordenante,cta_receptora,bco_receptor,clave_origen,clave_sentido
				 INTO vcNumcliente, vcFolioSolicitud, vcEstatuspPortabilidad, vcCuentaOrdenante, vcBancoOrdenante, vcCuentaReceptora, vcBancoReceptor, vcClaveOrigen, vcClaveSentido
				 FROM bdicheq:"informix".sc_portacec_solicitud 
				 WHERE empresa = pEmpresa AND num_cte = pCliente AND folio_solicitud = pFolioSol;
				 
				 SELECT {+INDEX (sc_relacion_estatus, idx_estatus_cve)} descripcion INTO vcDescripcionEstatus
				 FROM bdicheq:"informix".sc_relacion_estatus 
				 WHERE estatus_portabilidad = vcEstatuspPortabilidad AND clave_origen = vcClaveOrigen AND clave_sentido = vcClaveSentido;
				
				
				IF (vcClaveSentido='1')THEN--Sentido 1 PN Bancoppel a otro banco
					LET viTamanioCta = LENGTH(TRIM(vcCuentaOrdenante));
					IF (viTamanioCta=18)THEN --cuenta_clabe
						SELECT cuenta,producto,cuenta_clabe INTO vcCuenta, vcNumProducto, vcCuentaClabe
						FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta_clabe = vcCuentaOrdenante;
						
						SELECT nombre INTO vcNomProducto
						FROM bdicheq:"informix".sc_producto WHERE producto = vcNumProducto;
					
						--LET vcCuentaOrdenante = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||'  CLABE: ' || TRIM(vcCuentaClabe);
						LET vcCuentaOrdenante = TRIM(vcCuenta);						LET vcClabeCtaOrdenante = TRIM(vcCuentaClabe);
						--LET vcNomProductoOrd = TRIM(vcNomProducto);
						LET vcNomProductoOrd = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
						
					ELIF(viTamanioCta=16)THEN --num_tarjeta
						SELECT cuenta INTO vcCuenta FROM bdicheq:"informix".sc_tarjeta WHERE numcte = pCliente AND num_tarjeta = vcCuentaOrdenante;
						SELECT producto, cuenta_clabe INTO vcNumProducto, vcCuentaClabe FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta = vcCuenta;
						SELECT nombre INTO vcNomProducto FROM bdicheq:"informix".sc_producto where producto = vcNumProducto;
						
						--LET vcCuentaOrdenante = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||'  CLABE: ' || TRIM(vcCuentaClabe); 
						LET vcCuentaOrdenante = TRIM(vcCuenta);						LET vcClabeCtaOrdenante = TRIM(vcCuentaClabe);
						--LET vcNomProductoOrd = TRIM(vcNomProducto);
						LET vcNomProductoOrd = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
						
					END IF;
				ELIF (vcClaveSentido='2') THEN--Sentido 2 PN Otro banco a Bancoppel
					LET viTamanioCta = LENGTH(TRIM(vcCuentaReceptora));
					IF (viTamanioCta=18)THEN --cuenta_clabe
						SELECT cuenta,producto,cuenta_clabe INTO vcCuenta, vcNumProducto, vcCuentaClabe
						FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta_clabe = vcCuentaReceptora;
						
						SELECT nombre INTO vcNomProducto
						FROM bdicheq:"informix".sc_producto WHERE producto = vcNumProducto;
						
						--LET vcCuentaReceptora = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||'  CLABE: ' || TRIM(vcCuentaClabe);
						LET vcCuentaReceptora = TRIM(vcCuenta);						LET vcClabeCtaReceptora = TRIM(vcCuentaClabe);
						--LET vcNomProductoRec = TRIM(vcNomProducto);
						  LET vcNomProductoRec = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
						  
					ELIF(viTamanioCta=16)THEN --num_tarjeta
						SELECT cuenta INTO vcCuenta FROM bdicheq:"informix".sc_tarjeta WHERE numcte = pCliente AND num_tarjeta = vcCuentaReceptora;
						SELECT producto, cuenta_clabe INTO vcNumProducto, vcCuentaClabe FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND cuenta = vcCuenta;
						SELECT nombre INTO vcNomProducto FROM bdicheq:"informix".sc_producto WHERE producto = vcNumProducto;
						
						--LET vcCuentaReceptora = TRIM(vcCuenta) ||' - '|| TRIM(vcNomProducto) ||' CLABE: ' || TRIM(vcCuentaClabe);
						LET vcCuentaReceptora = TRIM(vcCuenta);						LET vcClabeCtaReceptora = TRIM(vcCuentaClabe);
						--LET vcNomProductoRec = TRIM(vcNomProducto);
						LET vcNomProductoRec = TRIM(vcNumProducto)||' '|| TRIM(vcNomProducto);
						
					END IF;
				END IF;
				
				--BANCO NOMBRE LARGO
				 LET vcBancoAux = SUBSTRING(vcBancoOrdenante FROM 3 FOR 3);
				 SELECT descripcion INTO vcNomBcoOrdLargo FROM bdinteg:"informix".si_bancos WHERE  banco = vcBancoAux;

				 RETURN cCodRet,NVL(vcNumCliente,''),NVL(vcFolioSolicitud,''),NVL(vcEstatuspPortabilidad,''),NVL(vcDescripcionEstatus,''),NVL(vcCuentaOrdenante,''),NVL(vcNomProductoOrd,''),NVL(vcClabeCtaOrdenante,''),NVL(vcBancoOrdenante,''),NVL(vcCuentaReceptora,''),NVL(vcNomProductoRec,''),NVL(vcClabeCtaReceptora,''),NVL(vcBancoReceptor,''),NVL(vcNomBcoOrdLargo,'');
		END IF;		
	END;
END PROCEDURE;