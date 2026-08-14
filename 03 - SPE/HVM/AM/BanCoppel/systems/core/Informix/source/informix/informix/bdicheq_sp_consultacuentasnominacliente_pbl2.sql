CREATE PROCEDURE "informix".sp_consultacuentasnominacliente_pbl2(pEmpresa CHAR(3), pCliente CHAR(20), pNumRegistros SMALLINT)
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
	CHAR(16) AS cTarjeta,
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
	DEFINE cTarjeta			      CHAR(16);

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
	LET cTarjeta			    = '';

	BEGIN	
	ON EXCEPTION SET cSqlErr
		IF cSqlErr <> 0 THEN
			let cCodRet = cSqlErr;
			RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus,cFechaSolicitud,NVL(cTarjeta,''),
            cInstFinanc,cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;
		END IF;
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/93146256/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON; 
	
	--Obtiene las cuentas del cliente
	IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) > 0 THEN
		IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND status_cta = '1') > 0 THEN

				FOREACH
                    SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe, sctar.num_tarjeta,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
    					INTO cNumCte, cApPaterno, cApMaterno, cNombre1, cNombre2, cRFC, cProducto, cNombre, cNumCta, cCuentaClabe, cTarjeta,
                             cCta_ordenante,cCta_receptora,cEstatusPortabilidad,cCveSentido,cClave_origen,cBcoOrdenante, cfolio_solicitud,
                             cFechaSolicitud, cEstatus_respuesta_res, cEstatus_respuesta,cFechaRespSol,
                             cFechaNotificacion, cRFCEmpresa, cFechaCancelacion
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
						LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta as sctar ON (si_cliente.numcte = sctar.numcte and sctar.cuenta = scmaechq.cuenta and status_tar = 'A')
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
										 AND si_cliente.numcte = solicitudporta.num_cte 
										 AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
										 OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora
										 --CIB030419 SE AGREGA CONDICION PARA VALIDAR CONSULTA POR TARJETA
										 OR solicitudporta.cta_ordenante IN (SELECT num_tarjeta 
																			FROM bdicheq:"informix".sc_tarjeta 
																			WHERE cuenta = scmaechq.cuenta 
																			AND numcte = scmaechq.num_cte
																			AND num_tarjeta = solicitudporta.cta_ordenante )))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                  
                        AND scproducto.producto IN ((SELECT producto FROM bdicheq:"informix".sc_producportab WHERE producto = scmaechq.producto AND  activo = 1)) 
                      /* CIB030419
						AND folio_solicitud in  (select max(case when 
								(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) is null then 
								(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) else
								(select max(folio_solicitud) from sc_portacec_solicitud WHERE empresa = pEmpresa AND num_cte = pCliente and estatus_portabilidad = '1' and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora) AND clave_sentido in ('1','0')) end)
								FROM bdicheq:"informix".sc_portacec_solicitud
								WHERE empresa = pEmpresa AND num_cte = pCliente and (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora)
								AND clave_sentido in ('1','0'))
						*/
						 AND folio_solicitud = (SELECT CASE WHEN MAX(folio_solicitud) IS NULL 
													THEN 
														(SELECT MAX(folio_solicitud) 
														FROM bdicheq:sc_portacec_solicitud solicitudporta 
														WHERE solicitudporta.empresa = pEmpresa 
														AND num_cte = pCliente  
														AND (scmaechq.cuenta_clabe IN (solicitudporta.cta_ordenante,solicitudporta.cta_receptora) 
																					OR solicitudporta.cta_ordenante IN (SELECT num_tarjeta 
																						FROM bdicheq:"informix".sc_tarjeta 
																						WHERE cuenta = scmaechq.cuenta 
																						AND numcte = scmaechq.num_cte
																						AND num_tarjeta = solicitudporta.cta_ordenante))
														AND clave_sentido in ('1','0'))
												   ELSE
													    MAX(folio_solicitud) END
													    FROM bdicheq:sc_portacec_solicitud solicitudporta 
													    WHERE solicitudporta.empresa = pEmpresa 
													    AND num_cte = pCliente  
													    AND estatus_portabilidad = '1' 
													    AND (scmaechq.cuenta_clabe IN (solicitudporta.cta_ordenante,solicitudporta.cta_receptora) 
																					OR solicitudporta.cta_ordenante IN (SELECT num_tarjeta 
																						FROM bdicheq:"informix".sc_tarjeta 
																						WHERE cuenta = scmaechq.cuenta 
																						AND numcte = scmaechq.num_cte
																						AND num_tarjeta = solicitudporta.cta_ordenante))
														AND clave_sentido IN ('1','0'))

                        UNION 
						SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe, sctar.num_tarjeta,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban 
                                                                ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban 
                                                                ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
						LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta as sctar ON (si_cliente.numcte = sctar.numcte and sctar.cuenta = scmaechq.cuenta and status_tar = 'A')
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
										AND si_cliente.numcte = solicitudporta.num_cte 
										AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
										OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora
										--CIB030419 SE AGREGA CONDICION PARA VALIDAR CONSULTA POR TARJETA
										OR solicitudporta.cta_ordenante IN (SELECT num_tarjeta 
																			FROM bdicheq:"informix".sc_tarjeta 
																			WHERE cuenta = scmaechq.cuenta 
                                                                            AND numcte = scmaechq.num_cte
                                                                            AND num_tarjeta = solicitudporta.cta_ordenante )))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                
                        AND scproducto.producto IN ((SELECT producto FROM bdicheq:"informix".sc_producportab WHERE producto = scmaechq.producto AND  activo = 1))
                        AND clave_sentido = '2' 
						UNION 
                        SELECT  si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe, sctar.num_tarjeta,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban 
                                                                ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban
                                                                ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
						LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta as sctar ON (si_cliente.numcte = sctar.numcte and sctar.cuenta = scmaechq.cuenta and status_tar = 'A')
                        LEFT OUTER JOIN bdicheq:"informix".sc_producto AS scproducto ON (scmaechq.producto = scproducto.producto)
                        LEFT OUTER JOIN bdicheq:"informix".sc_portacec_solicitud AS solicitudporta ON (scmaechq.empresa = solicitudporta.empresa 
										AND si_cliente.numcte = solicitudporta.num_cte 
										AND (scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante 
										OR scmaechq.cuenta_clabe = solicitudporta.cta_receptora
										--CIB030419 SE AGREGA CONDICION PARA VALIDAR CONSULTA POR TARJETA
										OR solicitudporta.cta_ordenante IN (SELECT num_tarjeta 
																			FROM bdicheq:"informix".sc_tarjeta 
																			WHERE cuenta = scmaechq.cuenta 
                                                                            AND numcte = scmaechq.num_cte
                                                                            AND num_tarjeta = solicitudporta.cta_ordenante )))
                        WHERE si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'
                        AND scproducto.producto IN ((SELECT producto FROM bdicheq:"informix".sc_producportab WHERE producto = scmaechq.producto AND  activo = 1))
                        AND clave_sentido IS NULL
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

						--CIB030419
						IF(cBcoOrdenante = '40137') THEN
							IF ( LENGTH (cCta_ordenante) = 16) THEN
								UPDATE bdicheq:"informix".sc_portacec_solicitud 
								SET cta_ordenante = cCuentaClabe
								WHERE folio_solicitud= cfolio_solicitud;
							END IF;
						END IF;
						
						LET cCodRet = '00000'; 
						
						RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,NVL(cTarjeta,''),
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
		RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,NVL(cTarjeta,''),cEstatus,cFechaSolicitud,cInstFinanc,
        cObservaciones,cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;
	END IF;
