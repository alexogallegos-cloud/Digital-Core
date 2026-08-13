CREATE PROCEDURE "informix".sp_tipospagosdom(iRegOmitidos SMALLINT)
RETURNING	CHAR (6)AS Retorno,		--CODIGO DE RETORNO
			CHAR (1)AS Clave ,		--CLAVE A DOMICILIAR
			CHAR (40)AS Descripcion;				
--DECLARACION DE VARIABLES
	DEFINE sql_err        	 		INTEGER;
	DEFINE cCodret         			CHAR(6);
	DEFINE cClave					CHAR(1)	;
	DEFINE cDescripcion				CHAR(40);
	
--Inicializar Variables
	LET sql_err            			= 0;
	LET cCodret            			= '00000';
	LET cClave						= '';
	LET cDescripcion       			= '';
	
 	--SET debug FILE TO "/tmp/ sp_tipospagosdom.out";
        --Trace ON;
       
	BEGIN 
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, cClave, cDescripcion; --Regresa Resultados
				END IF;
			END EXCEPTION; 
			
			SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP iRegOmitidos cve_domiciliar_tc, descripcion 
			INTO cClave, cDescripcion
			FROM bdidomi:dom_cat_imptc
			
			RETURN  cCodret, cClave, cDescripcion WITH RESUME; --Regresa Resultados
		END FOREACH;
				
	END
END PROCEDURE
DOCUMENT
'Autor		: Armida Pazos',
'Descripción: Carga el tipo de pago domiciliado.',
'Fecha		: 2010/02/03',
'Versón		: 20100203.0850',
'BD         : bdidomi';

CREATE PROCEDURE "informix".sp_autorizacionesdomi(p_sNumCte CHAR(20), p_sRegistros SMALLINT)

	RETURNING CHAR(5) AS retorno, CHAR (20) AS cuenta, CHAR(13) AS rfc, CHAR (20) AS num_cte, CHAR(2) AS cve_canal, MONEY (16,2) AS imp_maximo,
		      CHAR (2) AS cve_estatus, DATE AS fecha_estatus, CHAR(20) AS descripcion, CHAR(60) AS razon_social,
			  CHAR(18) AS cuenta_clabe, CHAR(4) AS cod_grupo_act, CHAR(4) AS cod_grupo_des, CHAR(4) AS cod_grupo_react, CHAR(20) AS cuenta_cargo, 
			  CHAR(1) AS cve_domiciliar_tc, MONEY(16,2) AS imp_fijo_tc;
	--Declaracion de  Variables
	DEFINE v_sCodRet					CHAR(5);
	DEFINE sql_err 						INTEGER;
	DEFINE v_sCuenta					CHAR(20);
	DEFINE v_sRfc 						CHAR(13);
	DEFINE v_sNumCte 					CHAR(20);
	DEFINE v_sCveCanal 					CHAR(2);
	DEFINE v_mImpMaximo 				MONEY(16,2);	
	DEFINE v_sCveEstatus 				CHAR(2);
	DEFINE v_dFechaEstatus 				DATE;	
	DEFINE v_sDescripcion 				CHAR(20);
	DEFINE v_sRazonSoc					CHAR(60);
	DEFINE v_sCuentaClabe				CHAR(18);	
	DEFINE v_sCodGrupoAct				CHAR(4);
	DEFINE v_sCodGrupoDes				CHAR(4);
	DEFINE v_sCodGrupoReact				CHAR(4);	
	
	DEFINE v_sCta_Cargo				    CHAR(20);	
	DEFINE v_sTipoPago				    CHAR(1);	
	DEFINE v_dImporte				    MONEY(16,2);	
	
	LET sql_err = 0;
	LET v_sCuenta = '';
	LET v_sRfc = '';
	LET v_sNumCte = '';
	LET v_sCveCanal = '';
	LET v_mImpMaximo = 0.00;
	LET v_sCveEstatus = '';
	LET v_dFechaEstatus = '01-01-1900';
	LET v_sDescripcion = '';
	LET v_sRazonSoc	 = '';
	LET v_sCuentaClabe = '';	
	LET v_sCodGrupoAct = '';
	LET v_sCodGrupoDes = '';
	LET v_sCodGrupoReact = '';
	LET v_sCta_Cargo = '';	
	LET v_sTipoPago	= '';	
	LET v_dImporte = '';
	
	--***************************************************************************************
	--	SET DEBUG FILE TO "/tmp/sp_autorizacionesdomi.out";
	--	TRACE ON; 
	--***************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte;
			END IF;
		END EXCEPTION;
		
		IF NVL(p_sNumCte, '') = '' THEN
			LET v_sCodRet = '00110';
			RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte;
		END IF	
		
		FOREACH 			
			SELECT SKIP p_sRegistros a.cuenta, a.rfc, a.num_cte, a.cve_canal, a.imp_maximo, a.cve_estatus, a.fecha_estatus, b.descripcion, 
			c.razon_social, c.cod_grupo_act, c.cod_grupo_des, c.cod_grupo_react, nvl (a.cuenta_cargo,''), nvl(a.cve_domiciliar_tc,''), nvl(a.imp_fijo_tc,0.00)				
			INTO v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, 
			v_sRazonSoc, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte
			FROM bdidomi:dom_autorizaciones a 			
			INNER JOIN bdidomi:dom_cat_estatusaut b ON(a.cve_estatus = b.cve_estatus)
			INNER JOIN bdidomi:dom_cat_servicios c ON(a.rfc = c.rfc)									
			WHERE a.num_cte = p_sNumCte
							
			SELECT cuenta_clabe INTO v_sCuentaClabe FROM bdicheq:sc_maechq WHERE cuenta = v_sCuenta;			
						
			LET v_sCodRet = '00000';
			
			RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT
'AUTOR      : Noel Gerardo',
'DESCRIPCION: Consulta las autorizaciones de domiciliación.',
'FECHA      : 20/07/2009',
'VERSION    : 20090720.1200',
'BD         : BDIDOMI',
'CASO DE USO: Caso de uso asociado PCU-Domciliacion\CU-0002-AutorizarDomiciliacion-SPL',
'MODIFICADO : Fabiola Corrales 09/Oct/2009. Se modificar para corregir las consultas y optimizar el código',
'MODIFICADO : Dulce Ramirez 04/08/2010. Se modifica para que tambien regrese v_sCta_Cargo, v_sTipoPago, v_dImporte';

CREATE PROCEDURE "informix".sp_autorizacionesdomi_cred(p_sNumCte CHAR(20), p_sRegistros SMALLINT)

	RETURNING CHAR(5) AS retorno, CHAR (20) AS cuenta, CHAR(13) AS rfc, CHAR (20) AS num_cte, CHAR(2) AS cve_canal, MONEY (16,2) AS imp_maximo,
		      CHAR (2) AS cve_estatus, DATE AS fecha_estatus, CHAR(20) AS descripcion, CHAR(60) AS razon_social,
			  CHAR(18) AS cuenta_clabe, CHAR(4) AS cod_grupo_act, CHAR(4) AS cod_grupo_des, CHAR(4) AS cod_grupo_react, CHAR(20) AS cuenta_cargo, 
			  CHAR(1) AS cve_domiciliar_tc, MONEY(16,2) AS imp_fijo_tc;
	--Declaracion de  Variables
	DEFINE v_sCodRet					CHAR(5);
	DEFINE sql_err 						INTEGER;
	DEFINE v_sCuenta					CHAR(20);
	DEFINE v_sRfc 						CHAR(13);
	DEFINE v_sNumCte 					CHAR(20);
	DEFINE v_sCveCanal 					CHAR(2);
	DEFINE v_mImpMaximo 				MONEY(16,2);	
	DEFINE v_sCveEstatus 				CHAR(2);
	DEFINE v_dFechaEstatus 				DATE;	
	DEFINE v_sDescripcion 				CHAR(20);
	DEFINE v_sRazonSoc					CHAR(60);
	DEFINE v_sCuentaClabe				CHAR(18);	
	DEFINE v_sCodGrupoAct				CHAR(4);
	DEFINE v_sCodGrupoDes				CHAR(4);
	DEFINE v_sCodGrupoReact				CHAR(4);	
	
	DEFINE v_sCta_Cargo				    CHAR(20);	
	DEFINE v_sTipoPago				    CHAR(1);	
	DEFINE v_dImporte				    MONEY(16,2);	
	
	LET sql_err = 0;
	LET v_sCuenta = '';
	LET v_sRfc = '';
	LET v_sNumCte = '';
	LET v_sCveCanal = '';
	LET v_mImpMaximo = 0.00;
	LET v_sCveEstatus = '';
	LET v_dFechaEstatus = '01-01-1900';
	LET v_sDescripcion = '';
	LET v_sRazonSoc	 = '';
	LET v_sCuentaClabe = '';	
	LET v_sCodGrupoAct = '';
	LET v_sCodGrupoDes = '';
	LET v_sCodGrupoReact = '';
	LET v_sCta_Cargo = '';	
	LET v_sTipoPago	= '';	
	LET v_dImporte = '';
	
	--***************************************************************************************
	--	SET DEBUG FILE TO "/tmp/sp_autorizacionesdomi.out";
	--	TRACE ON; 
	--***************************************************************************************
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte;
			END IF;
		END EXCEPTION;
		
		IF NVL(p_sNumCte, '') = '' THEN
			LET v_sCodRet = '00110';
			RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte;
		END IF	
		
		FOREACH 			
			SELECT SKIP p_sRegistros a.cuenta, a.rfc, a.num_cte, a.cve_canal, a.imp_maximo, a.cve_estatus, a.fecha_estatus, b.descripcion, 
			c.razon_social, c.cod_grupo_act, c.cod_grupo_des, c.cod_grupo_react, nvl (a.cuenta_cargo,''), nvl(a.cve_domiciliar_tc,''), nvl(a.imp_fijo_tc,0.00)				
			INTO v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, 
			v_sRazonSoc, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte
			FROM bdidomi:dom_autorizaciones a 			
			INNER JOIN bdidomi:dom_cat_estatusaut b ON(a.cve_estatus = b.cve_estatus)
			INNER JOIN bdidomi:dom_cat_servicios c ON(a.rfc = c.rfc)									
			WHERE a.num_cte = p_sNumCte and a.cve_domiciliar_tc is not null 
							
			SELECT cuenta_clabe INTO v_sCuentaClabe FROM bdicheq:sc_maechq WHERE cuenta = v_sCuenta;			
						
			LET v_sCodRet = '00000';
			
			RETURN v_sCodRet, v_sCuenta, v_sRfc, v_sNumCte, v_sCveCanal, v_mImpMaximo, v_sCveEstatus, v_dFechaEstatus, v_sDescripcion, v_sRazonSoc,
			       v_sCuentaClabe, v_sCodGrupoAct, v_sCodGrupoDes, v_sCodGrupoReact, v_sCta_Cargo, v_sTipoPago, v_dImporte WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT
