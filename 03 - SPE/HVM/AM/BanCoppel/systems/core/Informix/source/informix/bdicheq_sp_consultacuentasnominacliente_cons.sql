CREATE PROCEDURE "informix".sp_consultacuentasnominacliente_cons(pEmpresa CHAR(3), pCliente CHAR(20), pNumRegistros SMALLINT)
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
            cInstFinanc,TRIM(cObservaciones),cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/sp_ConsultaCuentasNominaCliente.out";
    --SET DEBUG FILE TO "/pisa/pisabanco/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON; 

		 IF EXISTS (SELECT 1 FROM "informix".sc_ctas_portab_temp WHERE num_cte = pCliente ) THEN
		 DELETE FROM "informix".sc_ctas_portab_temp WHERE num_cte = pCliente;
	     END IF;
		 
       INSERT INTO bdicheq:sc_ctas_portab_temp
        select max(folio_solicitud), cta_ordenante, num_cte from bdicheq:"informix".sc_portacec_solicitud
		 where num_cte =  pCliente
		 AND clave_sentido in ('1','0')
		 group by 2,3;
		 
	--Obtiene las cuentas del cliente
	IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) > 0 THEN
		IF (SELECT COUNT(num_cte) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pCliente AND status_cta = '1') > 0 THEN
				
				FOREACH
				
                    SELECT si_cliente.numcte, si_cliente.apell_paterno, si_cliente.apell_materno, si_cliente.nombre1, si_cliente.nombre2,
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
                        AND si_cliente.numcte = solicitudporta.num_cte AND scmaechq.cuenta_clabe =  solicitudporta.cta_ordenante)
                        WHERE solicitudporta.estatus_portabilidad<>'' AND si_cliente.empresa = pEmpresa
                        AND si_cliente.numcte = pCliente
                        AND scmaechq.status_cta = '1'                  
                        AND scproducto.producto in ((Select producto from bdicheq:"informix".sc_producportab where producto = scmaechq.producto and  activo = 1))
                        AND solicitudporta.cta_ordenante in (select cta_ordenante from bdicheq:"informix".sc_ctas_portab_temp)
                        AND solicitudporta.folio_solicitud in (select folio_solicitud from bdicheq:"informix".sc_ctas_portab_temp)
												
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
                        WHERE solicitudporta.estatus_portabilidad<>'' AND si_cliente.empresa = pEmpresa
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
                        WHERE solicitudporta.estatus_portabilidad<>'' AND si_cliente.empresa = pEmpresa
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

    --SET DEBUG FILE TO "/pisa/pisabanco/sp_ConsultaCuentasNominaCliente.out";
	--TRACE ON; 

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
		ELSE
			LET cCodRet = '00001';
		END IF;
	ELSE
		LET cCodRet = '00037';
	END IF;

	IF cCodRet <> '00000' THEN
		RETURN cCodRet,cNumCte,cApPaterno,cApMaterno,cNombre1,cNombre2,cRFC,cNumCta,cNombre,cCuentaClabe,cEstatus||TRIM(cObservaciones),cFechaSolicitud,cInstFinanc,
        TRIM(cObservaciones),cFechaRespSol,cFechaNotificacion,cRFCEmpresa,cFechaCancelacion,cEstatusPortabilidad,cCveSentido,cBcoOrdenante;

	END IF;
