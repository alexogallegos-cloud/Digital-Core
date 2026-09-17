CREATE PROCEDURE "informix".sp_actualizatutarjeta_web(pEmpresa CHAR(3),
													pNumCta CHAR(20),
													pNumTarjeta CHAR(16))
--RETORNO--
RETURNING	CHAR(5),	-- Codigo de Retorno
			CHAR(5),	-- Codigo de Retorno 2
			CHAR(1);	-- Tipo de Trajeta

--DEFINICION DE VARIABLES
DEFINE	iSqlErr 	INTEGER;
DEFINE	iIsamErr 	INTEGER;
DEFINE	cCodRet 	CHAR(6);
DEFINE	cCodRet2 	CHAR(6);
DEFINE	cTipoTarj	CHAR(1);

--INICIALIZACION DE VARIABLES
LET iSqlErr		= 0;
LET iIsamErr	= 0;
LET cCodRet		= '00000';
LET cCodRet2	= '00000';
LET	cTipoTarj	= "";

	--SET DEBUG FILE TO "/respaldosbd/mario/sp_actualizatutarjeta.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamErr
	IF iSqlErr <> 0 THEN
			LET cCodRet2 = iSqlErr;
			RETURN cCodRet, cCodRet2, cTipoTarj;
		END IF
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumCta,'') <> '' OR NVL(pNumTarjeta,'') <> '') THEN

		IF NVL(pNumCta,'') <> '' THEN
			SELECT LIMIT 1 b.clave_tipotarjeta INTO cTipoTarj
			FROM intercard:"informix".tarjeta a, intercard:"informix".lote b, intercard:"informix".tipotarjeta c,
			bdicheq:"informix".sc_tarjeta d, bdicheq:"informix".sc_maechq e
			WHERE b.numerolote = a.numerolote AND b.clave_tipotarjeta = c.clave_tipotarjeta
			AND a.numtarjeta = d.num_tarjeta AND b.clave_tipotarjeta = '4'
			AND e.status_cta = 1 AND d.status_tar = 'A' AND d.empresa = e.empresa 
			AND d.empresa = pEmpresa AND d.cuenta = pNumCta;
		ELSE
			SELECT LIMIT 1 b.clave_tipotarjeta INTO cTipoTarj
			FROM intercard:"informix".tarjeta a, intercard:"informix".lote b, intercard:"informix".tipotarjeta c,
			bdicheq:"informix".sc_tarjeta d, bdicheq:"informix".sc_maechq e
			WHERE b.numerolote = a.numerolote AND b.clave_tipotarjeta = c.clave_tipotarjeta
			AND a.numtarjeta = d.num_tarjeta AND b.clave_tipotarjeta = '4'
			AND e.status_cta = 1 AND d.status_tar = 'A' AND d.empresa = e.empresa 
			AND d.empresa = pEmpresa AND d.num_tarjeta = pNumTarjeta;
		END IF

		IF NVL(cTipoTarj,'') = '4' THEN
			LET cTipoTarj = '1';
		ELSE
			LET cTipoTarj = '0';
		END IF
	ELSE
		LET cCodRet2 = '00001'; --Parametros Vacios.
	END IF
	RETURN cCodRet, cCodRet2, cTipoTarj;
END
END PROCEDURE
DOCUMENT
"Folio:1618",
"Autor:95609997 Claudio Almodovar",
"Fecha:14/07/2014",
"ModificaciÃÂ³n: Valida si la tarjeta es de chip o de banda",
"Sustento: RQM_10-239-5_Ticket_inteligente_mensaje_para_tarjeta_de_debito_banda.pdf",
"Solicita: Rodolfo GÃÂ³mez ",
"BD: bdicheq";

