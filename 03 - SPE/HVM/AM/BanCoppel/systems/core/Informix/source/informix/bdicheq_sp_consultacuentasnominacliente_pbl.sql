CREATE PROCEDURE "informix".sp_consultacuentasnominacliente_pbl(pEmpresa CHAR(3), pCliente CHAR(20), pNumRegistros SMALLINT)
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
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

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
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
    					INTO cNumCte, cApPaterno, cApMaterno, cNombre1, cNombre2, cRFC, cProducto, cNombre, cNumCta, cCuentaClabe,
                             cCta_ordenante,cCta_receptora,cEstatusPortabilidad,cCveSentido,cClave_origen,cBcoOrdenante, cfolio_solicitud,
                             cFechaSolicitud, cEstatus_respuesta_res, cEstatus_respuesta,cFechaRespSol,
                             cFechaNotificacion, cRFCEmpresa, cFechaCancelacion
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
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
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban 
                                                                ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban 
                                                                ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
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
                        si_cliente.rfc, scproducto.producto, scproducto.nombre, scmaechq.cuenta, scmaechq.cuenta_clabe,
                        cta_ordenante,cta_receptora,estatus_portabilidad,clave_sentido,clave_origen,bco_ordenante, folio_solicitud,
                        fecha_solicitud, estatus_respuesta, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN estatus_cecoban 
                                                                ELSE estatus_respuesta END, 
                        CASE WHEN NVL(estatus_respuesta,'') = '' THEN fecha_estatus_cecoban
                                                                ELSE fecha_respuesta END,
                        fecha_presentacion, rfc_empresa, fecha_solca_portabilidad
                        FROM bdinteg:"informix".si_cliente AS si_cliente
                        LEFT OUTER JOIN bdicheq:"informix".sc_maechq AS scmaechq ON (si_cliente.numcte = scmaechq.num_cte)
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
'BD: bdicheq',
'-----------------------------------------------------------------------',
'FOLIO: 		1907',
'PROYECTO: 		INC_PORTABILIDAD_NOMINA',
'ETIQUETA: 		CIB030419',
'AUTOR: 		98467379-HECTOR AGUILAR',
'MODIFICACIÓN: 	Se crea clon con el nombre sp_consultacuentasnominacliente_pbl para que las consultas validen de igual manera si en el campo cta_ordenante viene desde el otro banco la ',
'				cuenta clabe o el numero de tarjeta y se pueda realizar la cancelacion de la portablidad mediante el aplicativo pl004012 ', 
'				y se agrega update para actualizar el campo con la CuentaClabe correspondiente y no afectar otros procesos. ',
'SOLICITA: 		CUTBERTO GONZALEZ / ALEX CUELLAR',
'BD: 			bdicheq',
'-----------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_val_ctectacel (vCte CHAR(20), vCta CHAR(20), vTel CHAR(10))
	RETURNING CHAR(4) AS CodRetorno, CHAR(12) AS CtaAso, CHAR(10) AS TelAso;