END;
END PROCEDURE
DOCUMENT
'Elaboro:Armida Pazos ChÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡vez',
'Fecha: 20100525',
'Proyecto: Habilitar y Deshabilitar la Portabilidad de NÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mina.',
'-----------------------------------------------------------------------',
'Folio: 1748',
'Autor: Claudio Almodovar',
'Fecha: 31/08/2015',
'ModificaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n: Se modifica SP para portabilidad de nomina de otros bancos a bancoppel',
'Solicita: Rodolfo GÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³mez ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_validatarjetaper(pNumCte varchar(13), pNumCuenta varchar(13), pEstatusSolicitud CHAR (1))
   RETURNING CHAR(5),CHAR(16),CHAR(50),CHAR(6);

   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);

   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cNumtarjeta     CHAR(16);

   LET cCodRet 		      = '00001';
   LET cDescripcion	      = 'No existe tarjeta';
   LET cIdSolicitud	      = '000000';
   LET cNumtarjeta        = '0';
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "VerifCte1.err";
		--TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet,cNumtarjeta, cDescripcion, cIdSolicitud;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO "/tmp/combinacion/SP_VALIDASOLPER.out";
	--TRACE ON;

	SELECT max(idsolicitud) INTO cIdSolicitud FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta AND estatusproceso = pEstatusSolicitud;

    SELECT numtarjeta INTO cNumtarjeta FROM intercard:detalle_maquila WHERE idsolicitud in (
    SELECT idsolicitud FROM  intercard:solicitudtarjeta WHERE idsolicitud=cIdSolicitud AND  numcliente = pNumCte  AND numcuenta =pNumCuenta);

    
	IF cNumtarjeta  <> "" THEN
		LET cCodRet = "00000";
		LET cDescripcion = "Tarjeta Valida";
	ELSE
		LET cCodRet = "00002";
	END IF;

	RETURN cCodRet,CNumtarjeta, cDescripcion, cIdSolicitud;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Miguel Guicochea',
'FECHA: 03/10/2016',
'BD: bdicheq',
'Objetivo: Se crea procedimiento para validar que la tarjeta deslizada corresponda a la solicitud';