CREATE PROCEDURE "informix".sp_conscitasagendadas_web(pStatus CHAR(20),pTipoBusqueda SMALLINT,pTipoConsulta SMALLINT, pNumCte CHAR(10),pNumCta CHAR(15),pCuentaClabe  CHAR(18), pSkip SMALLINT)
--DATOS A REGRESAR---
RETURNING CHAR(5)  AS cCodRet,
		  CHAR(8)  as sSecuencia,
		  DATE     AS dFechaCita,
		  CHAR(4)  AS sSucursal,
		  CHAR(10) AS sNumeroCliente,
		  CHAR(107) AS sNombreCliente,
		  CHAR(15) AS sNumeroCuenta,
		  CHAR(40) as sTipoCuenta,
		  CHAR(20) AS sEstatus,
		  CHAR(40) AS sTramite,		  
		  CHAR(8)  AS sHoraCita,
		  CHAR(200) as sObservaciones;
	 		  
--DEFINICION DE VARIABLES--
DEFINE cCodRet 	       CHAR(5);
DEFINE iSqlErr		   INTEGER;
DEFINE sSecuencia	   INTEGER;
DEFINE dFechaCita 	   DATE;
DEFINE sSucursal   	   CHAR(4);
DEFINE sNumeroCliente  CHAR(10);
DEFINE sNombreCliente  CHAR(107);
DEFINE sNumeroCuenta   CHAR(50);
DEFINE sTipoCuenta	   CHAR(40);
DEFINE sEstatus 	   CHAR(20);
DEFINE sTramite        CHAR(40);
DEFINE sHoraCita       CHAR(8);
DEFINE sObservaciones  CHAR(200);
DEFINE sST			   CHAR(20);
DEFINE sST1			   CHAR(20);
DEFINE sST2			   CHAR(20);
DEFINE sRetorno        CHAR(5);
DEFINE sdigitover      CHAR(1);
DEFINE sCompara        CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet 	    = '00000';
LET iSqlErr		    = 0;
LET sSecuencia		= 0;
LET dFechaCita   	= '01-01-1900';
LET sSucursal		= '';
LET sNumeroCliente	= '';
LET sNombreCliente	= '';
LET sNumeroCuenta 	= '';
LET sTipoCuenta 	= '';
LET sEstatus 		= '';
LET sTramite 		= '';
LET sHoraCita		= '';
LET sObservaciones	= '';
LET sST				= '';
LET sST1			= '';
LET sST2			= '';
LET sRetorno		= '';
LET sdigitover		= '';
LET sCompara 		= '';