END;
END PROCEDURE
DOCUMENT
'Elaboro:Armida Pazos ChÃ¡vez',
'Fecha: 20100525',
'Proyecto: Habilitar y Deshabilitar la Portabilidad de NÃ³mina.',
'-----------------------------------------------------------------------',
'Folio: 1748',
'Autor: Claudio Almodovar',
'Fecha: 31/08/2015',
'ModificaciÃ³n: Se modifica SP para portabilidad de nomina de otros bancos a bancoppel',
'Solicita: Rodolfo GÃ³mez ',
'BD: bdicheq',
'-----------------------------------------------------------------------',
'FOLIO: 		1907',
'PROYECTO: 		INC_PORTABILIDAD_NOMINA',
'ETIQUETA: 		CIB030419',
'AUTOR: 		98467379-HECTOR AGUILAR',
'MODIFICACIÃN: 	Se crea clon con el nombre sp_consultacuentasnominacliente_pbl para que las consultas validen de igual manera si en el campo cta_ordenante viene desde el otro banco la ',
'				cuenta clabe o el numero de tarjeta y se pueda realizar la cancelacion de la portablidad mediante el aplicativo pl004012 ', 
'				y se agrega update para actualizar el campo con la CuentaClabe correspondiente y no afectar otros procesos. ',
'SOLICITA: 		CUTBERTO GONZALEZ / ALEX CUELLAR',
'BD: 			bdicheq',
'-----------------------------------------------------------------------';

CREATE PROCEDURE "informix".cons_sec_web(pempresa CHAR(3), pcuenta CHAR(20))
--DATOS A REGRESAR
 Returning
 CHAR(5),
 SMALLINT;

 --DEFINICION DE VARIABLES
 DEFINE vcodret         CHAR(5);
 DEFINE vsiguiente      INTEGER;
 DEFINE vsqlerr         INTEGER;
 DEFINE VexisTar        INTEGER;
 DEFINE vExiste			INTEGER;

 LET vcodret = "00000";
 LET vsiguiente = 0;
 LET vsqlerr = 0;
 LET VexisTar = 0;
 LET vExiste = 0;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;
SELECT count(empresa) into vExiste FROM bdicheq:"informix".sc_maechq WHERE cuenta = pcuenta;

IF vExiste > 0 THEN
	
	SELECT count(empresa) into vExiste FROM bdicheq:"informix".sc_firmantes WHERE cuenta = pcuenta;
	
    IF vExiste > 0 THEN

        select max(secuencia) + 1 into vsiguiente
        from bdicheq:"informix".sc_firmantes
        where empresa=pempresa and cuenta=pcuenta;

        if vsiguiente is null then
			let vsiguiente = 1;
        end if;

    ELSE
		let vsiguiente = 1;
    END IF       

        RETURN vcodret, NVL(vsiguiente,0);

ELSE
        LET Vcodret = "00416";
        LET vsiguiente = "";
        RETURN vcodret, NVL(vsiguiente,0);		
END IF
END PROCEDURE;