--Definicion de Variables
DEFINE iSqlErr						INTEGER;
DEFINE cCodRet						CHAR(6);
DEFINE TelAso						CHAR(10);
DEFINE CtaAso						CHAR(12);
DEFINE cVar1 						INTEGER;
DEFINE cVar2 						INTEGER;
DEFINE cVar3 						INTEGER;
DEFINE cTel							CHAR(20);
DEFINE cCta							CHAR(20);	
DEFINE vCount						INTEGER;


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '0000';
LET TelAso = '';
LET CtaAso = '';
LET vCount = 1;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,TelAso,CtaAso;
		END IF;
	END EXCEPTION;

	-- Validacion Cliente
	IF vCte <> '' THEN
	
		SELECT COUNT(num_cte) INTO vCount 
		FROM bdicheq:sc_cuenta_telefono WHERE num_cte=vCte;
		
		IF vCount > 0 THEN
			
			FOREACH
				SELECT cuenta, telefono INTO cCta, cTel
				FROM bdicheq:sc_cuenta_telefono 
				WHERE num_cte=vCte
				
				LET cCodRet = '0001'; 
				RETURN cCodRet,cCta, cTel;
			END FOREACH;

		ELSE
			LET cCodRet = '0000';
		END IF;			
	END IF;	
	
	-- Validacion telefono
	IF vTel <> '' THEN
		
		EXECUTE PROCEDURE bdinteg:sp_validatelefono ('001','',vTel,'')
		INTO cCodRet,cVar1,cVar2,cVar3;
		
		IF cCodRet = "000" AND cVar2 = "1" THEN 
			LET cCodRet = '0000';
			SELECT COUNT(cuenta) INTO vCount 
			FROM bdicheq:sc_cuenta_telefono WHERE telefono=vTel;
		
			IF vCount > 0 THEN
						
				FOREACH
					SELECT cuenta, telefono INTO cCta, cTel
					FROM bdicheq:sc_cuenta_telefono 
					WHERE telefono=vTel

					LET cCodRet = '0001'; 
					RETURN cCodRet,cCta, cTel;
				END FOREACH;
				
			ELSE
					
			END IF;		
		ELSE
			LET cCodRet = '0002'; --Telefono invalido
			RETURN cCodRet, CtaAso, TelAso;
		END IF;		
	END IF;		
	
	-- Validacion Cuenta
	IF vCta <> '' THEN
		
		SELECT COUNT(cuenta) INTO vCount 
		FROM bdicheq:sc_maechq WHERE cuenta = vCta;

		IF vCount > 0 THEN
		
			SELECT COUNT(cuenta) INTO vCount 
			FROM bdicheq:sc_cuenta_telefono WHERE telefono=vTel;
			
			IF vCount > 0 THEN
				
				FOREACH
					SELECT cuenta, telefono INTO cCta, cTel
					FROM bdicheq:sc_cuenta_telefono 
					WHERE cuenta=vCta
				
					LET cCodRet = '0001'; 
					RETURN cCodRet,cCta, cTel;
				END FOREACH;
				
			ELSE
				LET cCodRet = '0000';		
			END IF;
		ELSE
			
			LET cCodRet = '0002';
			RETURN cCodRet, CtaAso, TelAso;
		END IF;			
	END IF;	
	RETURN cCodRet, CtaAso, TelAso;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Valida al cliente, cuenta o telefono no este asociado',
'MOFICIACION:SE QUITA LA VALIDACION DE TRANSFER',
'ELABORO: IREB 11112016',
'MODIFICO: 25012017';