--SET DEBUG FILE TO "/respaldosbd/OmarLerma/sp_conscitasagendadas.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
	   END IF;
	END EXCEPTION;
	
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

	IF(pTipoBusqueda = 1) THEN
			IF (pStatus = 'TODOS') THEN
			
				LET sST  = 'ACUDIO';
				LET sST1 = 'PENDIENTE';
				LET sST2 = 'CANCELO';
				
			ELSE 
			
				LET sST = pStatus;
				
			END IF;
			
			IF pTipoConsulta = 1 THEN
			
					IF (SELECT count(c.fecha_cita) FROM bdicheq:"informix".sc_citasagendadas c, bdicheq:"informix".sc_catestatustramitecitas q  WHERE DATE(c.fecha_cita) <= DATE(CURRENT) AND DATE(c.fecha_cita) >= DATE(CURRENT - 90 UNITS DAY) AND q.descripcion IN (sST,sST1,sST2) AND c.status = q.idestatus)> 0 THEN

						FOREACH						
							-- anteriores
							
							SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
							  FROM bdicheq:"informix".sc_citasagendadas c, 
								   bdicheq:"informix".sc_maechq n,
								   bdicheq:"informix".sc_producto p,
								   bdicheq:"informix".sc_catestatustramitecitas q
							 WHERE DATE(fecha_cita) <= DATE(CURRENT) 
							   AND DATE(fecha_cita) >= DATE(CURRENT - 90 UNITS DAY)
							   AND q.descripcion IN (sST,sST1,sST2)
							   AND c.numcte = n.num_cte
							   AND c.num_cuenta = n.cuenta
							   AND n.producto =  p.producto
							   AND c.status = q.idestatus
							GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
							
							RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
							
						END FOREACH;	
					ELSE 					
						LET cCodRet = '01289'; --No existe informacion. Favor de verificar
						RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
					END IF;

			ELIF pTipoConsulta = 2 THEN
					IF (SELECT count(c.fecha_cita) FROM bdicheq:"informix".sc_citasagendadas c, bdicheq:"informix".sc_catestatustramitecitas q  WHERE DATE(c.fecha_cita) = DATE(CURRENT) AND q.descripcion IN (sST,sST1,sST2) AND c.status = q.idestatus )> 0 THEN
						FOREACH
						--Hoy							
													
							SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
							  FROM bdicheq:"informix".sc_citasagendadas c, 
								   bdicheq:"informix".sc_maechq n,
								   bdicheq:"informix".sc_producto p,
								   bdicheq:"informix".sc_catestatustramitecitas q
							 WHERE DATE(fecha_cita) = DATE(CURRENT)
							   AND q.descripcion IN (sST,sST1,sST2)
							   AND c.numcte = n.num_cte
							   AND c.num_cuenta = n.cuenta
							   AND n.producto =  p.producto
							   AND c.status = q.idestatus
							GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
							
							RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
							
						END FOREACH;	
					ELSE 
						
						LET cCodRet = '01289'; --No existe informacion. Favor de verificar					
						RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
					
					END IF;
					
					
			ELIF pTipoConsulta = 3 THEN
					IF (SELECT count(c.fecha_cita) FROM bdicheq:"informix".sc_citasagendadas c, bdicheq:"informix".sc_catestatustramitecitas q  WHERE DATE(c.fecha_cita) >= DATE(CURRENT) AND DATE(c.fecha_cita) <= DATE(CURRENT + 7 units DAY)AND q.descripcion in (sST,sST1,sST2) AND c.status = q.idestatus)> 0 THEN

						FOREACH
						
							-- una semana
							SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
							  FROM bdicheq:"informix".sc_citasagendadas c, 
								   bdicheq:"informix".sc_maechq n,
								   bdicheq:"informix".sc_producto p,
								   bdicheq:"informix".sc_catestatustramitecitas q
							 WHERE DATE(fecha_cita) >= DATE(CURRENT) 
							   AND DATE(fecha_cita) <= DATE(CURRENT + 7 UNITS DAY)
							   AND c.numcte = n.num_cte
							   AND q.descripcion IN (sST,sST1,sST2)
							   AND c.num_cuenta = n.cuenta
							   AND n.producto =  p.producto
							   AND c.status = q.idestatus
							GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
							
							RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
							
						END FOREACH;	
					ELSE 
					
					LET cCodRet = '01289'; --No existe informacion. Favor de verificar
					RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;

					END IF;

			ELIF pTipoConsulta = 4 THEN
					IF(SELECT count(c.fecha_cita) FROM bdicheq:"informix".sc_citasagendadas c, bdicheq:"informix".sc_catestatustramitecitas q  WHERE DATE(c.fecha_cita) >= DATE(CURRENT) AND DATE(c.fecha_cita) <= DATE(CURRENT + 30 UNITS DAY) AND q.descripcion IN (sST,sST1,sST2) AND c.status = q.idestatus ) > 0 THEN

						FOREACH
							-- un mes
							SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
							  FROM bdicheq:"informix".sc_citasagendadas c, 
								   bdicheq:"informix".sc_maechq n,
								   bdicheq:"informix".sc_producto p,
								   bdicheq:"informix".sc_catestatustramitecitas q
							 WHERE DATE(fecha_cita) >= DATE(CURRENT)
							   AND DATE(fecha_cita) <= DATE(CURRENT + 30 UNITS DAY)
							   AND c.numcte = n.num_cte
							   AND q.descripcion IN (sST,sST1,sST2)
							   AND c.num_cuenta = n.cuenta
							   AND n.producto =  p.producto
							   AND c.status = q.idestatus
							GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
							ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
							
							RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
							
						END FOREACH;	
					ELSE 
					
					LET cCodRet = '01289'; --No existe informacion. Favor de verificar
					RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;

					END IF;	
			ELSE	
				LET cCodRet = '01289'; --No existe informacion. Favor de verificar
				RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
				
			END IF;
	-- Por numero de cliente
	ELIF (pTipoBusqueda = 6) THEN
		
		IF NVL(pNumCte,"") <> "" THEN
			IF (SELECT count(fecha_cita) FROM bdicheq:"informix".sc_citasagendadas WHERE numcte = pNumCte )> 0 THEN

				FOREACH						
					
					    SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
						  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
						  FROM bdicheq:"informix".sc_citasagendadas c, 
							   bdicheq:"informix".sc_maechq n,
							   bdicheq:"informix".sc_producto p,
							   bdicheq:"informix".sc_catestatustramitecitas q
						 WHERE c.numcte = pNumCte
						   AND c.numcte = n.num_cte
						   AND c.num_cuenta = n.cuenta
						   AND n.producto =  p.producto
						   AND c.status = q.idestatus
						 GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
						 ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
					

						RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
					
				END FOREACH;	
			ELSE 
				LET cCodRet = '01289'; --No existe informacion. Favor de verificar
				RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
			END IF;	
		ELSE
			LET cCodRet = '00051'; --Parametros Vacios
			RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
		END IF;

	ELIF (pTipoBusqueda = 7) THEN
	
		IF NVL(pNumCta,"") <> "" THEN
	
			IF (SELECT count(fecha_cita) FROM bdicheq:"informix".sc_citasagendadas WHERE num_cuenta = pNumCta )>0 THEN

				FOREACH						
					
					    SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
						  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
						  FROM bdicheq:"informix".sc_citasagendadas c, 
							   bdicheq:"informix".sc_maechq n,
							   bdicheq:"informix".sc_producto p,
							   bdicheq:"informix".sc_catestatustramitecitas q
						 WHERE c.num_cuenta = pNumCta
						   AND c.numcte = n.num_cte
						   AND c.num_cuenta = n.cuenta
						   AND n.producto =  p.producto
						   AND c.status = q.idestatus
						 GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
						 ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita
					
					RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
					
				END FOREACH;	

			ELSE 
				LET cCodRet = '01289'; --No existe informacion. Favor de verificar
				RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
			END IF;	
		ELSE
			LET cCodRet = '00051'; --Parametros Vacios
			RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
		END IF;
		
	ELIF (pTipoBusqueda = 8) THEN	
		IF NVL(pCuentaClabe,"") <> "" THEN
		
			IF (SELECT COUNT (cuenta_clabe)	FROM bdicheq:"informix".sc_maechq WHERE empresa = '001' AND cuenta_clabe = pCuentaClabe AND status_cta = '0') > 0 THEN			
					
					LET cCodret = '01284';
					RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
					
			ELSE	
					EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCuentaClabe) INTO sRetorno,sdigitover;	
					
						IF sRetorno = '0' AND 	sdigitover = '1' THEN
						
							IF(SELECT count(fecha_cita) FROM bdicheq:"informix".sc_citasagendadas WHERE num_cuenta = (SELECT cuenta FROM SC_MAECHQ WHERE cuenta_clabe = pCuentaClabe) ) > 0 THEN							
								
								FOREACH						
								
									SELECT SKIP pskip c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
										  INTO sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones
										  FROM bdicheq:"informix".sc_citasagendadas c, 
											   bdicheq:"informix".sc_maechq n,
											   bdicheq:"informix".sc_producto p,
											   bdicheq:"informix".sc_catestatustramitecitas q
										 WHERE c.num_cuenta = (SELECT cuenta FROM SC_MAECHQ WHERE cuenta_clabe = pCuentaClabe)
										   AND c.numcte = n.num_cte
										   AND c.num_cuenta = n.cuenta
										   AND n.producto =  p.producto
										   AND c.status = q.idestatus
										GROUP BY c.secuencia,c.fecha_cita,c.sucursal,c.numcte,c.nombre_cte,c.num_cuenta,p.nombre,q.descripcion,c.tramite,c.hora_cita,c.observaciones
										ORDER BY c.sucursal, c.numcte, c.fecha_cita, c.hora_cita

									RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones WITH RESUME;
									
								END FOREACH;	
								
								
							ELSE 
								LET cCodRet = '01289'; --No existe informacion. Favor de verificar
								RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
							END IF;
						ELSE				
							LET cCodRet = '01283'; --No existe informacion. Favor de verificar
							RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
							
						END IF;		
			END IF;
		ELSE
			LET cCodRet = '00051'; --Parametros Vacios
			RETURN cCodRet,sSecuencia,dFechaCita,sSucursal,sNumeroCliente,sNombreCliente,sNumeroCuenta,sTipoCuenta,sEstatus,sTramite,sHoraCita,sObservaciones;
		END IF;			
	
	END IF;	
