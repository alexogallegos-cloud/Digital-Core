CREATE PROCEDURE "informix".sp_determina_productos_pba(pnumcte CHAR(20),psucursal CHAR(4),pejecutivo CHAR(8),pPuestoEje CHAR(1),pcredCoppel CHAR(1),pPrecalCoppel CHAR(1),pDigiDomicilio CHAR (1),pIdentificacion CHAR (1))
RETURNING CHAR(6)       	AS codigo_retorno,
		CHAR(6)     		AS codigo_producto,
		CHAR(120)			AS descripcion_producto,
		CHAR(700)			AS causas_rechazo;
	  
-- ****************************************************************************
-- *                        DESCRIPCION DE ENTRADA                            *
-- ****************************************************************************

---		pnumcte CHAR(20)					Numero de cliente
---		psucursal CHAR(4)					Numero de sucursal
---		pejecutivo CHAR(8)					Numero de ejecutivo
---		pPuestoEje CHAR(1)					Puesto del ejecutivo (se compara si_ejecut y si_perfilproductos)
---		pcredCoppel CHAR(1)					Credito Coppel 0, parametro para buscar en la si_relacion_ctebcplcpl
---		pPrecalCoppel CHAR(1)				Precalificacion 0, parametro para buscar en la si_relacion_ctebcplcpl
---		pDigiDomicilio CHAR (1)				Digitalizacion 1, siÂ­ se marca en 0 no oferta productos
---		pIdentificacion CHAR (1)			Identificacion 1, siÂ­ se marca en 0 no oferta productos

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet      		CHAR(6); 
DEFINE vCadenaProductos		CHAR (6);
DEFINE vMensaje             CHAR(120);
DEFINE vCausasRechazo		CHAR (700);

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;

DEFINE p_empresa			CHAR(3);
DEFINE p_auxProducto		CHAR(15);
DEFINE p_producto			CHAR(4);

---- Valida situacion especial IFE
DEFINE vCodRetSei			CHAR(5);
DEFINE vSitEspSei			CHAR(5);

---- Situacion Pago Banco
DEFINE 	vCodRedSptb			CHAR(5);  
DEFINE 	vMensajeSptb		CHAR(300);
DEFINE 	vTipoPerSptb		CHAR(2);
DEFINE 	vnumcteRefSpb		CHAR(20);
DEFINE 	vNombreRef1Spb		CHAR(120);
DEFINE 	vnumcteRef2Spb		CHAR(20);
DEFINE 	vNombreRef2Spb		CHAR(120);
DEFINE 	vSexoSpb			CHAR(1);
DEFINE 	vEdoCivilSpb		CHAR(1);  
DEFINE 	vEdadSpb			SMALLINT;
DEFINE 	vTipoViviendaSpb	CHAR(2);
DEFINE 	vPuestoSpb			CHAR(3);
DEFINE 	vTieneCredSpb		CHAR(1);
DEFINE 	vProfesinSpb		CHAR(3);
DEFINE 	vTelRef1Spb			CHAR(13);
DEFINE 	vTelRef2Spb			CHAR(13);
DEFINE 	vParentescoRef1Spb	CHAR(2); 
DEFINE 	vParentescoRefSpb	CHAR(2);
DEFINE 	vNumRefCteSpb		CHAR(20); 

---- Situacion Pago Banco 2
DEFINE 	vCodRedSptb2		CHAR(5);  
DEFINE 	vMensajeSptb2		CHAR(300);
DEFINE 	vTipoPerSptb2		CHAR(2);
DEFINE 	vnumcteRefSpb2		CHAR(20);
DEFINE 	vNombreRef1Spb2		CHAR(120);
DEFINE 	vnumcteRef2Spb2		CHAR(20);
DEFINE 	vNombreRef2Spb2		CHAR(120);
DEFINE 	vSexoSpb2			CHAR(1);
DEFINE 	vEdoCivilSpb2		CHAR(1);  
DEFINE 	vEdadSpb2			SMALLINT;
DEFINE 	vTipoViviendaSpb2	CHAR(2);
DEFINE 	vPuestoSpb2			CHAR(3);
DEFINE 	vTieneCredSpb2		CHAR(1);
DEFINE 	vProfesinSpb2		CHAR(3);
DEFINE 	vTelRef1Spb2		CHAR(13);
DEFINE 	vTelRef2Spb2		CHAR(13);
DEFINE 	vParentescoRef1Spb2	CHAR(2); 
DEFINE 	vParentescoRefSpb2	CHAR(2);
DEFINE 	vNumRefCteSpb2		CHAR(20); 