CREATE PROCEDURE "informix".sp_integra_suspenso(pempresa CHAR(3),psistema CHAR(2),pfecha DATE)
    RETURNING CHAR(5);

    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
    
    DEFINE vcodret          CHAR(5);
    DEFINE vsqlerr          INTEGER;
	DEFINE vfecha_valida    DATE;

	DEFINE vidsc_suspenso   INTEGER; 
    DEFINE vsecuencia       INTEGER;
    DEFINE vsucursal 		CHAR(4);
    DEFINE vsuccta 			CHAR(4);
	DEFINE vcancelad 		CHAR(1);
    DEFINE vccmayor 		CHAR(10);
    DEFINE vccsub 			CHAR(10);
    DEFINE vccsubsub 		CHAR(10);
    DEFINE vccssubsub 		CHAR(10);
    DEFINE vccsssubsub 		CHAR(10);
    DEFINE vsector 			CHAR(10);
    DEFINE vauxiliar 		CHAR(9);
    DEFINE vproducto 		CHAR(4);
    DEFINE vtransacc 		CHAR(4);
	DEFINE vsectorca 		CHAR(2);
	
    DEFINE vtot_cargo 		MONEY(14,2);
    DEFINE vtot_abono 		MONEY(14,2);
	DEFINE vmonto_tot       MONEY(14,2);
    DEFINE vmoneda 			CHAR(2);
    DEFINE vdescripcion 	CHAR(30);
	
    DEFINE vc_ccmayor        CHAR(4);
    DEFINE vc_ccsub          CHAR(2);
    DEFINE vc_ccsubsub       CHAR(2);
    DEFINE vc_ccsssub        CHAR(2);
    DEFINE vc_ccssssub       CHAR(2);
    DEFINE vc_sector         CHAR(2);
    DEFINE va_ccmayor        CHAR(4);
    DEFINE va_ccsub          CHAR(2);
    DEFINE va_ccsubsub       CHAR(2);
    DEFINE va_ccsssub        CHAR(2);
    DEFINE va_ccssssub       CHAR(2);
    DEFINE va_sector         CHAR(2);
	
    DEFINE vpsucursal 		 CHAR(4);
    DEFINE vpsuccta 		 CHAR(4);
	
	DEFINE vpccmayor         CHAR(4);
    DEFINE vpccsub           CHAR(2);
    DEFINE vpccsubsub        CHAR(2);
    DEFINE vpccssubsub       CHAR(2);
    DEFINE vpccsssubsub      CHAR(2);
    DEFINE vpsector          CHAR(2);
	
	DEFINE vpauxiliar 		  CHAR(9);
	DEFINE vptot_cargo 		  MONEY(14,2);
    DEFINE vptot_abono 		  MONEY(14,2);
    DEFINE vpmoneda 		  CHAR(2);
    DEFINE vpdescripcion 	  CHAR(30);
	DEFINE vpciudad           CHAR(3);
	DEFINE vusuario 		  CHAR(8);
	DEFINE vfecha_hoy         DATE;
	DEFINE vpsecuencia        INTEGER;
	DEFINE vaplicapasecap     BOOLEAN;
	DEFINE vmca_aplic 	      CHAR(1);
	DEFINE vvalor			  INTEGER;
	
	BEGIN 
	
	ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret ;
        END IF;
    END EXCEPTION;

	--set debug file to "/tmp/sp_integra_suspenso.out";
    --trace on;

    LET vcodret  = '000';
	LET vfecha_valida = NULL;
	
	LET vidsc_suspenso = 0;
	LET vproducto = '';
	LET vtransacc = '';
	LET vsectorca = '';
	LET vsecuencia = '';
	
	LET vc_ccmayor        = ' ';
    LET vc_ccsub          = ' ';
    LET vc_ccsubsub       = ' ';
    LET vc_ccsssub        = ' ';
    LET vc_ccssssub       = ' ';
    LET vc_sector         = ' ';
    LET va_ccmayor        = ' ';
    LET va_ccsub          = ' ';
    LET va_ccsubsub       = ' ';
    LET va_ccsssub        = ' ';
    LET va_ccssssub       = ' ';
    LET va_sector         = ' ';

	LET vusuario 		  = ' ';
	LET vpsucursal 	      = ' ';
	LET vpsuccta 	      = ' ';

	LET vpccmayor         = ' ';
	LET vpccsub           = ' ';
	LET vpccsubsub        = ' ';
	LET vpccssubsub       = ' ';
	LET vpccsssubsub      = ' ';
	LET vpsector          = ' ';
	LET vpauxiliar 	      = ' ';
	LET vptot_cargo 	  = 0;
	LET vptot_abono 	  = 0;
	LET vmonto_tot        = 0;
	LET vpmoneda 	      = ' ';
	LET vpdescripcion     = ' ';
	LET vpciudad          = ' ';
	LET vpsecuencia       = 0;
	
	LET vaplicapasecap    = 'f';
	LET vmca_aplic        = "0";
	LET vvalor 			  = 0;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF psistema='01' THEN

	
		LET vg_sistema = '01';
		SELECT COUNT(fecha_valida) INTO vvalor FROM bdicheq:sc_suspenso WHERE fecha_captura_fin = pfecha;
		
		IF vvalor >= 0 THEN 
			UPDATE bdicheq:sc_suspenso 
			SET fecha_captura_fin = null
			WHERE fecha_captura_fin = pfecha;
		END IF
		
	/*	IF EXISTS( SELECT COUNT(fecha_valida) FROM bdicheq:sc_suspenso WHERE fecha_captura_fin = pfecha ) THEN
			UPDATE bdicheq:sc_suspenso 
			   SET fecha_captura_fin = null
			 WHERE fecha_captura_fin = pfecha;
		END IF*/
		
		--SELECT MIN(fecha_valida) INTO vfecha_valida FROM bdicheq:sc_suspenso WHERE fecha_captura_fin IS NULL;
			SELECT MIN(sus.fecha_valida) INTO vfecha_valida FROM bdicheq:sc_suspenso sus, bdinteg:si_prodtran prod
			WHERE sus.producto = prod.producto AND sus.transacc = prod.transaccion AND sus.fecha_captura_fin IS NULL;
	
			
		IF vfecha_valida IS NULL THEN
			
			RETURN vcodret;
			
		ELSE
		
				-- // CREA TABLA TEMPORAL DEL CUENTAS X PROCESO CUENTAS SUSPENSO
		SELECT empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector 
		FROM bdinteg:si_catalog  
		INTO temp tmp_si_catalog WITH NO LOG;
	
		CREATE INDEX id1_tmp_si_catalog ON tmp_si_catalog (empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector ) using btree fillfactor 99;
		UPDATE statistics medium FOR TABLE tmp_si_catalog;
		
			UPDATE bdicheq:sc_suspenso 
			   SET (usuario_sus, control_poliza_sus,fecha_captura_sus) = 
		           ((SELECT usuario,control_poliza,fecha_captura 
				       FROM bdicont:co_poliza 
					  WHERE empresa = pempresa
					    AND usuario='chqinfor'
						AND control_poliza > 0 
						AND fecha_captura = pfecha
						AND moneda IS NOT NULL))
			 WHERE fecha_valida = pfecha;
			 
		END IF
		
		TRUNCATE bdicheq:sc_contab;
        TRUNCATE bdicheq:aux_auditerr;
	
		FOREACH
			SELECT idsc_suspenso,secuencia,sucursal,succta,cancelad,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,auxiliar,producto,transacc,sectorca,tot_cargo,tot_abono,moneda,descripcion
			  INTO vidsc_suspenso,vsecuencia,vsucursal,vsuccta,vcancelad,vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,vsector,vauxiliar,vproducto,vtransacc,vsectorca,vtot_cargo,vtot_abono,vmoneda,vdescripcion
			  FROM bdicheq:sc_suspenso
			 WHERE fecha_valida = vfecha_valida
			 ORDER BY idsc_suspenso ASC

				SELECT c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector,
					   a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
				  INTO vc_ccmayor, vc_ccsub, vc_ccsubsub, vc_ccsssub, vc_ccssssub, vc_sector,
					   va_ccmayor, va_ccsub, va_ccsubsub, va_ccsssub, va_ccssssub, va_sector
				  FROM bdinteg:si_prodtran
				 WHERE empresa = pempresa 
				   AND producto = vproducto 
				   AND sistema = psistema 
				   AND transaccion = vtransacc 
				   AND secuencia = vsecuencia;
				   
					IF (vc_ccmayor =' '  OR vc_ccmayor IS NULL) AND (va_ccmayor = ' ' OR va_ccmayor IS NULL) THEN
						CONTINUE FOREACH;
					END IF
					
					IF NOT ( ((SELECT COUNT(*) FROM tmp_si_catalog 
	                    WHERE empresa = pempresa 
						  AND ccmayor = va_ccmayor 
						  AND ccsub = va_ccsub
						  AND ccsubsub = va_ccsubsub
						  AND ccssubsub = va_ccsssub
						  AND ccsssubsub = va_ccssssub
						  AND sector = va_sector ) > 0) 
																		AND
						((SELECT COUNT(*) FROM tmp_si_catalog 
									WHERE empresa = pempresa 
									  AND ccmayor = vc_ccmayor 
									  AND ccsub = vc_ccsub
									  AND ccsubsub = vc_ccsubsub
									  AND ccssubsub = vc_ccsssub
									  AND ccsssubsub = vc_ccssssub
									  AND sector = vc_sector ) > 0)						  
									  ) THEN
						
						CONTINUE FOREACH;
						
					END IF	
					
					IF vtot_cargo <> 0 THEN -- cancelacion de poliza suspenso

						INSERT INTO bdicheq:sc_contab VALUES (pempresa, vsecuencia, vsucursal, vsuccta, vccmayor,vccsub,vccsubsub,
															  vccssubsub,vccsssubsub,vsector,vauxiliar,0,vtot_cargo,
															  vmoneda,vdescripcion) ; 
															  
															  
					ELSE

						INSERT INTO bdicheq:sc_contab VALUES (pempresa, vsecuencia, vsucursal, vsuccta, vccmayor,vccsub,vccsubsub,
															  vccssubsub,vccsssubsub,vsector,vauxiliar,vtot_abono,0,
														      vmoneda,vdescripcion) ; 
					END IF

					LET vaplicapasecap = 't';
					
					IF vtot_cargo <> 0 THEN
						LET vmonto_tot = vtot_cargo;

						CALL extrae_cont(pempresa,vsecuencia,vmonto_tot,vsucursal,vproducto,vmoneda,vtransacc,vsectorca,vcancelad,vsuccta,vdescripcion) 
						RETURNING vcodret;
						
						IF vcodret <> "000" THEN 
							RETURN vcodret;
						END IF
						
					END IF

		END FOREACH

		IF vaplicapasecap = 't' THEN
		
		    CALL auditor(pempresa) RETURNING vcodret;
		
			IF vcodret = "000" THEN 
		
				LET vusuario = "ctassuca";
			    CALL pasecont(pempresa,pfecha,vfecha_valida,vusuario) RETURNING vcodret;
				
				IF vcodret = "000" THEN 
				
					UPDATE bdicheq:sc_suspenso 
					   SET (usuario_fin, control_poliza_fin,fecha_captura_fin) = 
		                   ((SELECT usuario,control_poliza,fecha_captura 
							   FROM bdicont:co_poliza 
							  WHERE empresa = pempresa
					            AND usuario='ctassuca'
						        AND control_poliza > 0 
						        AND fecha_captura = pfecha
						        AND moneda IS NOT NULL))
			        WHERE fecha_valida = vfecha_valida;

				END IF
			
			END IF

			END IF
		
	END IF
	
    RETURN vcodret;

    END;

END PROCEDURE;