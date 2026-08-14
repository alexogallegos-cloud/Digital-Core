CREATE PROCEDURE "informix".sp_consultacuentasnominacliente(pEmpresa CHAR(3), pCliente CHAR(20), pNumRegistros SMALLINT)
RETURNING
	CHAR(5) AS cCodRet,
	CHAR(20) AS cNumCte,
	CHAR(26) AS cApPaterno,
	CHAR(26) AS cApMaterno,
	CHAR(26) AS cNombre1,
	CHAR(26) AS cNombre2,
	CHAR(13) AS cRFC,
    CHAR(20) AS cNumCta,
	CHAR(50) AS cNombre,
	CHAR(19) AS cCuentaClabe,
	CHAR(150) AS cEstatus,
	CHAR(8) AS cFechaSolicitud,
	CHAR(40) AS cInstFinanc,
	CHAR(150) AS cObservaciones,
	CHAR(8) AS cFechaRespSol,
	CHAR(8) AS cFechaNotificacion,
	CHAR(13) AS cRFCEmpresa,
	CHAR(8) AS cFechaCancelacion,
	CHAR(2) AS cEstatusPortabilidad,
	CHAR(1) AS cCveSentido,
	CHAR(5) AS cBcoOrdenante;

	--Declaracion de  Variables
	DEFINE cCodRet				  CHAR (5);
	DEFINE cSqlErr				  SMALLINT;
	DEFINE cCiclo				  SMALLINT;
	DEFINE cNumCte				  CHAR(20);
	DEFINE cApPaterno			  CHAR(26);
	DEFINE cApMaterno			  CHAR(26);
	DEFINE cNombre1				  CHAR(26);
	DEFINE cNombre2				  CHAR(26);
	DEFINE cRFC					  CHAR(13);
	DEFINE cNumCta				  CHAR(20) ;
	DEFINE cNombre				  CHAR(50);
	DEFINE cCuentaClabe			  CHAR(19);
    DEFINE cEstatus				  CHAR(150);
    DEFINE cFechaSolicitud		  CHAR(8);
    DEFINE cInstFinanc			  CHAR(40);
    DEFINE cObservaciones		  CHAR(150);
    DEFINE cFechaRespSol		  CHAR(8);
    DEFINE cFechaNotificacion	  CHAR(8);
    DEFINE cRFCEmpresa			  CHAR(13);
    DEFINE cFechaCancelacion	  CHAR(8);
    DEFINE cEstatusPortabilidad	  CHAR(2);
    DEFINE cCveSentido			  CHAR(1);
    DEFINE cBcoOrdenante		  CHAR(5);
    DEFINE cBcoReceptor			  CHAR(5);
    DEFINE cProducto			  CHAR(4);
    DEFINE cCta_ordenante		  CHAR(20);
    DEFINE cCta_receptora		  CHAR(20);
    DEFINE cClave_origen		  CHAR(1);
    DEFINE cEstatus_respuesta	  CHAR(2);
    DEFINE cEstatus_respuesta_res CHAR(2);
    DEFINE cfolio_solicitud       CHAR(30);

	--Inicializo Variables
	LET cCodRet					= '01285';
	LET cSqlErr					= 0;
	LET cCiclo					= 0;
	LET cNumCte					= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cRFC					= '';
	LET cNumCta					= '';
	LET cNombre					= '';
	LET cEstatus				= '';
	LET cFechaSolicitud			= '';
	LET cInstFinanc				= '';
	LET cObservaciones			= '';
	LET cFechaRespSol			= '';
	LET cFechaNotificacion		= '';
	LET cRFCEmpresa				= '';
	LET cFechaCancelacion		= '';
	LET cCuentaClabe			= '';
	LET cEstatusPortabilidad	= '';
	LET cCveSentido				= '';
	LET cBcoOrdenante			= '';
	LET cBcoReceptor			= '';
	LET cProducto				= '';
	LET cCta_ordenante			= '';
	LET cCta_receptora			= '';
	LET cClave_origen			= '';
	LET cEstatus_respuesta		= '';
	LET cEstatus_respuesta_res	= '';
    LET cfolio_solicitud        = '';

	BEGIN	
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus,cFechaSolicitud,
            cInstFinanc,cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/93146256/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON; 

	--Obtiene las cuentas del cliente
	IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) > 0 THEN
		IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND status_cta = '1') > 0 THEN

				FOREACH
                    SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
    					INTO cNumCte, cApPaterno, cApMaterno, cNombre1, cNombre2, cRFC, cProducto, cNombre, cNumCta, cCuentaClabe,
                             cCta_ordenante,cCta_receptora,cEstatusPortabilidad,cCveSentido,cClave_origen,cBcoOrdenante, cfolio_solicitud,
                             cFechaSolicitud, cEstatus_respuesta_res, cEstatus_respuesta,cFechaRespSol,
                             cFechaNotificacion, cRFCEmpresa, cFechaCancelacion
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                  
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1)) 
                        AND folio_solicitud in  (select max(case when 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) is null then 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) else
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) end)
												FROM bdicheq:"informix".sc_portacec_solicitud
												WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora)
												AND clave_sentido in ('1','0'))
                        UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban 
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido = '2' 
                         UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad

                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido is null
                        ORDER BY scmaechq.cuenta_clabe, clave_sentido,estatus_portabilidad ASC, folio_solicitud DESC
                              
                        LET cCiclo = cCiclo + 1;
                        IF cCiclo <= pNumRegistros THEN
                            CONTINUE FOREACH;
                        END IF;

						--Obtiene ESTATUS
						LET cEstatus = '';
						IF NVL(cCta_ordenante,'') <> '' OR NVL(cCta_receptora,'') <> '' THEN
							SELECT descripcion INTO cEstatus
							FROM bdicheq:"informix".sc_relacion_estatus
							WHERE estatus_portabilidad = cEstatusPortabilidad
							AND clave_sentido = cCveSentido AND clave_origen = cClave_origen;
						END IF;


						--Obtiene INSTITUCION FINANCIERA
						LET cInstFinanc = '';

						IF NVL(cClave_origen,'') = '1' OR NVL(cClave_origen,'') = '2' THEN
							SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
							WHERE banco = '137';
						ELSE
							IF NVL(cCta_ordenante,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoOrdenante;
							ELIF NVL(cCta_receptora,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoReceptor;
							END IF;
						END IF;

						IF NVL(cEstatus_respuesta_res,'') = '' THEN

							--Obtiene OBSERVACIONES
							SELECT descripcion INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_cecoban
							WHERE estatus_cecoban = cEstatus_respuesta;

						ELSE
							--Obtiene OBSERVACIONES
							SELECT descripcion INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_respuesta
							WHERE estatus_respuesta = cEstatus_respuesta;

						END IF;


						IF NVL(cRFCEmpresa,'') = '' THEN
							LET cRFCEmpresa = '';
						END IF;

						LET cCodRet = '00000'; 
						RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,
                        cEstatus,cFechaSolicitud,cInstFinanc,cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,
                        cEstatusPortabilidad,cCveSentido,cBcoOrdenante WITH RESUME;

				END FOREACH;
		ELSE
			LET cCodRet = '00001';
		END IF;
	ELSE
		LET cCodRet = '00037';
	END IF;

	IF cCodRet <> '00000' THEN
		RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus,cFechaSolicitud,cInstFinanc,
        cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

	END IF;
END;
END PROCEDURE
DOCUMENT
'Elaboro:Armida Pazos Chávez',
'Fecha: 20100525',
'Proyecto: Habilitar y Deshabilitar la Portabilidad de Nómina.',
'-----------------------------------------------------------------------',
'Folio: 1748',
'Autor: Claudio Almodovar',
'Fecha: 31/08/2015',
'Modificación: Se modifica SP para portabilidad de nomina de otros bancos a bancoppel',
'Solicita: Rodolfo Gómez ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_portabconsultatjtcta(pEmpresa CHAR(3), pTipo CHAR(1), pNumTajCta CHAR(20))
RETURNING
	CHAR(5) AS cCodRet,
	CHAR(20) AS cNumCte,
	CHAR(26) AS cApPaterno,
	CHAR(26) AS cApMaterno,
	CHAR(26) AS cNombre1,
	CHAR(26) AS cNombre2,
	CHAR(13) AS cRFC,
    CHAR(20) AS cNumCta,
	CHAR(50) AS cNombre,
	CHAR(19) AS cCuentaClabe,
	CHAR(150) AS cEstatus,
	CHAR(8) AS cFechaSolicitud,
	CHAR(40) AS cInstFinanc,
	CHAR(150) AS cObservaciones,
	CHAR(8) AS cFechaRespSol,
	CHAR(8) AS cFechaNotificacion,
	CHAR(13) AS cRFCEmpresa,
	CHAR(8) AS cFechaCancelacion,
	CHAR(2) AS cEstatusPortabilidad,
	CHAR(1) AS cCveSentido,
	CHAR(5) AS cBcoOrdenante;

	--Declaracion de  Variables
	DEFINE cCodRet				  CHAR (5);
	DEFINE cSqlErr				  SMALLINT;
	DEFINE cCiclo				  SMALLINT;
	DEFINE cNumCte				  CHAR(20);
	DEFINE cApPaterno			  CHAR(26);
	DEFINE cApMaterno			  CHAR(26);
	DEFINE cNombre1				  CHAR(26);
	DEFINE cNombre2				  CHAR(26);
	DEFINE cRFC					  CHAR(13);
	DEFINE cNumCta				  CHAR(20) ;
	DEFINE cNombre				  CHAR(50);
	DEFINE cCuentaClabe			  CHAR(19);
    DEFINE cEstatus				  CHAR(150);
    DEFINE cFechaSolicitud		  CHAR(8);
    DEFINE cInstFinanc			  CHAR(40);
    DEFINE cObservaciones		  CHAR(150);
    DEFINE cFechaRespSol		  CHAR(8);
    DEFINE cFechaNotificacion	  CHAR(8);
    DEFINE cRFCEmpresa			  CHAR(13);
    DEFINE cFechaCancelacion	  CHAR(8);
    DEFINE cEstatusPortabilidad	  CHAR(2);
    DEFINE cCveSentido			  CHAR(1);
    DEFINE cBcoOrdenante		  CHAR(5);
    DEFINE cBcoReceptor			  CHAR(5);
    DEFINE cProducto			  CHAR(4);
    DEFINE cCta_ordenante		  CHAR(20);
    DEFINE cCta_receptora		  CHAR(20);
    DEFINE cClave_origen		  CHAR(1);
    DEFINE cEstatus_respuesta	  CHAR(2);
    DEFINE cEstatus_respuesta_res CHAR(2);
    DEFINE cfolio_solicitud       CHAR(30);

	--Inicializo Variables
	LET cCodRet					= '01285';
	LET cSqlErr					= 0;
	LET cCiclo					= 0;
	LET cNumCte					= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cRFC					= '';
	LET cNumCta					= '';
	LET cNombre					= '';
	LET cEstatus				= '';
	LET cFechaSolicitud			= '';
	LET cInstFinanc				= '';
	LET cObservaciones			= '';
	LET cFechaRespSol			= '';
	LET cFechaNotificacion		= '';
	LET cRFCEmpresa				= '';
	LET cFechaCancelacion		= '';
	LET cCuentaClabe			= '';
	LET cEstatusPortabilidad	= '';
	LET cCveSentido				= '';
	LET cBcoOrdenante			= '';
	LET cBcoReceptor			= '';
	LET cProducto				= '';
	LET cCta_ordenante			= '';
	LET cCta_receptora			= '';
	LET cClave_origen			= '';
	LET cEstatus_respuesta		= '';
	LET cEstatus_respuesta_res	= '';
    LET cfolio_solicitud        = '';

	BEGIN	
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus,cFechaSolicitud,
            cInstFinanc,cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/93146256/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON;

    IF pTipo = '1' THEN
        IF (SELECT COUNT(numcte) FROM bdicheq:"informix".sc_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pNumTajCta and status_tar = 'A' ) > 0 THEN
            SELECT cuenta,numcte into cNumCta, cNumCte FROM bdicheq:"informix".sc_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pNumTajCta and status_tar = 'A';
        ELSE
            LET cCodRet = '00858';
        END IF;
	ELIF pTipo = '2' THEN 
        IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta = pNumTajCta and status_cta = '1' ) > 0 THEN
            SELECT cuenta, num_cte into cNumCta, cNumCte FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta = pNumTajCta and status_cta = '1';
        ELSE
            LET cCodRet = '00050';
        END IF;
	ELIF pTipo = '3' THEN --Consulta por Número de Cuenta clabe
        IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta_clabe = pNumTajCta and status_cta = '1' ) > 0 THEN
            SELECT cuenta, num_cte into cNumCta, cNumCte FROM bdicheq:"informix".sc_maechq WHERE empresa = pEmpresa AND cuenta_clabe = pNumTajCta and status_cta = '1';
        ELSE
            LET cCodRet = '01283';
        END IF;
    END IF;

	--Obtiene las cuentas del cliente