DEFINE vSituacionBanco		INT;

---- Mensaje Maestro
DEFINE vCodRetMaes				CHAR(5);
DEFINE vnummensajeMaes			SMALLINT;
DEFINE vSecuenciamensajeMaes	SMALLINT;
DEFINE vMensajeMaes				CHAR(100);

DEFINE vCadenaMaestro			CHAR(700);

--- Valida fecha
DEFINE vCodRetVf				CHAR(5);
DEFINE vFechaInsertVf			DATE;

---- Valida situacion especial IFE
DEFINE vCodRetSei2			CHAR(5);
DEFINE vSitEspSei2			CHAR(5);

DEFINE pOfertaProdCred		INT;

--- Oferta Producto

DEFINE vCodRetOfProd			CHAR(6);
DEFINE vprod_finalOfProd		CHAR(4);
DEFINE vTpSolicitudOfProd		CHAR(1);
DEFINE vdescripcionOfProd		CHAR(40);
DEFINE vPrioridadOfProd			CHAR(2);



DEFINE bandera_prod_coppel		INTEGER;
DEFINE bandera_prod_banco		INTEGER;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET cCodRet      			= '00000';
LET vCadenaProductos		= '';
LET vMensaje				= '';
LET vCausasRechazo			= '';

LET iSqlErr      			= 0;
LET iIsamErr     			= 0;

LET p_empresa 				= '';
LET p_auxProducto			= '';
LET p_producto 				= '';

---- Valida situacion especial IFE
LET vCodRetSei				= '';
LET vSitEspSei				= '';

---- Situacion Pago Banco
LET vCodRedSptb			    = '';
LET vMensajeSptb		    = '';
LET vTipoPerSptb		    = '';
LET vnumcteRefSpb		    = '';
LET vNombreRef1Spb		    = '';
LET vnumcteRef2Spb		    = '';
LET vNombreRef2Spb		    = '';
LET vSexoSpb			    = '';
LET vEdoCivilSpb		    = '';
LET vEdadSpb			    = 0;
LET vTipoViviendaSpb	    = '';
LET vPuestoSpb			    = '';
LET vTieneCredSpb		    = '';
LET vProfesinSpb		    = '';
LET vTelRef1Spb			    = '';
LET vTelRef2Spb			    = '';
LET vParentescoRef1Spb	    = '';
LET vParentescoRefSpb	    = '';
LET vNumRefCteSpb		    = '';

---- Situacion Pago Banco 2
LET vCodRedSptb2			= '';
LET vMensajeSptb2			= '';
LET vTipoPerSptb2			= '';
LET vnumcteRefSpb2			= '';
LET vNombreRef1Spb2			= '';
LET vnumcteRef2Spb2			= '';
LET vNombreRef2Spb2			= '';
LET vSexoSpb2				= '';
LET vEdoCivilSpb2			= '';
LET vEdadSpb2				= 0;
LET vTipoViviendaSpb2		= '';
LET vPuestoSpb2				= '';
LET vTieneCredSpb2			= '';
LET vProfesinSpb2			= '';
LET vTelRef1Spb2			= '';
LET vTelRef2Spb2			= '';
LET vParentescoRef1Spb2		= '';
LET vParentescoRefSpb2		= '';
LET vNumRefCteSpb2			= '';

LEt vSituacionBanco			= 0;

--- Mensaje Maestro

LET vCodRetMaes             = '1';
LET vnummensajeMaes         = 0;
LET vSecuenciamensajeMaes   = 0;
LET vMensajeMaes            = '';
LET vCadenaMaestro			= '';

--- Valida fecha
LET vCodRetVf			= '';
LET vFechaInsertVf		= DATE(1);

---- Valida situacion especial IFE 2
LET vCodRetSei2				= '';
LET vSitEspSei2				= '';

LET pOfertaProdCred			= 0;

--- Oferta Producto