'AUTOR      : Noel Gerardo',
'DESCRIPCION: Consulta las autorizaciones de domiciliación.',
'FECHA      : 20/07/2009',
'VERSION    : 20090720.1200',
'BD         : BDIDOMI',
'CASO DE USO: Caso de uso asociado PCU-Domciliacion\CU-0002-AutorizarDomiciliacion-SPL',
'MODIFICADO : Fabiola Corrales 09/Oct/2009. Se modificar para corregir las consultas y optimizar el código',
'MODIFICADO : Dulce Ramirez 04/08/2010. Se modifica para que tambien regrese v_sCta_Cargo, v_sTipoPago, v_dImporte';

CREATE PROCEDURE "informix".sp_modificaserviciodomi(p_sCveCanal CHAR(2), p_sNumCte CHAR(20), p_sNumCta CHAR(20), p_sRfc CHAR(18),p_mImpMaximo MONEY(16,2),
										p_sCveEstatus CHAR(2), p_sUserEstatus CHAR(8))
	RETURNING CHAR(5);

	DEFINE v_sCodRet 		CHAR(5);
	DEFINE v_cGrupo 		CHAR(4);
	DEFINE sql_err 			INTEGER;
	DEFINE v_dFechaInsert 	DATE;

	--*********************************************************************************************************************************
	--	SET DEBUG FILE TO "/tmp/sp_modificaserviciodomi.out";
	--	TRACE ON;
	--*********************************************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet;
			END IF;
		END EXCEPTION;

		IF NVL(p_sCveCanal,'') = '' OR NVL(p_sNumCte,'') = '' OR NVL(p_sNumCta,'') = '' OR NVL(p_sRfc,'') = '' OR NVL(p_mImpMaximo,'') = ''
		OR NVL(p_sCveEstatus,'') = '' OR NVL(p_sUserEstatus,'') = '' THEN
			LET v_sCodRet = '00110';
			RETURN v_sCodRet;
		END IF;

		LET v_sCodRet = '00001';
		LET v_cGrupo = '0100';
		LET v_dFechaInsert = CURRENT::DATE;

--		IF EXISTS (SELECT 1 FROM bdidomi:dom_autorizaciones WHERE cuenta = p_sNumCta AND rfc = p_sRfc AND cve_canal = p_sCveCanal
--		AND num_cte = p_sNumCte) THEN

			IF p_sCveEstatus = '02' THEN
				UPDATE bdidomi:dom_autorizaciones
				SET imp_maximo = p_mImpMaximo,
				cve_estatus = p_sCveEstatus,
				user_estatus = p_sUserEstatus,
				fecha_estatus = v_dFechaInsert,
				cve_causa = '02',
                		cuenta = 'C' || cuenta
				WHERE cve_canal = p_sCveCanal AND num_cte = p_sNumCte AND cuenta = p_sNumCta AND rfc = p_sRfc;
				
				SELECT cod_grupo_act INTO v_cGrupo FROM dom_cat_servicios where rfc = p_sRfc;
				if v_cGrupo IS NULL THEN
				else
				  UPDATE bdidigital@coppelimg_tcp:dg_expediente 
				  SET cuenta = 'C' || cuenta
				  WHERE cliente = p_sNumCte AND cuenta = p_sNumCta AND producto = v_cGrupo;
				end if;
			ELSE
				UPDATE bdidomi:dom_autorizaciones
				SET imp_maximo = p_mImpMaximo,
				cve_estatus = p_sCveEstatus,
				user_estatus = p_sUserEstatus,
				fecha_estatus = v_dFechaInsert
				WHERE cve_canal = p_sCveCanal AND num_cte = p_sNumCte AND cuenta = p_sNumCta AND rfc = p_sRfc;
			END IF

			LET v_sCodRet = '00000';
--		ELSE
--			LET v_sCodRet = '00002';
--		END IF;

		RETURN v_sCodRet;
	END
END PROCEDURE
DOCUMENT
'AUTOR      : Noel Gerardo',
'DESCRIPCION: Descripción: Modifica el monto maximo autorizado y el esatus de la tabla dom_autorizaciones',
'FECHA      : 21/jul/2009',
'VERSION    : 20090721.1200, 20091008.1020',
'BD         : BDIDOMI',
'CASO DE USO: Caso de uso asociado PCU-Domciliacion\CU-0010-ModificarServicioDomi-SPL',
'MODIFiCADO : Fabiola Corrales 08/Oct/2009. Se modifica para que en caso de ser el estatus 02 grabe la causa 02',
'MODIFICADO: Fabiola Corraels 27/Nov/2009 Se modifica el parametro p_sCveCanal para que sea un char(2) y el parametro p_sRfc a char(18)';

CREATE PROCEDURE "informix".sp_validaserviciosctedomi (pCuenta CHAR (20), --Cuenta
		                                               pRfc CHAR (18),    --RFC
			                                           pNum_cte CHAR (20))--Numero de Cliente
	Returning CHAR(5) --Codigo de retorno

	--Declaracion de  Variables
	DEFINE sql_err INTEGER;
	DEFINE cCodret CHAR(5);
	DEFINE dFecha DATE;
	--Inicializo Variables
	LET sql_err = 0;
	LET cCodret = "00000";
	LET dFecha= CURRENT::DATE;
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodret = sql_err;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_ValidaServicosCteDomi.out";
		--TRACE ON;
		--Valida parametros de entrada
                IF pCuenta IS NULL OR pCuenta = "" OR
			pRfc IS NULL OR pRfc = "" OR
			pNum_cte IS NULL OR pNum_cte = ""  THEN
			LET cCodret="00110"; --Problema con los parametros
			RETURN cCodret;
		END IF;
		IF  EXISTS (SELECT 1 FROM  bdidomi:dom_autorizaciones
		            WHERE num_cte=pNum_cte
		            AND cuenta=pCuenta
			    AND rfc= pRfc
                AND cve_estatus = '01') THEN
		    let  cCodRet= '00012'; --El cliente ya tiene activado el servicio, con esa cuenta
		END IF
		RETURN cCodret;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Se encarga de validar si el cliente ya tiene dado de alta un servicio de domiciliacion',
'FECHA      : 20/07/2009',
'VERSION    : 200907',
'BD         : BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_generaarchivoproveedor(pUser_insert CHAR(8))
	RETURNING CHAR(5);

---- VARIABLES  GENERALES---
DEFINE cSqlerr		INTEGER;
DEFINE cCodret     CHAR(5);
DEFINE dFecha 		DATE;
DEFINE dFechaHabil DATE;
DEFINE dFechaHabil1 DATE;
DEFINE dFechaLimite DATE;
DEFINE dFechaHabilAntes DATE;
DEFINE cNombre_arch_cte CHAR(20);
DEFINE cNum_cte CHAR(20);
DEFINE cConsecutivo CHAR(2);
DEFINE cConsecutivo_nombre CHAR(2);
DEFINE mImporteMaximoPermitido MONEY(16,2);
DEFINE cCuenta  CHAR(20);
DEFINE cTipo_cuenta_cargo CHAR(2);
DEFINE cCuenta_cargo  CHAR(20);
DEFINE cCve_banco_cargo CHAR(3);
DEFINE cRfc CHAR(18);
DEFINE mSdo_pagar MONEY(15,2);
DEFINE mInteres_pago_total_tc  MONEY(15,2);
DEFINE cNum_credito  CHAR(20);
DEFINE dFecha_corte  DATE;
DEFINE cCve_domiciliar_tc CHAR(1);
DEFINE mImp_fijo_tc MONEY(15,2);
DEFINE mImp_Maximo MONEY(15,2);
DEFINE mSumaImportes MONEY(15,2);
DEFINE cNum_operaciones CHAR(8);
DEFINE cFecha CHAR(8);
DEFINE cNombre_cargo CHAR(40);
DEFINE cRfc_cargo CHAR(18);
DEFINE mImp_operacion  MONEY(15,2);
DEFINE iDiaFechaLimitePago INTEGER;
DEFINE iDiasHabilesAntesFechaLimite INTEGER;
DEFINE cBandera CHAR(1);
DEFINE cStatus_Cred CHAR(2);
DEFINE iContador INTEGER;
DEFINE cNum_Producto CHAR(4);
DEFINE cNumCte CHAR(20);
DEFINE cImporte INT8;
DEFINE cCve_Proceso CHAR(20);
DEFINE cEstatus CHAR(1);
DEFINE iMenosDias INTEGER;
DEFINE cTipoCtaAbono CHAR(2);