--	IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) > 0 THEN
--		IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND status_cta = '1') > 0 THEN

				FOREACH
                    SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
    					INTO cNumCte, cApPaterno, cApMaterno, cNombre1, cNombre2, cRFC, cProducto, cNombre, cNumCta, cCuentaClabe,
                             cCta_ordenante,cCta_receptora,cEstatusPortabilidad,cCveSentido,cClave_origen,cBcoOrdenante, cfolio_solicitud,
                             cFechaSolicitud, cEstatus_respuesta_res, cEstatus_respuesta,cFechaRespSol,
                             cFechaNotificacion, cRFCEmpresa, cFechaCancelacion
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = cNumCte
                        AND scmaechq.cuenta = cNumCta
                        AND scmaechq.status_cta = '1'
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1)) 
                        AND folio_solicitud in  (select max(case when 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = cNumCte and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) is null then 
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = cNumCte and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) else
												(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = cNumCte and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) end)
												FROM bdicheq:"informix".sc_portacec_solicitud
												WHERE empresa = pEmpresa AND num_cte = cNumCte and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora)
												AND clave_sentido in ('1','0'))												
                        UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban 
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = cNumCte
                        AND scmaechq.cuenta = cNumCta
                        AND scmaechq.status_cta = '1'                
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido = '2' 
                         UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        case when nvl(estatus_respuesta,'') = '' then estatus_cecoban 
                                                                else estatus_respuesta end, 
                        case when nvl(estatus_respuesta,'') = '' then fecha_estatus_cecoban
                                                                else fecha_respuesta end,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad

                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
                        AND si_cliente.numcte = solicitudporta.num_cte AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
                        OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = cNumCte
                        AND scmaechq.cuenta = cNumCta
                        AND scmaechq.status_cta = '1'
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND clave_sentido is null
                        ORDER BY scmaechq.cuenta_clabe, clave_sentido,estatus_portabilidad ASC, folio_solicitud DESC
                              
                        /*LET cCiclo = cCiclo + 1;
                        IF cCiclo <= pNumRegistros THEN
                            CONTINUE FOREACH;
                        END IF;*/

						--Obtiene ESTATUS
						LET cEstatus = '';
						IF NVL(cCta_ordenante,'') <> '' OR NVL(cCta_receptora,'') <> '' THEN
							SELECT descripcion INTO cEstatus
							FROM bdicheq:"informix".sc_relacion_estatus
							WHERE estatus_portabilidad = cEstatusPortabilidad
							AND clave_sentido = cCveSentido AND clave_origen = cClave_origen;
						END IF;
						--Obtiene INSTITUCION FINANCIERA
						LET cInstFinanc = '';

						IF NVL(cClave_origen,'') = '1' OR NVL(cClave_origen,'') = '2' THEN
							SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
							WHERE banco = '137';
						ELSE
							IF NVL(cCta_ordenante,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoOrdenante;
							ELIF NVL(cCta_receptora,'') <> '' THEN
								SELECT descripcion INTO cInstFinanc FROM bdinteg:"informix".si_bancos
								WHERE banco = cBcoReceptor;
							END IF;
						END IF;

						IF NVL(cEstatus_respuesta_res,'') = '' THEN
							--Obtiene OBSERVACIONES
							SELECT TRIM(descripcion) INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_cecoban
							WHERE estatus_cecoban = cEstatus_respuesta;
							
							IF NVL(cObservaciones,'') = '' THEN
								LET cObservaciones = '0';
							END IF;
						ELSE
							--Obtiene OBSERVACIONES
							SELECT TRIM(descripcion) INTO cObservaciones
							FROM bdicheq:"informix".sc_portacec_estatus_respuesta
							WHERE estatus_respuesta = cEstatus_respuesta;
							
							IF NVL(cObservaciones,'') = '' THEN
								LET cObservaciones = '0';
							END IF;
						END IF;

						IF NVL(cRFCEmpresa,'') = '' THEN
							LET cRFCEmpresa = '';
						END IF;

						LET cCodRet = '00000'; 
						RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,
                        cEstatus,cFechaSolicitud,cInstFinanc,TRIM(cObservaciones),cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,
                        cEstatusPortabilidad,cCveSentido,cBcoOrdenante WITH RESUME;
				END FOREACH;
--		ELSE
--			LET cCodRet = '00001';
--		END IF;
--	ELSE
--		LET cCodRet = '00037';
--	END IF;

	IF cCodRet <> '00000' THEN
		RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus,cFechaSolicitud,cInstFinanc,
        TRIM(cObservaciones),cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

	END IF;
END;
END PROCEDURE
DOCUMENT
'Elaboro:Armida Pazos Chávez',
'Fecha: 20100525',
'Proyecto: Habilitar y Deshabilitar la Portabilidad de Nómina.',
'-----------------------------------------------------------------------',
'Folio: 1748',
'Autor: Claudio Almodovar',
'Fecha: 31/08/2015',
'Modificación: Se modifica SP para portabilidad de nomina de otros bancos a bancoppel',
'Solicita: Rodolfo Gómez ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_actintisrxprodcedula( pFecha DATE, pProducto CHAR(4), pObservaciones CHAR(255) )
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actintisrxprodcedula.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actintisrxprodcedula.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFecha is null OR pFecha = '' ) OR
         ( pProducto is null OR pProducto = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_intisrxprodcedula
     WHERE fecha = pFecha
       AND producto = pProducto
       AND editable = '0';
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_intisrxprodcedula
           SET observaciones = pObservaciones
         WHERE fecha = pFecha
           AND producto = pProducto;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
    
    RETURN cCodRet1;
     
    END;
    
END PROCEDURE;