LET vCodRetOfProd			= '';
LET vprod_finalOfProd		= '';
LET vTpSolicitudOfProd		= '';
LET vdescripcionOfProd		= '';
LET vPrioridadOfProd		= '';
LET vCadenaProductos 		= '';

LET bandera_prod_coppel		= 0;
LET bandera_prod_banco		= 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;		
				RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
			END IF;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/RESPALDOSNEW/trace/sp_determina_productos'||trim(pnumcte)||'.out';
		TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

		SELECT valor
		INTO p_empresa
		FROM bdicred:sd_param
		WHERE cod_param = '40';

		---- Obtiene producto TDC 6001
		SELECT valor
		INTO p_auxProducto
		FROM bdicred:sd_param
		WHERE cod_param = '058';

		LET p_empresa = TRIM (p_empresa);
		LET p_producto = SUBSTR (p_auxProducto,9,4);

		---- Valida situacion especial IFE
		EXECUTE PROCEDURE bdisitesp:sp_valsitesp_ife(pnumcte)
			INTO vCodRetSei,vSitEspSei;
		
			IF (vCodRetSei < 0) THEN
				LET cCodRet = vCodRetSei;
				LET vCausasRechazo = "Error al validar Situacion IFE";
				RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
			END IF;

		---- Situacion Pago Banco		
		EXECUTE PROCEDURE bdisolic:situacion_pago_banco_cjunk(p_empresa,pnumcte,p_producto,psucursal,pejecutivo,0,'1')
			INTO vCodRedSptb,vMensajeSptb,vTipoPerSptb,vnumcteRefSpb,vNombreRef1Spb,vnumcteRef2Spb,
				vNombreRef2Spb,vSexoSpb,vEdoCivilSpb,vEdadSpb,vTipoViviendaSpb,vPuestoSpb,vTieneCredSpb,
				vProfesinSpb,vTelRef1Spb,vTelRef2Spb,vParentescoRef1Spb,vParentescoRefSpb,vNumRefCteSpb;
		
			IF vCodRedSptb < 0 THEN
				LET cCodRet = vCodRedSptb;
				LET vCausasRechazo = "Error al validar Situacion Pago Banco";
				RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
			ELSE 
				LET cCodRet = vCodRedSptb;
				LET vMensaje = vMensajeSptb;
			END IF;
			
		---- Situacion Pago Banco 2			
		EXECUTE PROCEDURE bdisolic:situacion_pago_banco_cjunk(p_empresa,pnumcte,p_producto,psucursal,pejecutivo,0,'0')
			INTO vCodRedSptb2,vMensajeSptb2,vTipoPerSptb2,vnumcteRefSpb2,vNombreRef1Spb2,vnumcteRef2Spb2,
				vNombreRef2Spb2,vSexoSpb2,vEdoCivilSpb2,vEdadSpb2,vTipoViviendaSpb2,vPuestoSpb2,vTieneCredSpb2,
				vProfesinSpb2,vTelRef1Spb2,vTelRef2Spb2,vParentescoRef1Spb2,vParentescoRefSpb2,vNumRefCteSpb2;
		
			IF vCodRedSptb2 < 0 THEN
				LET cCodRet = vCodRedSptb2;
				LET vCausasRechazo = "Error al validar Situacion Pago Banco 2";
				RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
			ELIF vCodRedSptb2 > 0 THEN
				LET vSituacionBanco = 1;
				LET cCodRet = vCodRedSptb2;
				LET vCausasRechazo = vMensajeSptb2;
			ELSE
				LET vSituacionBanco = 0;
				LET cCodRet = vCodRedSptb2;
				LET vCausasRechazo = vMensajeSptb2;
			END IF;

		---- Consulta mensaje Maestro 2					
		FOREACH
			EXECUTE PROCEDURE bdinteg:consultacatmensajesmaestro2(2,1,'0','0', pnumcte)
				INTO vCodRetMaes,vnummensajeMaes,vSecuenciamensajeMaes,vMensajeMaes
				
				IF vCodRetMaes < 0 THEN
					LET cCodRet = vCodRetMaes;
					LET vCausasRechazo = "Error al ejecutar consultacatmensajesmaestro2";
					RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
				ELSE
					----- Genera cadena de salida
					IF vCadenaMaestro = '' THEN
						LET vCadenaMaestro = TRIM (vMensajeMaes);
					ELSE
						LET vCadenaMaestro = TRIM (vCadenaMaestro)||' '||TRIM(vMensajeMaes);
					END IF;
				END IF;
		END FOREACH;

		LET vCausasRechazo = TRIM (vCadenaMaestro);
		
	
		EXECUTE PROCEDURE bdinteg:validafechadireccioncte(pnumcte)
			INTO vCodRetVf, vFechaInsertVf;

				IF vCodRetVf < 0 THEN
					LET cCodRet = vCodRetVf;
					LET vCausasRechazo = "Error al ejecutar validafechadireccioncte";
					RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
				END IF;

		---- Valida situacion especial IFE
		EXECUTE PROCEDURE bdisitesp:sp_valsitesp_ife(pnumcte)
			INTO vCodRetSei2,vSitEspSei2;
			
			IF (vCodRetSei2 < 0) THEN
				LET cCodRet = vCodRetSei2;
				LET vCausasRechazo = "Error al validar Situacion IFE 2";
				RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
			ELIF vSitEspSei2 = '109' OR vSitEspSei2 = '62' THEN 
				LET pOfertaProdCred = 1; --- No oferta productos de credito
			ELSE
				LET	pOfertaProdCred = 0;
			END IF;
			

		--- Proceso obtiene productos
		FOREACH
			EXECUTE PROCEDURE bdisolic:sp_obtiene_productos_cjunk_club2(p_empresa, psucursal, pejecutivo, pPuestoEje, pnumcte, pcredCoppel, pPrecalCoppel, vSituacionBanco, pDigiDomicilio, pIdentificacion,pOfertaProdCred)
				INTO vCodRetOfProd,vprod_finalOfProd,vTpSolicitudOfProd,vdescripcionOfProd,vPrioridadOfProd

					IF vCodRetOfProd < 0 THEN
						LET cCodRet = vCodRetOfProd;
						LET vCausasRechazo = 'Error al ejecutar sp_obtiene_productos_cjunk_club2';
						LET vCadenaMaestro = '';
						RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
					ELIF vCodRetOfProd::INTEGER > 0 THEN 
						LET cCodRet = vCodRetOfProd;
						LET vCadenaProductos = '';
						LET vCausasRechazo = 'Error al ejecutar sp_obtiene_productos_cjunk_club2';
						LET vMensaje = 'VALIDAR DATOS DE CLIENTE';
						RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
					ELSE
						----- Genera cadena de salida
						IF vprod_finalOfProd = '6500' THEN
							LET bandera_prod_coppel = 1;
						ELIF vprod_finalOfProd = '6001' THEN
							LET bandera_prod_banco = 1;
						END IF;
					END IF;

		END FOREACH;
		
		---- Validacion para homologar catalogo de retorno
		IF bandera_prod_coppel = 0 AND bandera_prod_banco = 0 THEN
			LET vCadenaProductos = '0000'; --- Ningun Producto
			LET vMensaje = 'NINGUN PRODUCTO';
		ELIF bandera_prod_coppel = 1 AND bandera_prod_banco = 0 THEN
			LET vCadenaProductos = '0001'; --- Solo tarjeta Coppel
			LET vMensaje = 'SOLO TARJETA DEPARTAMENTAL COPPEL';
		ELIF bandera_prod_coppel = 0 AND bandera_prod_banco = 1 THEN
			LET vCadenaProductos = '0002'; --- Solo tarjeta Banco
			LET vMensaje = 'SOLO TARJETA DE CREDITO BANCOPPEL';
		ELIF bandera_prod_coppel = 1 AND bandera_prod_banco = 1 THEN
			LET vCadenaProductos = '0003'; --- Ambos productos se ofertan
			LET vMensaje = 'TARJETA DEPARTAMENTAL COPPEL Y TARJETA DE CREDITO BANCOPPEL';
		END IF;
		
		IF cCodRet::integer = 0 THEN
			LET cCodRet = '00000';
		END IF;
	
		RETURN cCodRet,vCadenaProductos,vMensaje,vCausasRechazo;
	END;
END PROCEDURE

