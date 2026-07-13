CREATE PROCEDURE "informix".sp_altamodificacion_piezas_bym(pOpcion CHAR(1), pIdDenominacion INTEGER,pNumRecibo CHAR(10), pTipoPieza CHAR(1), pSerie CHAR(40), pFolio CHAR(40), pFechaEmision DATE, pNumPiezas INTEGER, pNota CHAR(200), pNumGuia CHAR(12),pFolioBanxico CHAR(40), pDictamenBanxico INTEGER,pNumLoteBanxico CHAR(40), pEstatus INTEGER, pEjecutivo CHAR(8), pIdPieza INTEGER)
RETURNING   CHAR(6) AS CodRet,
            CHAR(80) AS Mensaje ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE iIsamErr        	    INTEGER;
DEFINE cErrorInfo      	    CHAR(30);	
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje             CHAR(80);
DEFINE cMensaje1			CHAR(80);

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet             = '000000';
LET cMensaje            ='Ejecución Exitosa';
LET cMensaje1            ="";


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/sp_altamodificacion_piezas_bym.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iIsamErr, cErrorInfo
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cErrorInfo;
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' OR TRIM(NVL(pOpcion,'')) = '3' OR TRIM(NVL(pOpcion,'')) = '4' OR TRIM(NVL(pOpcion,'')) = '5' THEN
		
		IF TRIM(NVL(pOpcion,'')) = '1' THEN
			IF NVL(pIdDenominacion,0) > 0 AND  TRIM(NVL(pNumRecibo,'')) <> '' AND NVL(pNumPiezas,0) > 0 AND NVL(pEstatus,0) > 0 AND  TRIM(NVL(pTipoPieza,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' THEN
			
				IF pTipoPieza = '1' THEN
					IF TRIM(NVL(pSerie,'')) = '' OR TRIM(NVL(pFolio,'')) = '' OR TRIM(NVL(pFechaEmision,'')) = '' THEN
						LET cCodRet  = '000001';
						LET cMensaje = 'Parámetros de Entrada Vacíos';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					INSERT INTO bdisuc:"informix".ss_piezas_bym_falsos (id_denominacion, num_recibo, fecha_recepcion, serie, folio, fecha_emision, num_piezas, nota, estatus, ejecutivo_insert, fecha_insert)
					VALUES (pIdDenominacion, pNumRecibo, CURRENT, Pserie, pFolio, pFechaEmision, pNumPiezas, pNota, pEstatus, pEjecutivo, CURRENT);
				END IF;
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
			
		ELIF TRIM(NVL(pOpcion,'')) = '2' THEN
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0) > 0 AND TRIM(NVL(pTipoPieza,''))<>'' THEN
				IF TRIM(NVL(pTipoPieza,''))=1 THEN
					IF TRIM(NVL(pSerie,'')) <> '' AND TRIM(NVL(pFolio,'')) <> '' AND TRIM(NVL(pFechaEmision,'')) <> '' AND TRIM(NVL(pEstatus,'')) <> '' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET serie=TRIM(NVL(pSerie,'')), folio=TRIM(NVL(pFolio,'')), fecha_emision=TRIM(NVL(pFechaEmision,'')),
							ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT ,Estatus = pEstatus
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
					END IF
				END IF
				IF NVL(pIdDenominacion,0) > 0  THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET id_denominacion=NVL(pIdDenominacion,0),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
				IF NVL(pNumPiezas,0) > 0 THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET num_piezas=NVL(pNumPiezas,0),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				IF TRIM(NVL(pFolioBanxico,''))<>'' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET folio_banxico=TRIM(NVL(pFolioBanxico,'')),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
				IF TRIM(NVL(pNumLoteBanxico,''))<>'' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET num_lote_banxico=TRIM(NVL(pNumLoteBanxico,'')),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
		ELIF TRIM(NVL(pOpcion,'')) = '3' THEN
		
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pNumGuia,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' THEN
			
				UPDATE bdisuc:"informix".ss_piezas_bym_falsos
				SET num_guia = pNumGuia,
					ejecutivo_update = pEjecutivo,
					fecha_update = CURRENT
				WHERE num_recibo = pNumRecibo
				AND TRIM(NVL(num_guia,''))=''; 
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
		ELIF TRIM(NVL(pOpcion,'')) = '4' THEN
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0) > 0 AND NVL(pEstatus,0) > 0  THEN
				UPDATE  bdisuc:"informix".ss_piezas_bym_falsos
				SET estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
				WHERE num_recibo = pNumRecibo 
				AND id_pieza = pIdPieza;
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF
		ELIF TRIM(NVL(pOpcion,'')) = '5' THEN
			IF TRIM(NVL(pFolioBanxico,''))<>'' AND TRIM(NVL(pNumLoteBanxico,''))<>'' AND NVL(pDictamenBanxico,0)>0 AND NVL(pEstatus,0)>0 AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0)>0 THEN
				IF (SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE id_pieza = pIdPieza AND estatus=2 AND empresa='001')>0 THEN
					UPDATE  bdisuc:"informix".ss_piezas_bym_falsos
					SET folio_banxico=TRIM(NVL(pFolioBanxico,'')), num_lote_banxico=TRIM(NVL(pNumLoteBanxico,'')), dictamen_banxico=NVL(pDictamenBanxico,0),
						estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
					WHERE id_pieza = pIdPieza
					AND empresa='001';
				ELSE
					LET cCodRet  = '000002';
				END IF
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF
		END IF;

	ELSE
		LET cCodRet  = '000001';
		LET cMensaje = 'Parámetros de Entrada Vacíos';
	END IF;
	
	IF TRIM(NVL(pOpcion,''))='2' THEN
		IF cCodRet='000000' THEN
			LET cMensaje="";
			
				SELECT descripcion 
				INTO cMensaje1
				FROM bdinteg:"informix".si_codret WHERE codigo_retorno ='265'
				AND sistema='11';
			
			LET cMensaje= TRIM(cMensaje1);

				SELECT descripcion 
				INTO cMensaje1
				FROM bdinteg:"informix".si_codret WHERE codigo_retorno ='266'
				AND sistema='11';
			LET cMensaje= TRIM(cMensaje)  || ' ' || TRIM(cMensaje1);
		END IF
	ELIF TRIM(NVL(pOpcion,''))='4' THEN
		IF cCodRet='000000' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='263'
			AND sistema='11';
		END IF
	ELIF TRIM(NVL(pOpcion,''))='5' THEN
		IF cCodRet='000000' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='262'
			AND sistema='11';
		ELIF cCodRet='000002' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='264'
			AND sistema='11';
		END IF
	END IF
	RETURN cCodRet,  cMensaje;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'MODIFICO: Leslie Rendón',