END;
END PROCEDURE
DOCUMENT
'000000 - Exitoso',
'DESCRIPCION: Se crea sp para para realizar la consulta de las citas para productos nÃÂ³mina.',
'AUTOR : Omar Lerma Velazquez',
'PETICION: 255',
'SUSTENTO: RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de  Nomina en Sucursales.pdf',
'SOLICITA: Abraham Navaez',
'FECHA : 21/07/2017',
'BD: bdicheq';

CREATE PROCEDURE "informix".val_cheque_doc_web( pempresa   char(3), -- Empresa
                                            pcodigosss char(3), -- codigo seguridad
                                            ptransito  char(11), -- transito
                                            pcuenta    char(20), -- Cuenta
                                            pnumcheq   integer -- No. Cheque
                                            )
RETURNING     CHAR(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              val_cheque_doc
   --
   -- Version              1.0.1
   -- Objetivo:            Valida la informacion de la banda de un cheque ...................
   -- Supuestos:           Ninguno
   -- Creado por:          Alejandro Rueda Sanchez
   -- ModIFicado por:
   -- Ultima ModIFicacion: Febrero  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE i               smallint;
   DEFINE vdummy          char(100);
   DEFINE vfecha_hoy   	  DATE;
   DEFINE vhora           char(15);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vestado 	  CHAR(1);
   DEFINE vcodigosss 	  CHAR(3);
   DEFINE vcheque    	  CHAR(7);
   DEFINE vtransito    	  CHAR(7);
   DEFINE vsemilla     	  smallint;
   DEFINE vnumcheq     	  CHAR(11);
   DEFINE vsumacheque  	  INTEGER;
   DEFINE vsumafactor1	  INTEGER;
   DEFINE vprimerdigito	  INTEGER;
   DEFINE vsegundodigito  INTEGER;
   DEFINE vtercerdigito	  INTEGER;

   --Variables para el algoritmo SSS
   DEFINE vtransito1      SMALLINT;
   DEFINE vtransito2      SMALLINT;
   DEFINE vtransito3      SMALLINT;
   DEFINE vtransito4      SMALLINT;
   DEFINE vtransito5      SMALLINT;
   DEFINE vtransito6      SMALLINT;
   DEFINE vtransito7      SMALLINT;
   DEFINE vtransito8      SMALLINT;
   DEFINE vtransito9      SMALLINT;
   DEFINE vtransito10     SMALLINT;
   DEFINE vtransito11     SMALLINT;


   DEFINE vcuenta1        SMALLINT;
   DEFINE vcuenta2        SMALLINT;
   DEFINE vcuenta3        SMALLINT;
   DEFINE vcuenta4        SMALLINT;
   DEFINE vcuenta5        SMALLINT;
   DEFINE vcuenta6        SMALLINT;
   DEFINE vcuenta7        SMALLINT;
   DEFINE vcuenta8        SMALLINT;
   DEFINE vcuenta9        SMALLINT;
   DEFINE vcuenta10       SMALLINT;
   DEFINE vcuenta11       SMALLINT;

   DEFINE vcheque1        SMALLINT;
   DEFINE vcheque2        SMALLINT;
   DEFINE vcheque3        SMALLINT;
   DEFINE vcheque4        SMALLINT;
   DEFINE vcheque5        SMALLINT;
   DEFINE vcheque6        SMALLINT;
   DEFINE vcheque7        SMALLINT;
   DEFINE vcheque8        SMALLINT;
   DEFINE vcheque9        SMALLINT;
   DEFINE vcheque10       SMALLINT;
   DEFINE vcheque11       SMALLINT;

   DEFINE vsuma1          SMALLINT;
   DEFINE vsuma2          SMALLINT;
   DEFINE vsuma3          SMALLINT;
   DEFINE vsuma4          SMALLINT;
   DEFINE vsuma5          SMALLINT;
   DEFINE vsuma6          SMALLINT;
   DEFINE vsuma7          SMALLINT;
   DEFINE vsuma8          SMALLINT;
   DEFINE vsuma9          SMALLINT;
   DEFINE vsuma10         SMALLINT;
   DEFINE vsuma11         SMALLINT;

   DEFINE vfactor1        SMALLINT;
   DEFINE vfactor2        SMALLINT;
   DEFINE vfactor3        SMALLINT;
   DEFINE vfactor4        SMALLINT;
   DEFINE vfactor5        SMALLINT;
   DEFINE vfactor6        SMALLINT;
   DEFINE vfactor7        SMALLINT;
   DEFINE vfactor8        SMALLINT;
   DEFINE vfactor9        SMALLINT;
   DEFINE vfactor10       SMALLINT;
   DEFINE vfactor11       SMALLINT;

   DEFINE vdigito1        SMALLINT;
   DEFINE vdigito2        SMALLINT;
   DEFINE vdigito3        SMALLINT;

   LET vcodret    = " ";
   LET vsqlerr    = 0;
   LET vdummy     = " ";
   LET vestado    = " ";
   LET vcodigosss    = " ";

   LET vtransito1 = 0;
   LET vtransito2 = 0;
   LET vtransito3 = 0;
   LET vtransito4 = 0;
   LET vtransito5 = 0;
   LET vtransito6 = 0;
   LET vtransito7 = 0;
   LET vtransito8 = 0;
   LET vtransito9 = 0;
   LET vtransito10= 0;
   LET vtransito11= 0;
   LET vcuenta1   = 0;
   LET vcuenta2   = 0;
   LET vcuenta3   = 0;
   LET vcuenta4   = 0;
   LET vcuenta5   = 0;
   LET vcuenta6   = 0;
   LET vcuenta7   = 0;
   LET vcuenta8   = 0;
   LET vcuenta9   = 0;
   LET vcuenta10  = 0;
   LET vcuenta11  = 0;
   LET vcheque1   = 0;
   LET vcheque2   = 0;
   LET vcheque3   = 0;
   LET vcheque4   = 0;
   LET vcheque5   = 0;
   LET vcheque6   = 0;
   LET vcheque7   = 0;
   LET vcheque8   = 0;
   LET vcheque9   = 0;
   LET vcheque10  = 0;
   LET vcheque11  = 0;
   LET vsuma1     = 0;
   LET vsuma2     = 0;
   LET vsuma3     = 0;
   LET vsuma4     = 0;
   LET vsuma5     = 0;
   LET vsuma6     = 0;
   LET vsuma7     = 0;
   LET vsuma8     = 0;
   LET vsuma9     = 0;
   LET vsuma10    = 0;
   LET vsuma11    = 0;
   LET vfactor1   = 0;
   LET vfactor2   = 0;
   LET vfactor3   = 0;
   LET vfactor4   = 0;
   LET vfactor5   = 0;
   LET vfactor6   = 0;
   LET vfactor7   = 0;
   LET vfactor8   = 0;
   LET vfactor9   = 0;
   LET vfactor10  = 0;
   LET vfactor11  = 0;
   LET vsumacheque = 0;
   LET vsumafactor1 = 0;
   -- SET DEBUG FILE TO "/tmp/val_cheque_doc.out";
   -- TRACE ON;

BEGIN
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END exception;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
   --//Validaciones en parametros de entrada
   IF pempresa = " " OR pcuenta = " " OR pcodigosss = " " OR pnumcheq = 0 OR
      ptransito = " " OR pnumcheq IS NULL  THEN
      LET vcodret = "00110";
      RETURN vcodret;
   END IF

   LET vdummy = "";
   --// Valida que la cuenta exista
   SELECT cuenta
     INTO vdummy
     FROM sc_maechq
    WHERE empresa = pempresa
      AND cuenta = pcuenta;

   IF vdummy = "" OR vdummy IS NULL THEN
      LET vcodret = "00100";
      RETURN vcodret;
   END IF

   --// Valida que el estatus sea vigente***
   SELECT estado
     INTO vestado
     FROM sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta
      AND numero = pnumcheq;

   --//Verifica que el cheque se encuentre activo ÃÂ³ presentado en ventanilla
   IF vestado NOT IN ("A","U") THEN
      IF vestado = "B" THEN --//Bloqueado x Autoridades
         LET vcodret = "00703";
      ELIF vestado = "C" THEN --//Cancelado
         LET vcodret = "00704";
      ELIF vestado = "D" THEN --//Destruido
         LET vcodret = "00705";
      ELIF vestado = "E" THEN --//Entregado
         LET vcodret = "00706";
      ELIF vestado = "F" THEN --//Fraudulento
         LET vcodret = "00707";
      ELIF vestado = "I" THEN --//Incompleto
         LET vcodret = "00708";
      ELIF vestado = "J" THEN --//Bloqueado x orden Judicial
         LET vcodret = "00709";
      ELIF vestado = "M" THEN --//Pagado x camara
         LET vcodret = "00710";
      ELIF vestado = "N" THEN --//Presentado x Camara
         LET vcodret = "00711";
      ELIF vestado = "P" THEN --//Pagado en Sucursal
         LET vcodret = "00712";
      ELIF vestado = "R" THEN --//Revocado
         LET vcodret = "00713";
      ELIF vestado = "S" THEN --//Solicitado
         LET vcodret = "00714";
      ELSE
         LET vcodret = "00715"; --//No definida
      END IF
      RETURN vcodret;
   END IF

   --// ****** Valida el codigo de seguridad SSS ******
   --// Selecciona la semilla
   SELECT valor
     INTO vsemilla
     FROM bdicntchq:sq_param
    WHERE cod_param = 20;

   LET pcuenta = LPAD(trim(pcuenta), 11,"0");
   LET vnumcheq = LPAD(pnumcheq::varchar(11), 11,"0");
   LET ptransito = LPAD(trim(ptransito), 11,"0");
   FOR i = 1 to 11
       IF i = 1 THEN
	  LET vtransito1 = ptransito[1,1];
	  LET vcuenta1 = pcuenta[1,1];
	  LET vcheque1 = vnumcheq[1,1];
          LET vsuma1 = vtransito1 + vcuenta1;
          LET vfactor1 = MOD((vsuma1 * (vsemilla - vcheque1)),10);
       ELIF i = 2 THEN
	  LET vtransito2 = ptransito[2,2];
	  LET vcuenta2 = pcuenta[2,2];
	  LET vcheque2 = vnumcheq[2,2];
          LET vsuma2 = vtransito2 + vcuenta2;
          LET vfactor2 = MOD((vsuma2 * (vsemilla - vcheque2)),10);
       ELIF i = 3 THEN
	  LET vtransito3 = ptransito[3,3];
	  LET vcuenta3 = pcuenta[3,3];
	  LET vcheque3 = vnumcheq[3,3];
          LET vsuma3 = vtransito3 + vcuenta3;
          LET vfactor3 = MOD((vsuma3 * (vsemilla - vcheque3)),10);
       ELIF i = 4 THEN
	  LET vtransito4 = ptransito[4,4];
	  LET vcuenta4 = pcuenta[4,4];
	  LET vcheque4 = vnumcheq[4,4];
          LET vsuma4 = vtransito4 + vcuenta4;
          LET vfactor4 = MOD((vsuma4 * (vsemilla - vcheque4)),10);
       ELIF i = 5 THEN
	  LET vtransito5 = ptransito[5,5];
	  LET vcuenta5 = pcuenta[5,5];
	  LET vcheque5 = vnumcheq[5,5];
          LET vsuma5 = vtransito5 + vcuenta5;
          LET vfactor5 = MOD((vsuma5 * (vsemilla - vcheque5)),10);
       ELIF i = 6 THEN
	  LET vtransito6 = ptransito[6,6];
	  LET vcuenta6 = pcuenta[6,6];
	  LET vcheque6 = vnumcheq[6,6];
          LET vsuma6 = vtransito6 + vcuenta6;
          LET vfactor6 = MOD((vsuma6 * (vsemilla - vcheque6)),10);
       ELIF i = 7 THEN
	  LET vtransito7 = ptransito[7,7];
	  LET vcuenta7 = pcuenta[7,7];
	  LET vcheque7 = vnumcheq[7,7];
          LET vsuma7 = vtransito7 + vcuenta7;
          LET vfactor7 = MOD((vsuma7 * (vsemilla - vcheque7)),10);
       ELIF i = 8 THEN
	  LET vtransito8 = ptransito[8,8];
	  LET vcuenta8 = pcuenta[8,8];
	  LET vcheque8 = vnumcheq[8,8];
          LET vsuma8 = vtransito8 + vcuenta8;
          LET vfactor8 = MOD((vsuma8 * (vsemilla - vcheque8)),10);
       ELIF i = 9 THEN
	  LET vtransito9 = ptransito[9,9];
	  LET vcuenta9 = pcuenta[9,9];
	  LET vcheque9 = vnumcheq[9,9];
          LET vsuma9 = vtransito9 + vcuenta9;
          LET vfactor9 = MOD((vsuma9 * (vsemilla - vcheque9)),10);
       ELIF i = 10 THEN
	  LET vtransito10 = ptransito[10,10];
	  LET vcuenta10 = pcuenta[10,10];
	  LET vcheque10 = vnumcheq[10,10];
          LET vsuma10 = vtransito10 + vcuenta10;
          LET vfactor10 = MOD((vsuma10 * (vsemilla - vcheque10)),10);
       ELIF i = 11 THEN
	  LET vtransito11 = ptransito[11,11];
	  LET vcuenta11 = pcuenta[11,11];
	  LET vcheque11 = vnumcheq[11,11];
          LET vsuma11 = vtransito11 + vcuenta11;
          LET vfactor11 = MOD((vsuma11 * (vsemilla - vcheque11)),10);
       END IF
   END FOR

   --//Calculando el primer digito tenemos lo siguiente....
   LET vsumacheque = vcheque1 + vcheque2 + vcheque3 + vcheque4 + vcheque5 +
                     vcheque6 + vcheque7 + vcheque8 + vcheque9 + vcheque10 + vcheque11;
   LET vsumafactor1 = vfactor1 + vfactor2 + vfactor3 + vfactor4 + vfactor5;

   LET vprimerdigito = MOD((vsumacheque + vsumafactor1) * 3,10);

   --//Calculando el segundo digito tenemos lo siguiente....
   LET vsumafactor1 = vfactor4 + vfactor5 + vfactor6 + vfactor7 + vfactor8;

   LET vsegundodigito = MOD((vsumacheque + vsumafactor1) * 7,10);

   --//Calculando el tercer digito tenemos lo siguiente....
   LET vsumafactor1 = vfactor7 + vfactor8 + vfactor9 + vfactor10 + vfactor11;

   LET vtercerdigito = MOD((vsumacheque + vsumafactor1) * 13,10);

   LET vcodigosss = vprimerdigito||vsegundodigito||vtercerdigito;
   --//Verifica el codigo de seguridad calculado vs pcodigosss
   IF vcodigosss <> pcodigosss THEN
      LET vcodret = "00702";
      RETURN vcodret;
   END IF

   LET vcodret = "00000";
   RETURN vcodret;
end
END procedure;