CREATE PROCEDURE "informix".consctesfirxnumctaper(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))
	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5),     -- Codigo de retorno
	CHAR(20),    -- # Cliente
	CHAR(26),    -- Apellido paterno
	CHAR(26),    -- Apellido materno
	CHAR(26),    -- Nombre 1
	CHAR(26),    -- Nombre 2
	CHAR(13),    -- RFC
	CHAR(16),    -- # Tarjeta
	DATE,    	 --	Expiracion
	CHAR(4),     -- Producto tarjeta
	MONEY(14,2), -- Limite de retiro maximo por mes
	CHAR(1),     -- Status tarjeta
	CHAR(8),     -- Tipo de cliente
	CHAR(10),    -- Fecha de Nacimiento
	CHAR(4),     -- Producto de la cuenta
	CHAR(2);     -- Parentesco

	-- VARIABLES --
	DEFINE vCodRet  	CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE vTipCte  	CHAR(1);
	DEFINE vNumCte		CHAR(20);
	DEFINE vApePat  	CHAR(26);
	DEFINE vApeMat  	CHAR(26);
	DEFINE vNombre1 	CHAR(26);
	DEFINE vNombre2 	CHAR(26);
	DEFINE vRFC     	CHAR(13);
	DEFINE vNumTarj 	CHAR(16);
	DEFINE Vexpiracion  DATE;
	DEFINE Vprodtarjeta CHAR(4);
	DEFINE vLimTar  	MONEY(14,2);
	DEFINE vTipoCte 	CHAR(8);
	DEFINE vStatTjt 	CHAR(1);
	DEFINE vFechaNac 	CHAR(10);
	DEFINE vProductoCuenta CHAR(4);
	DEFINE vCantReg 	SMALLINT;
	DEFINE vParentesco 	CHAR(2);	
   --	DEFINE vFechaNac2 	DATE;
	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  		= "000";
	LET iSqlErr   		= 0;
	LET vCantReg 		= 0;
	LET vTipCte 		= "";
	LET vNumCte 		= "";
	LET vApePat 		= "";
	LET vApeMat 		= "";
	LET vNombre1 		= "";
	LET vNombre2 		= "";
	LET vRFC 			= "";
	LET vNumTarj 		= "";
	LET Vexpiracion 	= "";
	LET Vprodtarjeta 	= "";
	LET vLimTar 		= "";
	LET vTipoCte 		= "";
	LET vStatTjt 		= "";
	LET vFechaNac 		= "";
	LET vProductoCuenta = "";
	LET vParentesco 	= "";	
  --  LET vFechaNac2 = "";

	--SET DEBUG FILE TO "/respaldosbd/ConsCtesFirXnumCtaPer.out";
	--TRACE ON;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
						Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;


		-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --

		FOREACH
		
			SELECT DISTINCT si_cte.numcte, 
				si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 
				sc_fir.secuencia As tipo_cliente, si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
			INTO
                
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
			FROM
				bdicheq:"informix".sc_maechq sc_mcq,
				bdicheq:"informix".sc_firmantes AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte,
				bdinteg:"informix".si_ctepf AS si_pf
			WHERE sc_fir.empresa =  pEmpresa 
			  AND sc_fir.cuenta =  pNumeroCuenta 
			  -- AND sc_fir.numcte != pNumeroCliente 
			  AND sc_fir.numcte = si_cte.numcte 
			  AND si_cte.empresa = pEmpresa 
			  AND sc_fir.numcte = si_pf.numcte
			  AND sc_mcq.empresa = pEmpresa 
			  AND sc_mcq.cuenta = pNumeroCuenta
			  ORDER BY sc_fir.secuencia ASC
				
			IF vTipoCte = '1' THEN
				LET vTipoCte = 'Titular';
			ELSE
				LET vTipoCte = 'Firmante';
			END IF;

			-- OBTENER LA TARJETA DEL FIRMANTE --

			SELECT DISTINCT sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE sc_tjt.empresa = pEmpresa 
			  AND sc_tjt.cuenta = pNumeroCuenta
			  AND sc_tjt.numcte = vNumCte
			  --AND sc_tjt.tipo_tarjeta = 'A'
			  --AND sc_tjt.status_tar = 'A' 
			  AND sc_tjt.secuencia = (
					SELECT MAX(secuencia) 
					  FROM bdicheq:sc_tarjeta 
					 WHERE sc_tjt.empresa = empresa 
					   AND sc_tjt.cuenta = cuenta 
					   AND sc_tjt.numcte = numcte );
					   --AND sc_tjt.tipo_tarjeta = 'A');

			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF
          --  LET vFechaNac= vFechaNac;
           -- LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			LET vCantReg = vCantReg + 1;
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
		
		END FOREACH;

		IF vCantReg = 0 THEN
			LET vCodRet  	 = "000";
			LET vNumCte  	 = "";
			LET vApePat  	 = "";
			LET vApeMat  	 = "";
			LET vNombre1 	 = "";
			LET vNombre2 	 = "";
			LET vRFC     	 = "";
			LET vNumTarj 	 = "";
			LET Vexpiracion  = "";
			LET Vprodtarjeta = "";
			LET vLimTar  	 = 0;
			LET vStatTjt 	 = "";
			LET vTipoCte 	 = "";
			LET vFechaNac 	 = "";
			LET vParentesco	 = "";
           -- LET vFechaNac=vFechaNac2;
            LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
		
		END IF;
	
	END 
	
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se agrega filtro para obtener datos de tajertas unicamente Activas',
'EJECUTADO O LLAMADO POR: AperTP.exe',
'AUTOR : Elmer LÃÂ³pez',
'FECHA : 12/Octubre/2016',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_actualiza_ctasconsbg( pNumCredito CHAR(20), pTramaResp CHAR(500) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet  CHAR(5);
    DEFINE cIsamErr CHAR(5);
    DEFINE cDescErr CHAR(50);
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE iExiste  SMALLINT;
    DEFINE cCodResp CHAR(5);
    
    LET cCodRet  = '000';
    LET cIsamErr = '';
    LET cDescErr = '';
    LET iSqlErr	 = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET iExiste  = 0;
    LET cCodResp = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_ctasconsbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_ctasconsbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pNumCredito is null OR pNumCredito = '' ) OR
       ( pTramaResp is null OR pTramaResp = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE num_credito = pNumCredito;
     
    IF iExiste = 0 THEN
        LET cCodRet = '100';
        RETURN cCodRet;
    ELSE
        LET cCodResp = SUBSTR(pTramaResp, 1, 5);
    
        IF cCodResp = '00000' THEN
            UPDATE sc_limite_sbg
               SET imp_acum_sbg = 0.00
             WHERE num_credito = pNumCredito;
        END IF;
        
        INSERT INTO sc_limite_sbg_resp
        ( fecha_hora, num_credito, trama_resp )
        VALUES
        ( current, pNumCredito, pTramaResp );
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;