'DESCRIPCION: Guarda y actualiza los datos de la tabla ss_piezas_bym_falsos.',
'FECHA: 03/06/2015',
'MODIFICO: Felipe Urias',
'DESCRIPCION:  se modifica la opcion 5 para que solo se actualizen los registros con estatus 2',
'FECHA: 04/04/2016',
'DESCRIPCION : se modifica la opcion 2 para que actualizen los estatus de capturado a cancelado',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_entrada_salida2_total(eEmpresa    CHAR(3),
                                              eTipo       CHAR(1), 
                                              eSucursal   CHAR(4),
                                              ePlaza      CHAR(3),
                                              eFecInicio  DATE,
                                              eFecFin     DATE,
                                              eMes        CHAR(2),
                                              eAnio       CHAR(4),
                                              eStatus     CHAR(2))
RETURNING CHAR(5)    ,          --CodRet
          INTEGER;              --Total de registros

 DEFINE vCodRet       CHAR(5);
 DEFINE vCajGen       CHAR(1);
 DEFINE vRegistros    INTEGER;


 LET vCodRet       = "000";
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET vCajGen = 'N';
 LET vRegistros = 0;

-- SET DEBUG FILE TO "/tmp/entrasal.out";
--TRACE ON;

--SET LOCK MODE TO WAIT 4;
SET ISOLATION TO DIRTY READ;

   IF eTipo = 'C' THEN
    LET vCajGen = eTipo;
   END IF;

  IF ePlaza <> '000' AND eSucursal = '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	   FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor; 

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal = '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;
	  
	  RETURN vcodret, vRegistros;

 ELSE
		IF eMes <> '' AND eAnio <> '' THEN
			  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
			  INTO  vRegistros
			  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
									  WHERE a.cod_trans != '0'                      
				AND (MONTH(a.fecha_operacion) = eMes AND YEAR(a.fecha_operacion) = eAnio)
										AND a.sucursal IN (SELECT sucursal 
																		 FROM bdinteg:"informix".si_sucursales  
																		WHERE sucursal != '0'
																		  AND empresa = eEmpresa
																			  AND (tpo_sucursal = eTipo OR  tpo_sucursal = vCajGen))
											AND a.reversado IN ('0','1')
											AND a.folio_oper    = b.folio_oper   
				AND c.cod_proveedor = b.cod_proveedor;
			  
			  RETURN vcodret, vRegistros;
		END IF;
  END IF;

END PROCEDURE;