---- INICIALIZAR VARIABLES  ----
LET cSqlerr		= 0;
LET cCodret     = '00000';
LET dFecha = CURRENT;
LET mImporteMaximoPermitido = 0.00;
LET cCuenta = '';
LET cTipo_cuenta_cargo = '';
LET cCuenta_cargo = '';
LET cCve_banco_cargo = '';
LET cRfc = '';
LET cNum_credito = '';
LET dFecha_corte = CURRENT;
LET cCve_domiciliar_tc = '';
LET mImp_fijo_tc = 0.00;
LET cNum_operaciones = '';
LET cConsecutivo = 1;
LET cFecha = '';
LET cNombre_cargo = '';
LET cRfc_cargo = '';
LET mImp_operacion = 0.00;
LET mSumaImportes = 0.00;
LET mSdo_pagar = 0.00;
LET mInteres_pago_total_tc = 0.00;
LET mImp_Maximo = 0.00;
LET cConsecutivo_nombre = 0;
LET iDiaFechaLimitePago = 0;
LET iDiasHabilesAntesFechaLimite = 0;
LET dFechaHabil = CURRENT;
LET dFechaHabil1 = '';
LET dFechaLimite = CURRENT;
LET dFechaHabilAntes = CURRENT;
LET cBandera = 'N';
LET iContador = 0;
LET cNombre_arch_cte = '';
LET cNum_cte = '';
LET cStatus_Cred = '';
LET cNum_Producto = '';
LET cNumCte = '';
LET cImporte = 0;
LET cCve_Proceso = 'GENARCHPROV_TC';
LET cEstatus = '';
LET iMenosDias = 0;
LET cTipoCtaAbono = '03';

	--SET debug FILE TO "/tmp/domi/sp_domi_generaarchivoproveedor.out";
	--TRACE ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
			DELETE  FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombre_arch_cte;
			DELETE  FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombre_arch_cte;
			DELETE  FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombre_arch_cte;
			DELETE  FROM bdidomi:dom_cte_archivos WHERE nombre_arch = cNombre_arch_cte;
            RETURN cCodret;
        END IF;
    END EXCEPTION;
	--- Obtener la fecha hoy
	SELECT fecha_hoy INTO dFecha FROM bdicheq:sc_fechas WHERE empresa = '001';
	LET cFecha = YEAR(dFecha) || LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(dFecha),2,'0');
	--Se obtiene el numero de cliente parametrizado
	SELECT TRIM(valor) INTO cNum_cte FROM bdidomi:dom_parametros WHERE cod_param = '36';
	--Se obtiene el importe maximo permitido para el servicio de domiciliacion
	SELECT valor INTO mImporteMaximoPermitido FROM bdidomi:dom_parametros WHERE cod_param = '10';
	--Se obtienen los dias habiles antes a la fecha limite de pago
	SELECT valor INTO iDiasHabilesAntesFechaLimite FROM bdidomi:dom_parametros WHERE cod_param = '40';
	--Se obtiene el dia de la fecha limite de pago
	SELECT valor INTO iDiaFechaLimitePago FROM bdidomi:dom_parametros WHERE cod_param = '41';
	--Se valida si la fecha hoy es igual a n(parametro) dias habiles antes de la fehc limite
	LET dFechaHabil = LPAD(MONTH(dFecha),2,'0') || LPAD(DAY(iDiaFechaLimitePago),2,'0') || YEAR(dFecha);
	--Se obtiene el rfc de el servicio de pago de TC BANCOPPEL
	SELECT rfc INTO cRfc FROM bdidomi:dom_cat_servicios WHERE num_cte = cNum_cte;
	--Se obtiene el consecutivo
	SELECT NVL(MAX( SUBSTR(nombre_arch,19,2)),'00') + 1 INTO cConsecutivo_nombre FROM bdidomi:dom_cte_archivos WHERE fecha_insert = dFecha AND num_cte = LPAD(cNum_cte,20,'0') ;
	--Formar el nombre del archivo del proveedor
	LET cNombre_arch_cte = 'E' || SUBSTR(LPAD(TRIM(cNum_cte),20,'0'),12,9) || 'D' || LPAD(DAY(dFecha),2,'0') || LPAD(MONTH(dFecha),2,'0') || SUBSTR(YEAR(dFecha),3,2) || '.' || LPAD(TRIM(cConsecutivo_nombre),2,'0');
	-- Se verifica si ya se ejecuto el proceso
	IF  EXISTS( SELECT cve_proceso FROM dom_procesos WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha)THEN
		SELECT estatus INTO cEstatus FROM dom_procesos WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha;
		IF cEstatus = 1 THEN -- Ya se ejecuto el proceso
			-- El proceso ya se ejecuto
			LET cCodret = '00004';
			RETURN cCodret;
		ELSE -- Se esta ejecutando o -- Termino con error
			UPDATE dom_procesos SET estatus = '0', cod_retorno = cCodret
			WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha ;
		END IF;
	ELSE-- crea el registro en la procesos
		INSERT INTO dom_procesos (tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus, cod_retorno, user_insert , fecha_insert)
		VALUES ('M', dFecha, cCve_Proceso, 'Generando Archivo.','0', cCodret, pUser_insert ,dFecha );
	END IF;
	--Se limpian las tablas
	DELETE  FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombre_arch_cte;
	DELETE  FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombre_arch_cte;
	DELETE  FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombre_arch_cte;
	DELETE  FROM bdidomi:dom_cte_archivos WHERE nombre_arch = cNombre_arch_cte;
	--Se valida si se obtuvieron todos los parametros
	IF (cNum_cte = '' OR cNum_cte IS NULL OR mImporteMaximoPermitido  = '' OR mImporteMaximoPermitido IS NULL OR iDiasHabilesAntesFechaLimite = ''
		OR iDiasHabilesAntesFechaLimite IS NULL OR iDiaFechaLimitePago  = '' OR iDiaFechaLimitePago IS NULL OR cRfc = '' OR cRfc IS NULL ) THEN
		--No estan todos los parametros requeridos
		LET cCodret = '00001';
		UPDATE dom_procesos SET estatus = '3', cod_retorno = cCodret
		WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha ;
		RETURN cCodret;
	END IF;
	
	--A buscar que la fecha limite sea un dia habil
	CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHabil,iDiasHabilesAntesFechaLimite,'V')RETURNING cCodret,dFechaLimite;
		
		IF  cCodret <> '00000' THEN --Se encontro la fecha habil
			LET dFechaHabil = dFechaHabil - 1 UNITS DAY;
			WHILE cCodret <> '00000'
                    CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHabil,0,'V')RETURNING cCodret,dFechaLimite;
					IF cCodret = '00000' THEN
						EXIT WHILE;
					ELSE
						LET dFechaHabil = dFechaHabil - 1 UNITS DAY;
					END IF;
			END WHILE;
			
		END IF;	
	CALL bdidomi:sp_ValFeriadoBanca('001',dFechaLimite,iDiasHabilesAntesFechaLimite,'R')RETURNING cCodret,dFechaHabil;
		IF  cCodret <> '00000' THEN --Se encontro la fecha habil
			LET cCodret = '00005';
			RETURN cCodret;
		END IF;	
	CALL bdidomi:sp_ValFeriadoBanca('001',dFechaHabil,1,'S')RETURNING cCodret,dFechaHabilAntes;
		IF  cCodret <> '00000' THEN --Se encontro la fecha habil
			LET cCodret = '00005';
			RETURN cCodret;
		END IF;				
		
	--Se valida si se procesa hoy
	IF dFechaHabil <> dFecha THEN
		--No se ejecuta el proceso hoy
		LET cCodret = '00002';
		--se borra el registro del proceso para que no acumule registros
		DELETE FROM dom_procesos WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha;
        RETURN cCodret;
	END IF;
	LET cConsecutivo = 1;
	FOREACH
		SELECT cuenta, tipo_cuenta_cargo, cuenta_cargo, cve_banco_cargo, cve_domiciliar_tc, imp_fijo_tc , imp_maximo
		INTO cCuenta, cTipo_cuenta_cargo, cCuenta_cargo, cCve_banco_cargo, cCve_domiciliar_tc, mImp_fijo_tc , mImp_Maximo
		FROM bdidomi:dom_autorizaciones WHERE rfc = cRfc AND cve_estatus = '01'

		SELECT {+INDEX(bdicred:sd_tarjeta idx_tarjeta1)}tar.num_credito, tar.numcte
		INTO cNum_credito,cNumCte
		FROM bdicred:sd_tarjeta tar
		WHERE tar.empresa = '001' AND tar.num_tarjeta = cCuenta ;

		--Se valida si  se obtuvo el numero de credito
		IF (cNum_credito = '' OR cNum_credito IS NULL) THEN
			--No existe la tarjeta o no es permitido o no existe el credito se ingnora el registro
			CONTINUE FOREACH;
		END IF;

		--Se obtiene el numero de credito, el estatus, el nombre y el rfc del titular del credito
		SELECT mae.status_cred, NVL(TRIM(TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)||' '|| TRIM(cte.razon_social)  ),' '), NVL(cte.rfc ,' '),mae.num_producto
		INTO cStatus_Cred, cNombre_cargo, cRfc_cargo,cNum_Producto
		FROM bdicred:sd_maecred mae
		INNER JOIN bdinteg:si_cliente cte ON (mae.numcte = cte.numcte)
		WHERE NOT NVL(mae.id_unidad_prod,0) IN( 2 ,4)
		AND num_credito = cNum_credito;

		--Se valida que se obtenga el estatus, el nombre, rfc y el num producto
		IF (cStatus_Cred = '' OR cStatus_Cred IS NULL OR cNombre_cargo = '' OR cNombre_cargo IS NULL OR
			cRfc_cargo = '' OR cRfc_cargo IS NULL OR cNum_Producto = '' OR cNum_Producto IS NULL ) THEN
			--No existe la tarjeta o no es permitido o no existe el credito se ingnora el registro
			CONTINUE FOREACH;
		END IF;

		-- Se valida que  el producto sea un producto permitido y que exista en la tabla dom_prod_permitidos_tc
		IF NOT EXISTS( SELECT cve_producto FROM bdidomi:dom_prod_permitidos_tc prod WHERE prod.cve_producto = cNum_Producto) THEN
			--la tarjeta no es permitida se ingnora el registro
			CONTINUE FOREACH;
		END IF;

		--Se valida que el estatus del credito no sea cartera vendida
		IF cStatus_Cred = 'CV' THEN
			--el credito es cartera vendida
			UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02',fecha_estatus = dFecha, user_estatus = pUser_insert
			WHERE cuenta =  cCuenta
			AND tipo_cuenta_cargo = cTipo_cuenta_cargo
			AND cuenta_cargo = cCuenta_cargo
			AND cve_banco_cargo = cCve_banco_cargo
			AND cve_domiciliar_tc = cCve_domiciliar_tc
			AND imp_fijo_tc  =  mImp_fijo_tc
			AND imp_maximo = mImp_Maximo
			AND rfc = cRfc;
			CONTINUE FOREACH;
		END IF;

		IF cCve_domiciliar_tc = 'F' THEN
			LET mImp_operacion = mImp_fijo_tc ;
		ELSE
			--Obtener  los importes  del saldo total y pago minimo de la TC
			SELECT sdo_pagar,interes_pago_total_tc
			INTO mSdo_pagar, mInteres_pago_total_tc
			--FROM bdicred:sd_encabezado2_edocta
			FROM bdicred@pld_tcp:sd_encabezado2_edocta
			WHERE num_credito = cNum_credito
			--AND fecha_corte = (SELECT MAX(fecha_corte) FROM bdicred:sd_encabezado2_edocta WHERE num_credito = cNum_credito);
			AND fecha_corte = (SELECT MAX(fecha_corte) FROM bdicred@pld_tcp:sd_encabezado2_edocta WHERE num_credito = cNum_credito);

			--Se obtiene el  Imp_operacion
			IF cCve_domiciliar_tc = 'M' THEN
				LET mImp_operacion = mSdo_pagar ;
			ELIF cCve_domiciliar_tc = 'T' THEN
				LET mImp_operacion = mInteres_pago_total_tc ;
			END IF;
		END IF;
		--Si el saldo a pagar es menor a cero o es mayor al saldo permitido se ignora el registro
		IF mImp_operacion <= 0 OR mImp_operacion IS NULL THEN
			CONTINUE FOREACH;
		END IF;
		--Se valida que el importe de la operacion sea  menor al importe maximo permitido por el cliente
		IF mImp_operacion > mImp_Maximo AND mImp_Maximo > 0 THEN
			LET mImp_operacion = mImp_Maximo;
		END IF;
		-- Se valida que el importe sea menor al ImporteMaximoPermitido por domi
		IF mImp_operacion > mImporteMaximoPermitido THEN
			LET mImp_operacion = mImporteMaximoPermitido;
		END IF;
		LET cImporte = (mImp_operacion * 100 );
		LET dFechaHabilAntes = dFechaHabilAntes;
		--LET dFechaHabil1
		IF cConsecutivo = 1 THEN
			--Genera el insert a la dom_cte_archivos
			INSERT INTO bdidomi:dom_cte_archivos (nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
			VALUES (cNombre_arch_cte, dFecha, LPAD(TRIM(cNum_cte),20,'0'), dFecha, '01', pUser_insert, dFecha);
			-- Genera el insert a la dom_cte_encabezado
			INSERT INTO bdidomi:dom_cte_encabezado (nombre_arch, fecha_envio, tipo_registro, num_cte, cuenta_abono, num_operaciones, fecha_inicial, fecha_final, user_insert, fecha_insert)
			VALUES (cNombre_arch_cte, dFecha, 'E', LPAD(TRIM(cNum_cte),20,'0'), '00000000000000000000', 0, YEAR(dFechaHabilAntes) || LPAD(MONTH(dFechaHabilAntes),2,'0') || LPAD(DAY(dFechaHabilAntes),2,'0'), YEAR(dFechaHabilAntes) || LPAD(MONTH(dFechaHabilAntes),2,'0') || LPAD(DAY(dFechaHabilAntes),2,'0') , pUser_insert, dFecha);
		END IF;
		-- Genera el insert a la dom_cte_detalle
		INSERT INTO bdidomi:dom_cte_detalle (nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono)
		VALUES (cNombre_arch_cte, dFecha, 'D', LPAD(TRIM(cConsecutivo),6,'0'), YEAR(dFechaHabilAntes) || LPAD(MONTH(dFechaHabilAntes),2,'0') || LPAD(DAY(dFechaHabilAntes),2,'0'), YEAR(dFechaLimite) || LPAD(MONTH(dFechaLimite),2,'0') || LPAD(DAY(dFechaLimite),2,'0'), cTipo_cuenta_cargo, cCve_banco_cargo, LPAD(TRIM(cCuenta_cargo),20,'0'), cRfc_cargo, cNombre_cargo, LPAD(TRIM(cCuenta),20,'0'),  LPAD(cImporte ,15,'0'), '000000000000000', LPAD(SUBSTR(cFecha,7,2) || SUBSTR(cFecha,5,2) || SUBSTR(cFecha,3,2),7,'0') , 'CARGO POR DOMICILIACION DE T. CREDITO   ', 'PAGO DE TARJETA DE CREDITO '|| SUBSTR(cFecha,5,2) || '/' || SUBSTR(cFecha,1,4) , cNombre_cargo, 'A', 'S', 'EP', '                                                  ', null, null, null, null, null, null, pUser_insert, dFecha, cTipoCtaAbono);
		LET mSumaImportes = mSumaImportes + mImp_operacion;
		LET cConsecutivo = cConsecutivo + 1;
	END FOREACH;
	LET cConsecutivo = cConsecutivo - 1;
	LET cNum_operaciones = cConsecutivo;
	IF cNum_operaciones <> 0 THEN
		-- Genera el insert a la dom_cte_sumario
		LET cImporte = (mSumaImportes * 100 );
		INSERT INTO bdidomi:dom_cte_sumario (nombre_arch, fecha_envio, tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend, num_oper_apli, imp_oper_apli, num_oper_rech, imp_oper_rech, user_insert, fecha_insert)
		VALUES (cNombre_arch_cte, dFecha, 'S', LPAD(TRIM(cNum_operaciones),8,'0'), LPAD(cImporte ,15,'0') , '00000000', '000000000000000000', '00000000', '000000000000000000', '00000000', '000000000000000000', pUser_insert, dfecha);
		--Se actualiza la tabla de encabezado
		UPDATE bdidomi:dom_cte_encabezado SET num_operaciones = LPAD(TRIM(cNum_operaciones),8,'0') WHERE nombre_arch = cNombre_arch_cte;
		--se aactualiza el proceso como exitoso
		UPDATE dom_procesos SET estatus = '1', cod_retorno = cCodret, descripcion = 'Generacion de archivo exitosa.'
		WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha;
	ELSE
		-- No hay registros de detalle no se genera el archivo
		LET cCodret = '00003';
		UPDATE dom_procesos SET estatus = '3', cod_retorno = cCodret
		WHERE cve_proceso = cCve_Proceso AND fecha_proceso = dFecha;
		RETURN cCodret;
	END IF;
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: 	Este procedimiento es el encargado de generar o simular la generacion del archivo',
' 				proveedor con las tarjetas de credito a domiciliar, este proceso se ejecutara los',
'				n(parametro) dias habiles antes del dia x(parametro) limite a realizar el pago de ',
'				la tarjeta de credito domiciliada.',
'FECHA : 10 de Febrero de 2010',
'Version: 20100220.2300',
'MODIFICO :Antonio Bastidas',
'DESCRIPCION: 	Se agregó la validación sobre la si_feriado_banca, lo cual te indica los',
'				días inhabiles para el banco con el llamado al procedimiento sp_ValFeriadoBanca',
'FECHA : 16 de Abril de 2010',
'Version: 20100422.1303',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_parametroscheques_pba (pEmpresa CHAR(3),pNumEmpleado CHAR(9))

	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2);



	--Declaracion de variables		  

	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosCheques.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet= '00000';
	LET cLongitudCliente= '';
	LET cCodMonNac= '';
	LET cPathRep= '';
	LET cNombreUsuario= '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
			END IF;
		END EXCEPTION;

		--Obtengo el valor longitud del numero de cliente		
		SELECT Trim(valor)
		INTO cLongitudCliente 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 

		--Obtengo el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND descripcion = ('codigo mn');

		 --Obtengo el valor path de reportes
		SELECT Trim(valor) 
		INTO cPathRep
		FROM sc_param 
		WHERE empresa = pEmpresa AND codparam = ('path_rpt');
		
		--Obtengo el nombre del usuario o ejecutivo
		SELECT nombre 
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;

		-- Obtengo el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas 
		WHERE empresa = pEmpresa;

		-- Obtengo Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy 
		INTO dFecha_Hoy
		FROM bdicheq:sc_fechas;

		--Obtengo codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema 
		WHERE siglas = 'SI';

		RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;

	
	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema', 
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
	'Solicito : Armando Mercado',	
	'AUTOR: Yeimi Adelaida Valdez Haro ',
	'FECHA: Abril 2009',
	'VERSION: 200904',
	'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_parametrosdomi_pba(pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2);

	--Declaracion de variables		  
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cLongitudCuenta		char(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosDomi.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet = '00000';
	LET cLongitudCliente = '';
	LET cLongitudCuenta = '';
	LET cCodMonNac = '';
	LET cPathRep = '';
	LET cNombreUsuario = '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
			END IF;
		END EXCEPTION;
		
		--Se validan parametros de entrada
		IF ((pEmpresa = "") OR (pEmpresa IS NULL)) THEN
			LET cCodRet = '02612'; --Viene blanco o nulo el parametro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		IF ((pNumEmpleado = "") OR (pNumEmpleado IS NULL)) THEN
			LET cCodRet = '02612'; --Viene en blanco o nulo el parametros de numero de empleado.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		IF LENGTH(pEmpresa)<> 3 Then
			LET cCodRet = '02612'; --No tiene la longitud correcta el paramtro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;

		If LENGTH(pNumEmpleado)<> 8 Then
			LET cCodRet = '02612'; --No tiene la longitud correcta el paramtro de codigo de empresa.
			RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;		
		END IF;
						
		--Obtiene el valor longitud del numero de cliente		
		SELECT Trim(valor)
		INTO cLongitudCliente 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND cod_param = 7; 

		--Obtiene longitud de cuenta cheques
		SELECT Trim(valor)
		INTO cLongitudCuenta 
		FROM bdicheq:sc_param 
		WHERE empresa = pEmpresa AND codparam = 'longcta'; 

		--Obtiene el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac 
		FROM bdinteg:si_param 
		WHERE empresa = pEmpresa AND cod_param = '15';

		 --Obtiene el valor path de reportes
		SELECT Trim(valor) 
		INTO cPathRep
		FROM bdidomi:dom_parametros 
		WHERE cod_param = '33';

		--Obtiene el nombre del usuario o ejecutivo
		SELECT nombre 
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;
		 
		-- Obtiene el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas 
		WHERE empresa = pEmpresa;
		 
		-- OObtiene Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy 
		INTO dFecha_Hoy
		FROM bdicheq:sc_fechas;

		--OObtiene codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema 
		WHERE siglas = 'DP';
		
		RETURN cCodRet,cLongitudCliente,cLongitudCuenta,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
		
	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema, dom_parametros', 
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',	
	'AUTOR: Abigail Vasavilbazo Cañedo ',
	'FECHA: Septiembre 2009',
	'VERSION: 20090901.1114',
	'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_conciliacontable_pba(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini Char(10), pfecfin Char(10))
RETURNING 
    Char(5),       -- 00.- Codigo de Retorno	
    Date,          -- 01.- Fecha Presentacion
	Integer,       --02.- Cantidad de Registros Archivo Origuinal
	Money(18,2),   --03.- Sumatoria de Reguistros Archivo Origuinal
	Integer,       --04.- Cantidad de Registros Archivo Respuesta1
	Money(18,2),   --05.- Sumatoria de Reguistros Archivo Respuesta1
	Integer,       --06.- Cantidad de Registros Archivo Respuesta2 
	Money(18,2),   --07.- Sumatoria de Reguistros Archivo Respuesta2
	Char(14),      --08.- Cuenta Contable Cargos
	Money(18,2),   --09.- Sumatoria Cuenta Contable Cargos
	Char(14),      --10.- Cuenta Contable Cargos Deudora
	Money(18,2),   --11.- Sumatoria Cuenta Contable Cargos Deudora
	Char(14),      --12.- Cuenta Contable Abonos
	Money(18,2);   --13.- Sumatoria Cuenta Contable Abonos
    

-- Declaracion de Variables
Define iSQLerr                          Integer;
Define cCodRet                          Char(5);
Define cCodRet2                         Char(5);
Define cDescError                       Char(95);

Define dFechaPresentacion               Date;
Define iContRegOriginal                 Integer;
Define mSumRegOriguinal                 Money(18,2);
Define iContRegResp1                    Integer;
Define mSumRegResp1                     Money(18,2);
Define iContRegResp2                    Integer;
Define mSumRegResp2                     Money(18,2);
Define cCuentaContableCargo             Char(14);
Define mSumCuentaContableCargo          Money(18,2);
Define cCuentaContableCargoDeudora      Char(14);
Define mSumCuentaContableCargoDeudora   Money(18,2);
Define cCuentaContableAbono             Char(14);
Define mSumCuentaContableAbono          Money(18,2);
Define cCodParam01                      Char(2);
Define cCodParam02                      Char(2);
Define cCodParam03                      Char(2);
Define dFecha_Presentacion              Date;
Define dFechaHoy                        Date;
Define cTipoP                           Char(1);
Define cCodOperacion                    Char(2);
Define cFecIni                          Char(8);
Define cFecFin                          Char(8);
Define cFecha_Presentacion              Char(8);
Define iTipoOp                          Integer;

ON EXCEPTION SET iSQLerr
    IF iSQLerr <> 0 THEN
        LET cCodRet = iSQLerr; 
        RETURN cCodRet,dFecha_Presentacion,iContRegOriginal,mSumRegOriguinal,iContRegResp1,mSumRegResp1,iContRegResp2,mSumRegResp2,
			   cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableCargoDeudora,mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono,mSumCuentaContableAbono;   
	END IF
END EXCEPTION;

--Inicializacion de Variables
Let iSQLerr       					 = 0;
Let cCodRet        					 = '00000';
Let cCodRet2       					 = '00000';
Let cDescError     					 = '';

Let dFechaPresentacion               = '';
Let iContRegOriginal                 = 0;
Let mSumRegOriguinal                 = 0.00;
Let iContRegResp1                    = 0;
Let mSumRegResp1                     = 0.00;
Let iContRegResp2                    = 0;
Let mSumRegResp2                     = 0.00;
Let cCuentaContableCargo             = '';
Let mSumCuentaContableCargo          = 0.00;
Let cCuentaContableCargoDeudora      = '';
Let mSumCuentaContableCargoDeudora   = 0.00;
Let cCuentaContableAbono             = '';
Let mSumCuentaContableAbono          = 0.00;
Let cCodParam01                      = '';
Let cCodParam02                      = '';
Let cCodParam03                      = '';
Let dFecha_Presentacion              = '';
Let dFechaHoy                        = '';
Let cTipoP                           = '';
Let cCodOperacion                    = '';
Let cFecIni                          = '';
Let cFecFin                          = '';
Let cFecha_Presentacion              = '';
Let iTipoOp                          = 0;

	--SET DEBUG FILE TO "/tmp/sp_domi_ConciliaContable.out";
	--TRACE ON;	

Begin

	--Validacion de Parametros de entrada
	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02612"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02612"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
	END IF;	
	
	If Trim(pNomArchivo) <> "" or pNomArchivo is not null Then
		Select limit 1 cod_operacion 
		Into cCodOperacion		
		From dom_cce_detalle 
		Where nombre_arch = pNomArchivo;
		
		If substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '30' Then 
			Let pTpoProc = 1;
		Elif substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '34' Then 
			Let pTpoProc = 2;
		Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '30' Then 
			Let pTpoProc = 4;
		Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '34' Then 
			Let pTpoProc = 5 ;
		End  if		
	End If
	
    IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
        Let cTipoP = 'E';
		Let cCodOperacion = '30';		
		Let cCodParam01 = '18';
		Let cCodParam02 = '19';
    ELIF pTpoProc = 2 THEN -- REPORTE PRESENTADO
		Let cTipoP = 'E';
		Let cCodOperacion = '34';		
		Let cCodParam01 = '20';
		Let cCodParam02 = '21';
    ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
		Let cTipoP = 'S';
		Let cCodOperacion = '30';		
		Let cCodParam01 = '22';
		Let cCodParam02 = '23';
    ELIF pTpoProc = 5 THEN -- REPORTE RECIBIDO    
		Let cTipoP = 'S';
		Let cCodOperacion = '34';		            
		Let cCodParam01 = '24';
		Let cCodParam02 = '25';
		Let cCodParam03 = '26';		
    ELSE
		LET cCodRet = '02600'; -- OPERACION DESCONOCIDA
		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
    END IF
	
	--Obtengo las cuenta contables para la conciliación
	Select valor Into cCuentaContableCargo 
	From dom_parametros Where cod_param = cCodParam01;
	
	Select valor Into cCuentaContableAbono
	From dom_parametros Where cod_param = cCodParam02;
	
	If cCodParam03 <> '' then 
		Select valor Into cCuentaContableCargoDeudora 
		From dom_parametros Where cod_param = cCodParam03;
	End if

-- SE ELIMINA CONCILIACION CONTABLE	
	--Se validan los parametros obtenidos
--	If length(cCuentaContableCargo) <> 14 then
--		LET cCodRet = '02613'; -- 
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
--	
--	If length(cCuentaContableAbono) <> 14 then
--		LET cCodRet = '02613'; --
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
--	
--	If length(cCuentaContableAbono) <> 14 and cCodParam03 <> '' then
--		LET cCodRet = '02613'; --
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
	
	If pNomArchivo <> "" Then		
		Select fecha_presentacion 
		Into cFecha_Presentacion
		From dom_cce_encabezado		
		Where nombre_arch = pNomArchivo;
		
		--Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
		Let cFecIni = cFecha_Presentacion; 
		Let cFecFin = cFecha_Presentacion;			
	Else
		--Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
		Let cFecIni = substr(pfecini,7,4) || substr(pfecini,1,2) || substr(pfecini,4,2); 
		Let cFecFin = substr(pfecfin,7,4) || substr(pfecfin,1,2) || substr(pfecfin,4,2);	
	End IF	
	
	Let cCodOperacion = cCodOperacion;
	Let cTipoP  =cTipoP; 
	Let cFecIni = cFecIni;
	Let cFecFin = cFecFin;
	
	Foreach with hold
		Select Distinct(fecha_presentacion)
		Into cFecha_Presentacion
		From dom_cce_encabezado
		Where cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And fecha_presentacion Between cFecIni And cFecFin
		
		Let pNomArchivo = pNomArchivo;

		--Obtiene cantidad de reguistros del archivo y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegOriginal, mSumRegOriguinal
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP;
		
		--Obtiene cantidad de reguistros del archivo respuesta 1 y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegResp1, mSumRegResp1
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion 
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And cve_estatus = '02';
		
		--Obtiene cantidad de reguistros del archivo respuesta 2 y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegResp2, mSumRegResp2
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion 
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And cve_estatus = '01';
		
		--Obtengo la fecha de presentacion del archivo mm/dd/yyyy
		Let dFecha_Presentacion = substr(cFecha_Presentacion,5,2) || '/' || substr(cFecha_Presentacion,7,2) || '/' || substr(cFecha_Presentacion,1,4);		

		Select fecha_hoy Into dFechaHoy From bdicheq:sc_fechas;
		
--		If Month(dFecha_Presentacion) = Month(dFechaHoy) then
			
			--Obtengo la sumatoria de los cargos para la cuenta contable de Cargos
--			Select nvl(Sum(cargos_dia),0)
--			Into mSumCuentaContableCargo
--			From bdicont:co_sdodias
--			Where ccmayor = substr(cCuentaContableCargo,1,4)
--			And ccsub = substr(cCuentaContableCargo,5,2)
--			And ccsubsub = substr(cCuentaContableCargo,7,2)
--			And ccssubsub = substr(cCuentaContableCargo,9,2)
--			And ccsssubsub = substr(cCuentaContableCargo,11,2)
--			And sector = substr(cCuentaContableCargo,13,2)
--			And mes_dia = dFecha_Presentacion;
			
			--Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
--			Select nvl(Sum(abonos_dia),0)
--			Into mSumCuentaContableAbono
--			From bdicont:co_sdodias
--			Where ccmayor = substr(cCuentaContableAbono,1,4)
--			And ccsub = substr(cCuentaContableAbono,5,2)
--			And ccsubsub = substr(cCuentaContableAbono,7,2)
--			And ccssubsub = substr(cCuentaContableAbono,9,2)
--			And ccsssubsub = substr(cCuentaContableAbono,11,2)
--			And sector = substr(cCuentaContableAbono,13,2)
--			And mes_dia = dFecha_Presentacion;
			
--			If cCodParam03 <> '' then
--				--Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
--				Select nvl(Sum(abonos_dia),0)
--				Into mSumCuentaContableCargoDeudora
--				From bdicont:co_sdodias
--				Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
--				And ccsub = substr(cCuentaContableCargoDeudora,5,2)
--				And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
--				And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
--				And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
--			And sector = substr(cCuentaContableCargoDeudora,13,2)
--				And mes_dia = dFecha_Presentacion;
--			End IF	

			RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
				   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
				   cCuentaContableCargo, mSumCuentaContableCargo,
				   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
				   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;		   			
--		Else				
--			--Obtengo la sumatoria de los cargos para la cuenta contable de Cargos de Hist
--			Select nvl(Sum(cargos_dia),0)
--			Into mSumCuentaContableCargo
--			From bdicont:co_histsdodias
--			Where ccmayor = substr(cCuentaContableCargo,1,4)
--			And ccsub = substr(cCuentaContableCargo,5,2)
--			And ccsubsub = substr(cCuentaContableCargo,7,2)
--			And ccssubsub = substr(cCuentaContableCargo,9,2)
--			And ccsssubsub = substr(cCuentaContableCargo,11,2)
--			And sector = substr(cCuentaContableCargo,13,2)
--			And mes_dia = dFecha_Presentacion;
			
			--Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
--			Select nvl(Sum(abonos_dia),0)
--			Into mSumCuentaContableAbono
--			From bdicont:co_histsdodias
--			Where ccmayor = substr(cCuentaContableAbono,1,4)
--			And ccsub = substr(cCuentaContableAbono,5,2)
--			And ccsubsub = substr(cCuentaContableAbono,7,2)
--			And ccssubsub = substr(cCuentaContableAbono,9,2)
--			And ccsssubsub = substr(cCuentaContableAbono,11,2)
--			And sector = substr(cCuentaContableAbono,13,2)
--			And mes_dia = dFecha_Presentacion;
			
--			If cCodParam03 <> '' then
				--Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
--				Select nvl(Sum(abonos_dia),0)
--				Into mSumCuentaContableCargoDeudora
--				From bdicont:co_histsdodias
--				Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
--				And ccsub = substr(cCuentaContableCargoDeudora,5,2)
--				And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
--				And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
--				And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
--				And sector = substr(cCuentaContableCargoDeudora,13,2)
--				And mes_dia = dFecha_Presentacion;
--			End IF	

--			RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
--				   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--				   cCuentaContableCargo, mSumCuentaContableCargo,
--				   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--				   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;		   			
--		End IF	
	End Foreach
	
		
End 
End Procedure
DOCUMENT
'AUTOR: Armando Mercado Figueroa',
'Descripcion: Sumatoria por dia segun cuenta contable, las cuentas contables se encuentran parametrizadas',
'Fecha: 2009/09/02',
'Version: 20090902.1246',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_procesararchivo10(pNombreArchivo CHAR(20),pNombreArchivo11 CHAR(20))
	RETURNING CHAR(5);

---Agregar un nombre de archivo 11
---- VARIABLES  GENERALES---
DEFINE  cSqlerr		INTEGER;
DEFINE  cCodret     CHAR(5);
DEFINE  cCodret2     CHAR(5);
DEFINE  cMensaje     CHAR(200);
DEFINE  cCuenta		 CHAR(11);
DEFINE  cStatus		 CHAR(1);
DEFINE  cFisica		 CHAR(2);
DEFINE  cListaProductosPermitidos		 CHAR(100);
DEFINE  cNombreArchivoSAlida CHAR(20);
DEFINE  cProducto CHAR(4);
DEFINE dFecha date;
DEFINE iExiste 		INTEGER;
DEFINE d_Fech_prox DATE;
DEFINE c_Fech_prox CHAR(8);
---- VARIABLES   ---
DEFINE cPrefijoCLABE 	CHAR(6);
DEFINE cPrefijoTarjeta 	CHAR(6);
DEFINE cPrefijoTarjNuevo CHAR(6);
DEFINE cTarjeta_NumCta	CHAR(20);

---- VARIABLES ENCABEZADO -----
DEFINE cNombre_archE CHAR(20);
DEFINE cFecha_presentacionE CHAR(8);
DEFINE cTpo_registro CHAR(2);
DEFINE cNum_secuenciaE CHAR(7);
DEFINE cCod_operacionE CHAR(2);
DEFINE cCve_banco CHAR(3);
DEFINE cSentido CHAR(1);
DEFINE cServicio CHAR(1);
DEFINE cNum_bloque CHAR(7);
DEFINE cCod_divisaE CHAR(2);
DEFINE cCve_rechazo_bl CHAR(2);
DEFINE cModalidad CHAR(1);
DEFINE cUso_futuro_ccenE CHAR(41);
DEFINE cUso_futuro_bancoE CHAR(345);
DEFINE cUser_insertE CHAR(8);
DEFINE dFecha_insertE date;

---- VARIABLES DETALLE -----
DEFINE cNombre_archD CHAR(20);
DEFINE cFecha_presentacionD CHAR(8);
DEFINE cTipo_registro CHAR(2);
DEFINE cNum_secuenciaD CHAR(7);
DEFINE cCod_operacionD CHAR(2);
DEFINE cCod_divisaD CHAR(2);
DEFINE cFecha_trans CHAR(8);
DEFINE cBanco_presentador CHAR(3);
DEFINE cBanco_receptor CHAR(3);
DEFINE cImporte CHAR(15);
DEFINE cUso_futuro_ccenD CHAR(16);
DEFINE cTipo_operacion CHAR(2);
DEFINE cFecha_aplica CHAR(8);
DEFINE cTipo_cta_ord CHAR(2);
DEFINE cNum_cta_ord CHAR(20);
DEFINE cNombre_ord CHAR(40);
DEFINE cRfc_ord CHAR(18);
DEFINE cTipo_cta_rec CHAR(2);
DEFINE cNum_cta_rec CHAR(20);
DEFINE cNombre_rec CHAR(40);
DEFINE cRfc_rec CHAR(18);
DEFINE cRef_servicio CHAR(40);
DEFINE cNombre_titular_serv CHAR(40);
DEFINE cImporte_iva CHAR(15);
DEFINE cRef_numerica CHAR(7);
DEFINE cRef_leyenda CHAR(40);
DEFINE cClave_rastreo CHAR(30);
DEFINE cMotivo_dev CHAR(2);
DEFINE cFecha_pres_ini CHAR(8);
DEFINE cUso_futuro_bancoD CHAR(12);
DEFINE cCve_estatus CHAR(2);
DEFINE cFolio_suc CHAR(16);
DEFINE cUser_insertD CHAR(8);
DEFINE dFecha_insertD DATE;

---- VARIABLES SUMARIO -----
DEFINE cNombre_archS CHAR(20);
DEFINE cFecha_presentacionS CHAR(8);
DEFINE cTipo_registroS CHAR(2);
DEFINE cNum_secuenciaS CHAR(7);
DEFINE cCod_operacionS CHAR(2);
DEFINE cNum_bloqueS CHAR(7);
DEFINE cNum_operaciones CHAR(7);
DEFINE cImp_operaciones CHAR(18);
DEFINE cUso_futuro_ccenS CHAR(40);
DEFINE cUso_futuro_bancoS CHAR(339);
DEFINE cUser_insertS CHAR(8);
DEFINE dFecha_insertS DATE;


DEFINE cFechaSinFormato CHAR(8);
DEFINE cFechaFormateada date;
DEFINE cCodSpFecha CHAR(5);
DEFINE dFechaHabil DATE;
DEFINE iContador INTEGER;
DEFINE cFecha_Hoy DATE;
DEFINE cStatus_tar CHAR(1);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET iContador = 0;
LET cStatus_tar = '';

----INICIALIZAR  VARIABLES ENCABEZADO -----
LET cNombre_archE ='';
LET cProducto = '';
LET cFecha_presentacionE='';
LET cTpo_registro ='';
LET cNum_secuenciaE ='';
LET cCod_operacionE ='';
LET cCve_banco ='';
LET cSentido ='';
LET cServicio ='';
LET cNum_bloque ='';
LET cCod_divisaE ='';
LET cCve_rechazo_bl ='';
LET cModalidad ='';
LET cUso_futuro_ccenE ='';
LET cUso_futuro_bancoE ='';
LET cUser_insertE ='';
LET dFecha_insertE ='';

---INICIALIZAR VARIABLES DETALLE
LET cNombre_archD ='';
LET cFecha_presentacionD ='';
LET cTipo_registro ='';
LET cNum_secuenciaD ='';
LET cCod_operacionD ='';
LET cCod_divisaD ='';
LET cFecha_trans ='';
LET cBanco_presentador ='';
LET cBanco_receptor ='';
LET cImporte ='';
LET cUso_futuro_ccenD ='';
LET cTipo_operacion ='';
LET cFecha_aplica ='';
LET cTipo_cta_ord ='';
LET cNum_cta_ord ='';
LET cNombre_ord ='';
LET cRfc_ord ='';
LET cTipo_cta_rec ='';
LET cNum_cta_rec ='';
LET cNombre_rec ='';
LET cRfc_rec ='';
LET cRef_servicio ='';
LET cNombre_titular_serv ='';
LET cImporte_iva ='';
LET cRef_numerica ='';
LET cRef_leyenda ='';
LET cClave_rastreo ='';
LET cMotivo_dev ='';
LET cFecha_pres_ini ='';
LET cUso_futuro_bancoD ='';
LET cCve_estatus ='';
LET cFolio_suc ='';
LET cUser_insertD ='';
LET dFecha_insertD ='';

----INICIALIZAR VARIABLES SUMARIO -----
LET cNombre_archS='';
LET cFecha_presentacionS ='';
LET cTipo_registroS ='';
LET cNum_secuenciaS ='';
LET cCod_operacionS ='';
LET cNum_bloqueS ='';
LET cNum_operaciones ='';
LET cImp_operaciones ='';
LET cUso_futuro_ccenS ='';
LET cUso_futuro_bancoS ='';
LET cUser_insertS ='';
LET dFecha_insertS ='';
LET iExiste =0;
LET c_Fech_prox = '';

		

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret;
        END IF;
    END EXCEPTION;

	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoTarjeta FROM Dom_Parametros WHERE cod_param = '06';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoTarjNuevo FROM Dom_Parametros WHERE cod_param = '43';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoCLABE FROM Dom_Parametros WHERE cod_param = '05';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT fecha_hoy INTO cFecha_hoy FROM bdicheq:sc_fechas;

	-- VALIDACIONES   EN ORDEN --
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		--Selecciona la cuenta a validar
		SELECT  Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Cod_divisa,
				Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen, Tipo_operacion, Fecha_aplica, Tipo_cta_ord,
				Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec, Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv,
				Importe_iva, Ref_numerica, Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus,
				Folio_suc, User_insert, Fecha_insert
		INTO    cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
				cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica, cTipo_cta_ord,
				cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,
				cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev, cFecha_pres_ini, cUso_futuro_bancoD, cCve_estatus,
				cFolio_suc, cUser_insertD, dFecha_insertD
		FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10'
		LET cTarjeta_NumCta = cNum_cta_rec;
		---- si no entra a ningun error pues se queda el 99 de archivo paso  las validaciones
		-- 6.- VALIDACION DE  Motivo 99 "Cuenta correcta en la verificacion de cuentas" --
		LET cMensaje = 'Cuenta correcta en la verificación de cuentas';
		--Inserto en la de detalle_paso con codigo de operacion 11 almacenar clave 01 en motivo de devolucion
		LET cCod_operacionD = '11';
		LET cImporte = '000000000000000';
		--LET cRef_leyenda = 'Cuenta para Verificar';
		LET cMotivo_dev = '99';

		-- VALIDACIONES   EN ORDEN --
		-- 1.- VALIDACION DE  Motivo 06 "Cuenta no pertenece al Banco Receptor" --
		IF NOT (SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjeta) OR SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjNuevo) OR SUBSTR(cNum_cta_rec,3,3) = TRIM(cPrefijoCLABE)) THEN----si la cuenta es un a  Tarjeta  06      OR    ----si la cuenta es un a  CLABE   07
			--- ERROR MARCAR EL ERROR 06
			LET cMensaje = 'Cuenta no pertenece al banco receptor';
			LET cMotivo_dev = '06';
		END IF;
		---se valida si es tarjeta o cuenta CLABE, si es una tarjeta obtengo la CLABE para usar la cuenta
		IF SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjeta) OR SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjNuevo) AND cMotivo_dev = '99' THEN  --Es una Tarjeta
			--- Si me dan la tarjeta obtengo la  cuenta para hacer una busqueda mas rapida
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16);  --- INDEX (empresa,num_tarjeta)
			IF  (cCuenta = '') THEN
				--marco el error en el registro    --- ERROR MARCAR EL ERROR 01
				LET cMensaje = 'Cuenta inexistente';
				LET cMotivo_dev = '01';
			ELSE
				-- validar que la tarjeta sea la titular
				----  si la tarjeta no es la titular marcar el error de servisio no permitido
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS (SELECT tipo_tarjeta FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16) AND tipo_tarjeta = 'T' AND status_tar = 'A') THEN
					-- VALIDAR SI ESTA EN LA MAESTRO DE CHEQUES
					IF EXISTS (SELECT cuenta_clabe FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = cCuenta)THEN
						--Obtener la cuenta clabe para que funcione el codigo siguiente de la cual se tomara la cuenta del cliente
						SELECT LPAD(cuenta_clabe,20,'0') INTO cNum_cta_rec FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = cCuenta; --- INDEX (empresa, cuenta)
					ELSE
						---la tarjeta no es la titular marcar el error de servicio no permitido
						LET cMensaje = 'Cuenta inexistente';
						LET cMotivo_dev = '01';
					END IF;
				ELSE
					---la tarjeta no es la titular marcar el error de servicio no permitido
					LET cMensaje = 'La tarjeta no es titular';
					LET cMotivo_dev = '02';
					SELECT status_tar INTO cStatus_tar FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16) AND tipo_tarjeta = 'T';
					IF cStatus_tar <> 'A' THEN
						---la tarjeta no es la titular marcar el error de servicio no permitido
						LET cMensaje = 'La tarjeta esta cancelada';
						LET cMotivo_dev = '03';
					END IF;
				END IF;
			END IF;
		END IF;
		---Al final de cada validacion se valida q   cMotivo_dev = '99' para asegurar q si entro aun error de registro ya no entre a otro y regrese el primer ) cMotivo_dev
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF((SUBSTR(cNum_cta_rec,3,3) = TRIM(cPrefijoCLABE)) AND cMotivo_dev = '99') THEN--- Es una cuenta CLABE
			--- SE OBTIENE SI ES UNA PERSONA FISICA
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT cte.tpo_persona INTO cFisica FROM bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
			WHERE mae.cuenta = SUBSTR(cNum_cta_rec,9,11);
			--- SE VALIDA  Q SEA UN PERSONA FISICA
			IF (cFisica <> '01' AND cMotivo_dev = '99')THEN
				--marco el error en el registro  --- PERSONA NO FISICA
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
			--- SE VALIDA Q EL PRODUCTO ESTE  EN LA LISTA DE PRODUCTOS DE LA TABLA PARAMETROS CON LA COD_PARAM = 12
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT valor INTO cListaProductosPermitidos FROM dom_parametros WHERE cod_param = '12';
			--Se obtiene el producto de la cuenta para validar si es un producto permitido
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT producto INTO cProducto FROM bdicheq:sc_maechq ma WHERE ma.empresa = '001' AND ma.cuenta = SUBSTR(cNum_cta_rec,9,11);
			--validar que exista en la lista de productos permitidos
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF NOT( cListaProductosPermitidos LIKE '%'|| cProducto || '%' ) AND cMotivo_dev = '99'  THEN
				--marco el error en el registro  --- El producto no esta en la lista de productos permitidos
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
			-- 2.- VALIDACION DE  Motivo 01 "Cuenta inexistente" --
			IF (NOT EXISTS (SELECT cuenta_clabe FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = SUBSTR(cNum_cta_rec,9,11))) AND cMotivo_dev = '99' THEN  --INDEX EMPRESA  cuenta
				--marco el error en el registro  --- ERROR MARCAR EL ERROR 01
				LET cMensaje = 'Cuenta inexistente';
				LET cMotivo_dev = '01';
			END IF;
			-- 3.- VALIDACION DE  Motivo 02 "Cuenta Bloqueada" --
			-- 4.- VALIDACION DE  Motivo 03 "Cuenta Cancelada" --
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF (EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdicheq:sc_maechq.status_cta IN(2,3) )) AND cMotivo_dev = '99' THEN-- validar que no este bloqueada 2   INDEX  empresa cuenta
				-- SE OBTIENE EL ESTADA PARA VALIDARLO
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT status_cta INTO cStatus FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdicheq:sc_maechq.status_cta IN(2,3);
				-- 3.- VALIDACION DE  Motivo 02 "Cuenta Bloqueada" --
				IF cStatus = '3' THEN
					---Cuenta Bloqueada marcar con 02  --marco el error  en el registro
					LET cMensaje = 'Cuenta Bloqueada';
					LET cMotivo_dev = '02';
				ELIF cStatus = '2' THEN  -- 4.- VALIDACION DE  Motivo 03 "Cuenta Cancelada" --
					--Cuenta Cancelada marcar con 03   --marco el error  en el registro
					LET cMensaje = 'Cuenta Cancelada';
					LET cMotivo_dev = '03';
				END IF;
			END IF;
			-- 5.- VALIDACION DE  Motivo 11 "Cliente no tiene autorizado el Servicio" --
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF( EXISTS (SELECT cuenta FROM bdidomi:dom_autorizaciones  WHERE bdidomi:dom_autorizaciones.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdidomi:dom_autorizaciones.cve_estatus = '02') ) AND cMotivo_dev = '99'THEN
				--Cuenta no Autorizada marcar con 11   --marco el error  en el registro
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
		END IF;
		--Inserto en la de detalle_paso con codigo de operacion 11 almacenar clave  en motivo de devolucion
		LET cFechaFormateada = SUBSTR(cFecha_presentacionD,5,2) ||'/'|| SUBSTR(cFecha_presentacionD,7,2) ||'/'|| SUBSTR(cFecha_presentacionD,1,4);
		--- se obtendra el dia siguente habil para validar las fechas de cFecha_trans y la cFecha_aplica ya que estas deben ser el dia siguiente habil a la fecha cFecha_presentacion
		EXECUTE FUNCTION bdinteg:splvalfecha('001',(cFechaFormateada) + 1 ,0)INTO cCodSpFecha,dFechaHabil; --a qui ya tengo el dias siguiente habil
		--NOTA.- Se agrego la validacion de la fecha dado que se puede presentar el caso que la fecha sea habil para la banca e inabil para el banco.
		--Solicitada por jaime gonzales el dia 15/09/2008
		--Realizada por Alejandro Osuna
        SELECT fecha_prox INTO d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = dFechaHabil;
        IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
           LET dFechaHabil = dFechaHabil;
        ELSE
           LET dFechaHabil = d_Fech_prox;
           LET cFecha_trans = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
           LET cFecha_aplica = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
        END IF;
		-- se manda mes dia año
		LET cFechaSinFormato = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
		--comparacion con tra los fechas   Fecha_trans   cFecha_aplica
		IF NOT (cFecha_trans = cFechaSinFormato AND cFecha_aplica = cFechaSinFormato) THEN
			--Marco el error , Guardar en bitacora y rechazar el archivo por motivo  uno o mas registros de la aplicacion tienen una fecha no valida
			LET cCodRet = '00801';
			RETURN cCodRet;
		END IF;
		---SI EL MOTIVO ES DIFERENTE DE 99 SE ACTUALIZA EL CAMPO CVE_EESTATUS = 02 DELA DETALLE PASO
		IF cMotivo_dev <> '99' THEN
			UPDATE dom_cce_detalle_paso SET dom_cce_detalle_paso.cve_estatus = '02'
			WHERE Nombre_arch = cNombre_archD AND Fecha_presentacion = cFecha_presentacionD
			AND Tipo_registro = cTipo_registro AND Num_secuencia = cNum_secuenciaD AND cod_operacion = '10';
		ELSE
			UPDATE dom_cce_detalle_paso SET dom_cce_detalle_paso.cve_estatus = '01'
			WHERE Nombre_arch = cNombre_archD AND Fecha_presentacion = cFecha_presentacionD
			AND Tipo_registro = cTipo_registro AND Num_secuencia = cNum_secuenciaD AND cod_operacion = '10';
		END IF;
		--Nombrar al archivo de salida para que deje insertar en la tabla de paso
		LET cNombreArchivoSAlida = pNombreArchivo11;
		LET cNum_cta_rec = cTarjeta_NumCta;
		LET cFecha_presentacionD = cFechaSinFormato;

		INSERT INTO dom_cce_detalle_paso(Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion,
							Cod_divisa, Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen,
							Tipo_operacion, Fecha_aplica, Tipo_cta_ord, Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec,
							Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv, Importe_iva, Ref_numerica,
							Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus, Folio_suc,
							User_insert, Fecha_insert)
		Values (cNombreArchivoSalida, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
				cFecha_trans, cBanco_receptor,/* <--Aqui se intercambian los bancos para el 11 -->*/cBanco_presentador , cImporte, cUso_futuro_ccenD,
				cTipo_operacion, cFecha_aplica,cTipo_cta_ord,cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec,
				cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo,
				cMotivo_dev,cFecha_pres_ini, cUso_futuro_bancoD, cCve_estatus, cFolio_suc, cUser_insertD, dFecha_insertD);
		---Contador de los registros de detalle  para una validacion en la parte de abajo
		LET iContador = iContador + 1;
	END FOREACH;
		----Hacer el insert de  encabezado y sumario
		--Selecciona El registro de Encabezado
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT  Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio, Num_bloque,
				Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
		INTO    cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
				cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE
		FROM Dom_cce_encabezado_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10';
		---Llenar la variables q se ban a modificar antes del insert del codigo 11 para la tabla
		LET cTpo_registro = '01';
		LET cNum_secuenciaE = '0000001';
		LET cCod_operacionE = '11';
		LET cSentido = 'E';
		LET cFecha_presentacionE = cFechaSinFormato;
		-- Insertar en encabezado el 11
		LET cNombre_archE = cNombreArchivoSalida;
		--cNum_bloque  al momento de crear el archivo 11 el numero de bloque cambia a DDCCCCCCC  donde CCCCCCC  = 000001
		LET cNum_bloque = LPAD(SUBSTR(cFecha_presentacionE,7,2),2,'0') || LPAD(SUBSTR(pNombreArchivo11,16,2),5,'0');
		INSERT INTO Dom_cce_encabezado_paso( Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio,
		        Num_bloque, Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
		Values( cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
				cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE);

		--Selecciona El registro de Sumario
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque, Num_operaciones,
		       Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
		INTO   cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
		       cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS
		FROM Dom_cce_sumario_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10';

		---Llenar la variables q se ban a modificar antes del insert
		LET cTipo_registroS = '09';
		LET cCod_operacionS = '11';
		IF LPAD(iContador,7,'0') <> cNum_operaciones THEN
			LET cCodRet = '00802';
			--LET cMensaje = 'El Numero de operaciones en sumario no corresponde al numero de detalles';
			RETURN cCodRet;
		END IF;
		-- Insertar en encabezado el 11
		LET cNombre_archS = cNombreArchivoSalida;
		LET cFecha_presentacionS = cFechaSinFormato;
		--cNum_bloque  al momento de crear el archivo 11 el numero de bloque cambia a DDCCCCCCC  donde CCCCCCC  = 000001
		LET cNum_bloqueS = LPAD(SUBSTR(cFecha_presentacionS,7,2),2,'0') || LPAD(SUBSTR(pNombreArchivo11,16,2),5,'0');
		INSERT INTO Dom_cce_sumario_paso( Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque,
		        Num_operaciones, Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
		VALUES( cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
		        cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS);
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de procesar y validar los datos de las cuentas del archivo 10 para generar el 11',
'           : tambien inserta los registros en las tablas de paso de sumario, detalle, encabezado',
'FECHA : Julio de 2009',
'BD    : BDIDOMI',
'VERSION: 20090729';

CREATE PROCEDURE "informix".sp_domi_genrep30_pba(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(20),      -- 11.- Estatus
		 CHAR(60),      -- 12.- Causa Rechazo
		 CHAR(2);       -- 13.- Codigo de Respuesta

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cStatus        CHAR(20);       -- 11
DEFINE cCausaRech     CHAR(60);       -- 12
DEFINE cCodResp       CHAR(2);        -- 13
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_Rastreo CHAR(30);



ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_domi_genrep30.out";
--	TRACE ON;	

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cCodResp       = "";      -- 13
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET iTipoOp        = 0;
LET cClave_Rastreo = "";

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
	
	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 30 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 30 AND LENGTH(pNomArchivo) = 16) THEN
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN 
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
				END IF;
	
				FOREACH WITH HOLD	
				
					SELECT 
						 TRIM(det.fecha_presentacion), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
						 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
						 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
					INTO cFechPresS, cNomOrd, cServ, cRef,
					     cImp, cCtaDest, cSec, cTipoCtaCod, 
						 cBancDestCod, 
						 cStatus, cCausaRech, cStat_val, cClave_Rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status			
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '30'
						LET cCodResp = '';
					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;
					
					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;
								
					IF cStat_val = '01' THEN
						LET cCodResp = '32';
						LET cCausaRech = "";
					ELIF cStat_val = '02' THEN
						LET cCodResp = '31';
					ELIF cStat_val = '03' OR cStat_val = '00' THEN
						LET cCodResp = "";
						LET cCausaRech = "";
					END IF;
					
					IF cCodResp = '31' THEN
						SELECT dev.descripcion 
						INTO cCausaRech
						FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
						WHERE clave_rastreo = cClave_Rastreo
						AND cod_operacion = '31'
						AND det.motivo_dev = dev.motivo_dev;
					END IF;
					
					LET mImp2 = cImp / 100;					
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
					
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;		
			
	ELIF iTipoOp = 1 OR iTipoOp = 4 THEN -- CONSULTA POR NOMBRE DEL PROCESO		
		IF pfecini <> "" AND pfecfin <> "" THEN 
		
			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);
		
			IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';			
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
				
			FOREACH WITH HOLD
			
				SELECT		
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
					 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
					 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
				INTO cFechPresS, cNomArch, cNomOrd, cServ, cRef,
				     cImp, cCtaDest, cSec, cTipoCtaCod, 
					 cBancDestCod, 
					 cStatus, cCausaRech, cStat_val, cClave_Rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc			
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '30'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'
				
				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;
				
				IF cStat_val = '01' THEN
					LET cCodResp = '32';
					LET cCausaRech = "";
				ELIF cStat_val = '02' THEN
					LET cCodResp = '31';
				ELIF cStat_val = '03' OR cStat_val = '00' THEN
					LET cCodResp = "";
					LET cCausaRech = "";
				END IF;
				
				IF cCodResp = '31' THEN
					SELECT dev.descripcion 
					INTO cCausaRech
					FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
					WHERE clave_rastreo = cClave_Rastreo
					AND cod_operacion = '31'
					AND det.motivo_dev = dev.motivo_dev;
				END IF;
				
				LET mImp2 = cImp / 100;				
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
				
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;	
	ELSE
		LET cCodRet = '02608'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 30 - VALORES 1 o 4
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 30, ya sean presentados o recibidos',
'FECHA: 13/08/2009',
'VERSION: 20090813.1730',
'BD: Bdidomi',

'MODIFICO: Cesar Valdez Figueroa',
'DESCRIPCION: para que regresara la descrimcion del codigo 31',
'FECHA: 10/11/2009',
'VERSION: 20091110.1200',
'BD: Bdidomi';

CREATE PROCEDURE "informix".sp_domi_buscararchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(50))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(1); ---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE bBandera				CHAR(1);
	DEFINE sCadSql				LVARCHAR(500);
	DEFINE sLinea				VARCHAR(50);
	
	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret,NULL;
    END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET iSqlErr
		IF iPaso NOT IN (4,5,6) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
	END EXCEPTION WITH RESUME;


	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_BuscarArchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';

	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;
	END IF

	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;
	END IF

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_busca_archivo') THEN
		DROP TABLE dom_tmp_busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_busca_archivo
	(linea LVARCHAR(50));

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus';
	SYSTEM sCadSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus' || ' INSERT INTO dom_tmp_busca_archivo" > '|| TRIM(p_Ruta) || cFechaArchivoOUT|| '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--Produccion
	LET sCadSql = '/ifxsif01/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--Desarrollo
	--LET sCadSql = '/informix/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	SYSTEM sCadSql;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_busca_archivo

		IF sLinea = p_NombreArchivo THEN
			LET bBandera = "V";
			EXIT FOREACH;
		END IF;
	END FOREACH;
	
	LET iPaso = 4;	
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;

	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;	

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.out';
	SYSTEM sCadSql;	
	
	DROP TABLE dom_tmp_busca_archivo;

	RETURN v_cod_ret, bBandera;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_BuscarArchivo
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para buscar un archivo en una ruta proporcionada
--##############################################################################
END PROCEDURE;