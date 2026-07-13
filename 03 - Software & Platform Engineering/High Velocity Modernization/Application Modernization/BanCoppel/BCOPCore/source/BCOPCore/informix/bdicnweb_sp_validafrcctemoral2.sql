CREATE PROCEDURE "informix".sp_validafrcctemoral2(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(14), pTipoCte CHAR(1))
                RETURNING CHAR(5) AS codret;            
                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;       
        DEFINE iTotal INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;  
        LET iTotal = 0;

        BEGIN   
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_validafrcctemoral2.out';
                -- TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' OR pTipoCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                IF pTipoCte NOT IN('M','F') THEN
                        LET cCodRet = '00313';
                        RETURN cCodRet;
                END IF;                      
                
                --SE COMPRUEBA QUE EL RFC NO ESTE ASIGNADO YA A OTRO CLIENTE
                SELECT FIRST 1 1 INTO iTotal  FROM  bdinteg:si_cliente WHERE rfc= pRfc and tpo_persona='02';
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					SELECT FIRST 1 1 INTO iTotal FROM  bdinteg:si_cliente WHERE rfc_alterno= pRfc and tpo_persona='02';
				END IF;
	
                
                IF iTotal > 0 THEN
                        LET cCodRet = '00291';
                        RETURN cCodRet;
                END IF;
        
                RETURN cCodRet; 
        END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 27/05/2014',
'DESCRIPCION: Valida la formato y armado del rfc de un cliente persona moral',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/10/2021',
'DESCRIPCION: Se clona sp y se deja solo la parte de validar si existe en la tabla si_cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consfoliooperacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS folio_oper;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolioOper CHAR(8);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFolioOper = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFolioOper;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consfoliooperacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFolioOper;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cFolioOper;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFolioOper;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT {+INDEX (bdisuc:ss_mae_entradasalida idx01ss_mae_entradasalida)} SKIP pRegistros FIRST pRecuperacion folio_oper 
			INTO cFolioOper
			FROM bdisuc:"informix".ss_mae_entradasalida 
			WHERE sucursal = pSucursal AND fecha_solicitud = pFecha
			ORDER BY folio_oper ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cFolioOper WITH RESUME;
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01275';
			RETURN cCodRet,cFolioOper;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cFolioOper;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo Folio Operación.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacentrocostos(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipo CHAR(1), pPlaza CHAR(3),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(4)	AS clave,
				  CHAR(45)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(4);
	DEFINE cDescripcion CHAR(45);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacentrocostos.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo ='' OR pPlaza ='' OR pRecuperacion ='' OR pRegistros=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} SKIP pRegistros FIRST pRecuperacion 
			sucursal, sucursal||' ' ||UPPER(nombre)
			INTO cClave, cDescripcion FROM bdinteg:"informix".si_sucursales
			WHERE tpo_sucursal = pTipo AND plaza_cajagen = pPlaza
            ORDER BY sucursal
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cClave, cDescripcion WITH RESUME;
        END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cClave,cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave,cDescripcion;
		END IF;	

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar las sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultacentrocostos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pTipo CHAR(1), pPlaza CHAR(3))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS total;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal  INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultacentrocostos_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pPlaza = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotal;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} COUNT(*)
		INTO iTotal FROM bdinteg:"informix".si_sucursales
		WHERE tpo_sucursal = pTipo AND plaza_cajagen = pPlaza;        
	
		RETURN cCodRet, iTotal;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar el total de las sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaplaza(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(3)	AS clave,
				  CHAR(40)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaplaza.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;

		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion 
			plaza, plaza||' ' ||UPPER(descripcion)
			INTO cClave, cDescripcion FROM bdisuc:"informix".ss_proveedores
            ORDER BY plaza
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cClave, cDescripcion WITH RESUME;
        END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cClave,cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave,cDescripcion;
		END IF;	

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar las plazas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultaplaza_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS total;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultaplaza_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotal;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
         
        SELECT COUNT(*)
		INTO iTotal FROM bdisuc:"informix".ss_proveedores;
		
		RETURN cCodRet, iTotal;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: Caja General',
'FUNCIONALIDAD: Reverso de transacciones',
'DESCRIPCION: SPL encargado de consultar el total de las plazas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_consultatipocc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS tipo,
		CHAR(40) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cDescrip CHAR(40);
	DEFINE cTipo CHAR(2);
	DEFINE iTotal INTEGER; 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cDescrip = '';
	LEt cTipo = '';
	LET iTotal= 0;
 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipo,cDescrip;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultatipocc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipo,cDescrip;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipo,cDescrip;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
		SELECT tipo,descripcion
		INTO cTipo,cDescrip
		FROM "informix".sw_cg_catalogotipocc
		ORDER BY tipo ASC

		LET iTotal = iTotal+1;
		
		RETURN cCodRet,cTipo,cDescrip WITH RESUME;	
		END FOREACH;
					
		IF iTotal=0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipo,cDescrip;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/11/2021',
'MODULO: OPERACIONES',
'DESCRIPCION: SPL encargado de recuperar el catalogo de los centros de costos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacora(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaDel DATE, pFechaAl DATE, pNumUsuario CHAR(8), pOperacion CHAR(20),
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_modificacion,
			CHAR(4) AS sucursal,
			CHAR(8) AS folio_operacion,
			CHAR(25) AS tipo_operacion,
			MONEY(16,2) AS monto,
			CHAR(8) AS usuario,
			CHAR(20) AS reverso_cambio;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha_modificacion DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_operacion CHAR(8);
	DEFINE cTipo_operacion CHAR(25);
	DEFINE mMonto MONEY(16,2);
	DEFINE cUsuario CHAR(8);
	DEFINE cReverso_cambio CHAR(20);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha_modificacion = '';
	LET cSucursal = '';
	LET cFolio_operacion = '';
	LET cTipo_operacion = '';
	LET mMonto = 0.00;
	LET cUsuario = '';
	LET cReverso_cambio = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
		IF pOperacion='TODAS' THEN 
			LET pOperacion ='';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pNumUsuario = '' AND pOperacion = '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = usuario
				AND reverso_cambio = reverso_cambio
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario <> '' AND pOperacion = '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = pNumUsuario
				AND reverso_cambio = reverso_cambio
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario = '' AND pOperacion <> '' THEN	
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = usuario
				AND reverso_cambio = pOperacion
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
			
		ELIF pNumUsuario <> '' AND pOperacion <> '' THEN
			FOREACH
				SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} SKIP pRegistros FIRST pRecuperacion 
				fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio
				INTO dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio
				FROM bdisuc:"informix".ss_bitacora_reversoscg
				WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
				AND usuario = pNumUsuario
				AND reverso_cambio = pOperacion
				ORDER BY fecha_modificacion ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio WITH RESUME;
			END FOREACH;
		END IF;
			
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha_modificacion,cSucursal,cFolio_operacion,cTipo_operacion,mMonto,cUsuario,cReverso_cambio;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 14/02/2021',
'DESCRIPCION: Se realiza tratamiento para el parametro pOperacion TODAS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_detallebitacora_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaDel DATE, pFechaAl DATE, pNumUsuario CHAR(8), pOperacion CHAR(20))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detallebitacora_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDel IS NULL OR pFechaAl IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		IF pOperacion='TODAS' THEN 
			LET pOperacion ='';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		IF pNumUsuario = '' AND pOperacion = '' THEN
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = usuario
			AND reverso_cambio = reverso_cambio;
		ELIF pNumUsuario <> '' AND pOperacion = '' THEN
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = pNumUsuario
			AND reverso_cambio = reverso_cambio;
		ELIF pNumUsuario = '' AND pOperacion <> '' THEN	
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = usuario
			AND reverso_cambio = pOperacion;
		ELIF pNumUsuario <> '' AND pOperacion <> '' THEN	
			SELECT {+INDEX (bdisuc:ss_bitacora_reversoscg idx_ss_bitacora_reversoscg)} COUNT  (*)
			INTO iNumRegistros
			FROM bdisuc:"informix".ss_bitacora_reversoscg
			WHERE fecha_modificacion BETWEEN pFechaDel AND pFechaAl 
			AND usuario = pNumUsuario
			AND reverso_cambio = pOperacion;
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'DESCRIPCION: SPL encargado de consultar el detalle de la bitÃ¡cora de Reversos y Cambios de Estatus.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 14/02/2021',
'DESCRIPCION: Se realiza tratamiento para el parametro pOperacion TODAS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportehistoricomovcapcre(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2), pFechaInicial DATE, pFechaFinal DATE, pCancelado CHAR(1), pNumCliente CHAR(20), 
		pCccMayor CHAR(10), pCccSub CHAR(10), pCccSubsub CHAR(10), pCccSssub CHAR(10), pCccSsssub CHAR(10),
		pAccMayor CHAR(10), pAccSub CHAR(10), pAccSubsub CHAR(10), pAccSssub CHAR(10), pAccSsssub CHAR(10),
		pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta,
		CHAR(4) AS sucursal,
		CHAR(20) AS num_cliente,
		CHAR(4) AS producto,
		MONEY(18,2) AS monto_total,
		CHAR(4) AS transaccion,
		CHAR(50) AS descripcion,
		CHAR(1) AS se_contabiliza,
		CHAR(10) AS c_cc_mayor,
		CHAR(10) AS c_cc_sub,
		CHAR(10) AS c_cc_subsub,
		CHAR(10) AS c_cc_sssub,
		CHAR(10) AS c_cc_ssssub,
		CHAR(10) AS a_cc_mayor,
		CHAR(10) AS a_cc_sub,
		CHAR(10) AS a_cc_subsub,
		CHAR(10) AS a_cc_sssub,
		CHAR(10) AS a_cc_ssssub,
		DATE AS fecha_alta,
		CHAR(3) AS codigo_fun, 
		INTEGER AS codigo_ref;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cNumCliente CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE mMontoTotal MONEY(14,2);
	DEFINE cTransaccion CHAR(4);
	DEFINE cDescripcion CHAR(50);
	DEFINE cSeContabiliza CHAR(1);
	DEFINE cCccMayor CHAR(10);
	DEFINE cCccSub CHAR(10);
	DEFINE cCccSubsub CHAR(10);
	DEFINE cCccSssub CHAR(10);
	DEFINE cCccSsssub CHAR(10);
	DEFINE cAccMayor CHAR(10);
	DEFINE cAccSub CHAR(10);
	DEFINE cAccSubsub CHAR(10);
	DEFINE cAccSssub CHAR(10);
	DEFINE cAccSsssub CHAR(10);
	DEFINE cAttrQry CHAR(500);
	DEFINE cAttrAliasQry CHAR(500);
	DEFINE cFromQry CHAR(500);
	DEFINE cWhereQry CHAR(500);
	DEFINE cAndQry CHAR(500);
	DEFINE cQry CHAR(1500);
	DEFINE cQryHist CHAR(1500);
	DEFINE dFechaAlt DATE;
	DEFINE cCodigoFun CHAR(3); 
	DEFINE iCodigoRef INTEGER;
	DEFINE cATR        CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCuenta = '';
	LET cSucursal = '';
	LET cNumCliente = '';
	LET cProducto = '';
	LET mMontoTotal = NULL;
	LET cTransaccion = '';
	LET cDescripcion = '';
	LET cSeContabiliza = '';
	LET cCccMayor = '';
	LET cCccSub = '';
	LET cCccSubsub = '';
	LET cCccSssub = '';
	LET cCccSsssub = '';
	LET cAccMayor = '';
	LET cAccSub = '';
	LET cAccSubsub = '';
	LET cAccSssub = '';
	LET cAccSsssub = '';
	LET cAttrQry = '';
	LET cAttrAliasQry = '';
	LET cFromQry = '';
	LET cWhereQry = '';
	LET cAndQry  = '';
	LET cQry = '';
	LET cQryHist = '';
	LET dFechaAlt = NULL;
	LET cCodigoFun = ''; 
	LET iCodigoRef = 0;
	LET cATR = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportehistoricomovcapcre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL 
			OR pFechaFinal IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validacción de acceso a la funcionalidad, dependiendo si trae numero de cliente o no
		IF pNumCliente = '' or pNumCliente = 'null' THEN
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		ELSE
			EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCliente, pSistemaCuenta, '2') INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		END IF;
		
		
		-- Validación de los parametros de paginado
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validación del sistema cuenta
		IF pSistemaCuenta NOT IN ('01', '06') THEN
			LET cCodRet = '00109';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		END IF;
		
		-- Validación del parametro de reversado
		IF pSistemaCuenta = '01' AND TRIM(pCancelado) <> '' AND pCancelado <> 'S' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
					cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
					dFechaAlt, cCodigoFun, iCodigoRef;
		ENd IF;
		
		-- Armado de los atributos
		IF pSistemaCuenta = '01' THEN
			LET cAttrAliasQry = 'cuenta, sucursal, num_cte, producto, monto_tot, transacc, descripcion, se_contabiliza, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, fech_alt, codfun, codref';
			LET cAttrQry = 'a.cuenta, a.sucursal, b.num_cte, a.producto, a.monto_tot, a.transacc, upper(c.descripcion) as descripcion, c.se_contabiliza, d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub, d.c_ccssssub, d.a_ccmayor, d.a_ccsub, d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, a.fech_alt, "" as codfun, 0 as codref';
			LET cFromQry = ', bdicheq:sc_maechq b, bdinteg:si_transacc c, bdinteg:si_prodtran d';
			LET cWhereQry = 'b.cuenta = a.cuenta and c.numero = a.transacc and d.transaccion = a.transacc and d.producto = a.producto and a.fech_alt between "'||pFechaInicial||'" and "'||pFechaFinal||'"';
			LET cAndQry = 'a.transacc in ("0283", "0282", "0887", "0881")';
			
			-- Movimientos reversados
			IF pCancelado = 'S' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and a.cancelad = 'S'";
			ELSE
				LET cWhereQry = TRIM(cWhereQry)||" and a.cancelad <> 'S'";
			END IF;
			
			IF pNumCliente <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and b.num_cte = '"||TRIM(pNumCliente)||"'";
			END IF;
			
			-- Cargos
			IF pCccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccmayor = '"||TRIM(pCccMayor)||"'";
			END IF;
			
			IF pCccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsub = '"||TRIM(pCccSub)||"'";
			END IF;
			
			IF pCccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsubsub = '"||TRIM(pCccSubsub)||"'";
			END IF;
			
			IF pCccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccsssub = '"||TRIM(pCccSssub)||"'";
			END IF;
			
			IF pCccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.c_ccssssub = '"||TRIM(pCccSsssub)||"'";
			END IF;
			
			-- Abonos
			IF pAccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccmayor = '"||TRIM(pAccMayor)||"'";
			END IF;
			
			IF pAccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsub = '"||TRIM(pAccSub)||"'";
			END IF;
			
			IF pAccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsubsub = '"||TRIM(pAccSubsub)||"'";
			END IF;
			
			IF pAccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccsssub = '"||TRIM(pAccSssub)||"'";
			END IF;
			
			IF pAccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and d.a_ccssssub = '"||TRIM(pAccSsssub)||"'";
			END IF;
			
			LET cQry = 'select '||TRIM(cAttrQry)||' from bdicheq:sc_movdia a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			LET cQryHist = 'select '||TRIM(cAttrQry)||' from bdicheq:sc_movhis a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			
		ELIF pSistemaCuenta = '06' THEN
			
			LET cAttrAliasQry = 'num_credito, sucursal, numcte, num_producto, monto, transacc, descripcion, se_contabiliza, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, fech_alt, codfun, codref';
			LET cAttrQry = 'a.num_credito, a.sucursal, b.numcte, a.num_producto, a.monto, c.transacc, upper(d.descripcion) as descripcion, d.se_contabiliza, e.c_ccmayor, e.c_ccsub, e.c_ccsubsub, e.c_ccsssub, e.c_ccssssub, e.a_ccmayor, e.a_ccsub, e.a_ccsubsub, e.a_ccsssub, e.a_ccssssub, a.fecha_mov as fech_alt, c.codigo_fun as codfun, c.codigo_ref as codref';
			LET cFromQry = ', bdicred:sd_maecred b, bdicred:sd_transfun c, bdinteg:si_transacc d, bdinteg:si_prodtran e';
			
			--Valida si esta activo el IFRS	
			select NVL(valor,'I') 
			  into cATR 
			  from bdicred:"informix".sd_param 
			 where cod_param = '700';
			
			IF (cATR = 'I') THEN 
				LET cWhereQry = 'b.num_credito = a.num_credito and c.codigo_fun = a.codigo_fun and c.transacc = a.transacc_suc and d.numero = c.transacc and e.transaccion = a.transacc_suc and e.sistema = "'||TRIM(pSistemaCuenta)||'" and a.fecha_mov between "'||pFechaInicial||'" and "'||pFechaFinal||'"';
			ELSE
				LET cWhereQry = 'b.num_credito = a.num_credito and c.codigo_fun = a.codigo_fun and c.transacc = a.transacc_suc and d.numero = c.transacc_ifrs and e.transaccion = c.transacc_ifrs and e.sistema = "'||TRIM(pSistemaCuenta)||'" and a.fecha_mov between "'||pFechaInicial||'" and "'||pFechaFinal||'"';			
			END IF;
			
			LET cAndQry = 'a.transacc_suc in ("7730", "6887", "6881", "6282")';
			
			-- Cargos
			IF pCccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccmayor = '"||TRIM(pCccMayor)||"'";
			END IF;
			
			IF pCccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsub = '"||TRIM(pCccSub)||"'";
			END IF;
			
			IF pCccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsubsub = '"||TRIM(pCccSubsub)||"'";
			END IF;
			
			IF pCccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccsssub = '"||TRIM(pCccSssub)||"'";
			END IF;
			
			IF pCccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.c_ccssssub = '"||TRIM(pCccSsssub)||"'";
			END IF;
			
			-- Abonos
			IF pAccMayor <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccmayor = '"||TRIM(pAccMayor)||"'";
			END IF;
			
			IF pAccSub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsub = '"||TRIM(pAccSub)||"'";
			END IF;
			
			IF pAccSubsub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsubsub = '"||TRIM(pAccSubsub)||"'";
			END IF;
			
			IF pAccSssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccsssub = '"||TRIM(pAccSssub)||"'";
			END IF;
			
			IF pAccSsssub <> '' THEN
				LET cWhereQry = TRIM(cWhereQry)||" and e.a_ccssssub = '"||TRIM(pAccSsssub)||"'";
			END IF;
			
			LET cQry = 'select '||TRIM(cAttrQry)||' from bdicred:sd_movdia a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
			LET cQryHist = 'select '||TRIM(cAttrQry)||' from bdicred:sd_movhis a'||TRIM(cFromQry)||' where '||TRIM(cWhereQry)||' and '||TRIM(cAndQry);
		END IF;
		
		-- Ejecución de la consulta
		PREPARE sqlQry FROM 'select skip '||pRegistros||' first '||pRecuperacion||' '||TRIM(cAttrAliasQry)||' from ('||TRIM(cQry)||' union '||TRIM(cQryHist)||') order by fech_alt';
		DECLARE sqlCur CURSOR FOR sqlQry;
		OPEN sqlCur;
			
		FETCH sqlCur INTO cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
				cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
				dFechaAlt, cCodigoFun, iCodigoRef;		
		
		IF SQLCODE == 100 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
			
			IF pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
			END IF;
		END IF;
		
		WHILE(SQLCODE == 0)
			RETURN cCodRet, cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef WITH RESUME;
			FETCH sqlCur INTO cCuenta, cSucursal, cNumCliente, cProducto, mMontoTotal, cTransaccion, cDescripcion, cSeContabiliza, 
						cCccMayor, cCccSub, cCccSubsub, cCccSssub, cCccSsssub, cAccMayor, cAccSub, cAccSubsub, cAccSssub, cAccSsssub,
						dFechaAlt, cCodigoFun, iCodigoRef;
		END WHILE;
		
		CLOSE sqlCur;
		FREE sqlCur;
		FREE sqlQry;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 20/11/2013",
"DESCRIPCION: Consulta los movimientos hitoricos de captación y credito";

CREATE PROCEDURE "informix".sp_cb_genrepcuentasatraspasar(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumDiasSMVDF SMALLINT,pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE dValorSM DECIMAL(14,2);
	DEFINE iNoAnios SMALLINT;
	DEFINE cnum_cte CHAR(20);
	DEFINE ccuenta CHAR(20);
	DEFINE ccliente CHAR(104);
	DEFINE dsdocon  DECIMAL(18,2);
	DEFINE dsdofin  DECIMAL(14,2);
	DEFINE dfechapago DATE;
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);
	DEFINE dTotal DECIMAL(16,2);
	DEFINE pIdMensaje CHAR(10);
	
	DEFINE vAcum_sdo_int DECIMAL(14,2);
	DEFINE vInts_prov_acum DECIMAL(14,2);
	DEFINE vFechaHoy DATE;
	DEFINE iAnio SMALLINT;
	DEFINE dResiduo DECIMAL(6,2); 
	DEFINE iAniobase SMALLINT;
	DEFINE dPorRetencionSuj	DECIMAL(9,6);
	DEFINE cPfisica	CHAR(1);
	DEFINE cExento_isr	CHAR(1);
	DEFINE cTipoPersona	CHAR(1);
	DEFINE cSujRet CHAR(1);
	DEFINE dPorRetSuj DECIMAL(9,6);
	DEFINE vbase_exenta DECIMAL(14,2);
	DEFINE iDias SMALLINT;
	DEFINE vBase_gravable	DECIMAL(14,2);
	DEFINE vIsrCalc         DECIMAL(14,2);
	DEFINE vValSaldo DECIMAL(14,2);
	
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
	LET cCodRetSp='00000';

	LET dValorSM = 0.0;
	LET iNoAnios = 3;
	LET cnum_cte ='';
	LET ccuenta ='';
	LET ccliente ='';
	LET dsdocon  =0.0;
	LET dsdofin  =0.0;
	LET dfechapago = DATE(1);
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET dTotal =0;
	LET pIdMensaje='WEB_ART61';
	
	LET vInts_prov_acum = 0.00;
	LET vAcum_sdo_int = 0.00;
	LET vFechaHoy  = '';
	LET iAnio	 = 0;
	LET dResiduo = 0.00;
	LET iAniobase = 0;
	LET dPorRetencionSuj = 0.000000;
	LET cPfisica = '';
	LET cExento_isr  = '';
	LET cTipoPersona  = '';
	LET cSujRet  = '';
	LET dPorRetSuj  = 0.000000;
	LET vbase_exenta = 0.00;
	LET iDias  = 0;
	LET vBase_gravable = 0.00;
	LET vIsrCalc    = 0.00;
	LET vValSaldo = 0.00;
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cb_genrepcuentasatraspasar.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR  NVL(pNumDiasSMVDF,0) = 0 THEN
			LET cCodRet = '00003';		
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';	
		     EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT nombre INTO cNombre FROM bdinteg:"informix".si_ejecut where ejecutivo = pUsuario;
		
		 -- SE LIMPIA TABLA POR USUARIO
 
        DELETE FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;

		DELETE FROM "informix".sw_verificastatusrepcuentasatraspasar
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusrepcuentasatraspasar(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error) 
		VALUES(pUsuario,'','I','','LECTURA','');
		
		--CONSULTA VALOR SMDF
		SELECT valor * pNumDiasSMVDF
		INTO   dValorSM
		FROM   bdicheq:sc_param
		WHERE  codparam = 'smdf';
		
		--BASE EXENTA PARA COBRO DE ISR
	    SELECT valor 
        INTO   vbase_exenta
        FROM   bdicheq:sc_param
        WHERE  empresa = "001"
        AND    codparam = "baseexenta";
		
		-- // OBTINENE LA FECHA DE HOY
        SELECT fecha_hoy
        INTO   vFechaHoy
        FROM   bdicheq:sc_fechas
        WHERE  empresa = "001";
		
		
	    -- CONSULTA DE CUENTAS		
        FOREACH WITH HOLD			   
		        SELECT con.num_cte,con.cuenta,con.cliente,con.sdo_concentrado,con.sdo_concentrado,con.fecha_concentra,
		               noc.acum_sdo_int,con.ints_prov_acum
				INTO   cnum_cte,ccuenta,ccliente,dsdocon,dsdofin,dfechapago,
				       vAcum_sdo_int,vInts_prov_acum
		        FROM   bdicheq:sc_cuentas_concentradas con, 
                       bdicheq:sc_maechq mae,
                       bdicheq:sc_maenoc noc,
                       bdicheq:sc_fechas fec
                WHERE  DATE(con.fecha_concentra) <= DATE((fec.pri_dia_mes - 1 UNITS DAY)) - (365 * iNoAnios)
                AND    mae.cuenta = con.cuenta
                AND    mae.status_cta = '6'
                AND    (con.sdo_concentrado >= 0 AND con.sdo_concentrado <= dValorSM )
                AND    noc.empresa = mae.empresa
                AND    noc.cuenta  = mae.cuenta
                AND    fec.empresa = mae.empresa
			    AND    con.fecha_concentra = (SELECT MAX(a.fecha_concentra)
                                              FROM   bdicheq:sc_cuentas_concentradas as a
                                              WHERE  a.cuenta = con.cuenta)
											  
											  
											  
			    -- // DETERMINA COBRO DE ISR
                LET iAnio = year(vFechaHoy);
                LET dResiduo = mod(iAnio, 4);

                IF  dResiduo = 0 THEN
                    LET iAniobase = 366;
                ELSE
                    LET iAniobase = 365;
                END IF;
        
                SELECT valor
                INTO   dPorRetencionSuj
                FROM   bdinteg:si_fechavalor
                WHERE  tasa = 'I.S.R.'
                AND    fecha = ( SELECT MAX(fecha) FROM bdinteg:si_fechavalor WHERE tasa = 'I.S.R.' );
           
		        SELECT tip.es_fisica, tip.exento_isr 
			    INTO   cPfisica,      cExento_isr
			    FROM   bdicheq:sc_maechq  mae,
		               bdinteg:si_cliente cte,
		               bdinteg:si_tipper  tip
                WHERE  mae.cuenta = ccuenta
	            AND    cte.numcte = mae.num_cte
	            AND    tip.tpo_persona = cte.tpo_persona;

                IF cPfisica = 'S' THEN
                    LET cTipoPersona = 'F';
                ELSE
                    LET cTipoPersona = 'M';
                END IF;
                 
                IF cExento_isr = 'N' THEN
                    LET cSujRet = 'S';
                ELSE
                    LET cSujRet = 'N';
                END IF;
                
                IF cSujRet <> 'S' THEN
                    LET dPorRetSuj = 0;
                ELSE
                    LET dPorRetSuj = dPorRetencionSuj;
                END IF;
                
                IF vbase_exenta is null THEN
                    LET vbase_exenta = 0;
                END IF;
        
                LET iDias = vFechaHoy - dfechapago;
		        LET vBase_gravable = dsdocon - vbase_exenta;
        
                IF  dPorRetSuj <> 0 THEN
                    IF cTipoPersona = 'F' THEN
                        IF vBase_gravable > 0 THEN
                            LET vIsrCalc = (vBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase;
                        ELSE
                            LET vIsrCalc = 0;
                        END IF;
                    ELSE
                        LET vIsrCalc = (dsdocon * (dPorRetSuj/100)) * iDias / iAniobase;
                    END IF;
                ELSE
                    LET vIsrCalc = 0;
                END IF;
			
			    --DE MOMENTO ESTA EN CODIGO DURO YA QUE NO SE REQUIERE COBRAR UN INTERES, SI EN ALGUN MOMENTO SE REQUIERE SOLO SE LIBERA LA LINEA. 
			    LET vIsrCalc = 0.00;
                
		        --- VALIDA SI LA CUENTA SUPERA LOS SALARIOS MINIMOS  AL SUMAR EL SALDO CONCENTRADO + INTERESES - ISR.  
		        LET vValSaldo = NVL(dsdocon,0.00) + NVL(vAcum_sdo_int,0.00) + NVL(vInts_prov_acum,0.00) - NVL(vIsrCalc,0.00);
		   
		        IF  vValSaldo <=  dValorSM  THEN 
		            INSERT INTO "informix".sw_cb_reportecuentasatraspasartmp(usuario, num_cte, num_cta, nom_cte, saldo_con, saldo_fin, fecha_con) 
		            VALUES(pUsuario,cnum_cte,ccuenta,ccliente,dsdocon,vValSaldo,dfechapago);
				END IF;

		END FOREACH; 
		
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';	
			UPDATE "informix".sw_verificastatusrepcuentasatraspasar
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
		
		SELECT SUM(saldo_con) INTO dTotal FROM "informix".sw_cb_reportecuentasatraspasartmp WHERE usuario = pUsuario;
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'NÃMERO DE CLIENTE','NÃMERO DE CUENTA','NOMBRE DEL CLIENTE','SALDO CONCENTRADO','SALDO FINAL','FECHA DE CONCENTRACIÃN' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT num_cte::CHAR(20), num_cta::CHAR(20),nom_cte::CHAR(104),saldo_con::CHAR(20),saldo_fin::CHAR(18),LPAD(DAY(fecha_con),2,0)||'/'||LPAD(MONTH(fecha_con),2,0)||'/'||YEAR(fecha_con) FROM ""informix"".sw_cb_reportecuentasatraspasartmp WHERE usuario ='"||pUsuario||"'"; 
       			
		LET cFechaHoraArchivo = LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||YEAR(dFechaHoy);
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'Cuentas_a_enviar_beneficencia_'||TRIM(cFechaHoraArchivo)||'.txt';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   DELETE FROM "informix".sw_ctrlgenreportesart WHERE nombre_reporte = TRIM(cNombreArchivo);
			     INSERT INTO "informix".sw_ctrlgenreportesart(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			    VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,'1');
			   
	    UPDATE "informix".sw_verificastatusrepcuentasatraspasar
		SET  status = 'T', error_proceso = 'N', nombre_archivo=cNombreArchivo
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
                
                -- SE ENVIA LA NOTIFICACIÃN DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),iTotal,'EL REPORTE DE CUENTAS A ENVIAR','','','','','','','',dTotal,0,0,0,0,'', '') INTO cCodRetSp;
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/07/2021',
'DESCRIPCION: SPL que genera el Reporte de las cuentas a traspasar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cb_genrepcuentastraspasadas(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATE,pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE dValorSM DECIMAL(14,2);
	DEFINE iNoAnios SMALLINT;
	DEFINE cnum_cte CHAR(20);
	DEFINE ccuenta CHAR(20);
	DEFINE ccliente CHAR(104);
	DEFINE dsdocon  DECIMAL(18,2);
	DEFINE dsdofin  DECIMAL(14,2);
	DEFINE dfechapago DATE;
	DEFINE dfechatran DATE;
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);
	DEFINE dTotal DECIMAL(16,2);
	DEFINE pIdMensaje CHAR(10);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
    LET cCodRetSp ='00000';
	
	LET dValorSM = 0.0;
	LET iNoAnios = 3;
	LET cnum_cte ='';
	LET ccuenta ='';
	LET ccliente ='';
	LET dsdocon  =0.0;
	LET dsdofin  =0.0;
	LET dfechapago = DATE(1);
	LET dfechatran = DATE(1);
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET dTotal =0;
	LET pIdMensaje='WEB_ART61';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/informix/rsv/bene/sp_cb_genrepcuentastraspasadas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR  pFecha = '' THEN
			LET cCodRet = '00003';		
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;
		
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
			 EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT nombre INTO cNombre FROM bdinteg:"informix".si_ejecut where ejecutivo = pUsuario;
		
		 -- SE LIMPIA TABLA POR USUARIO
 
        DELETE FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;

		DELETE FROM "informix".sw_verificastatusrepcuentastraspasadas
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusrepcuentastraspasadas(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error) 
		VALUES(pUsuario,'','I','','LECTURA','');
	
		-- CONSULTA DE CUENTAS		
		FOREACH WITH HOLD			   
		SELECT cb.num_cte, cb.cuenta, cb.cliente, cb.sdo_concentrado, cb.sdo_trasp_beneficiencia, cb.fecha_concentra, cb.fecha_trasp_benefic
		INTO   cnum_cte  , ccuenta  , ccliente  , dsdocon           , dsdofin,                    dfechapago,         dfechatran
		FROM   bdicheq:sc_cuentas_concentradas cb, 
               bdicheq:sc_maechq mae   
        WHERE  cb.cuenta = mae.cuenta
        AND    cb.fecha_trasp_benefic= pFecha
        AND    mae.status_cta        = '2'
        AND    mae.motivo            ='14'

		INSERT INTO "informix".sw_cb_reportecuentastraspasadastmp(usuario, num_cte, num_cta, nom_cte, saldo_con, saldo_fin, fecha_con,fecha_tra) 
		VALUES(pUsuario,cnum_cte,ccuenta,ccliente,dsdocon,dsdofin,dfechapago,dfechatran);

		END FOREACH; 
		
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';	
			UPDATE "informix".sw_verificastatusrepcuentastraspasadas
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'NO EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),'0','EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',0.00,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
           
		SELECT SUM(saldo_con) INTO dTotal FROM "informix".sw_cb_reportecuentastraspasadastmp WHERE usuario = pUsuario;		   
		   
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'NÃMERO DE CLIENTE','NÃMERO DE CUENTA','NOMBRE DEL CLIENTE','SALDO CONCENTRADO','SALDO FINAL','FECHA DE CONCENTRACIÃN','FECHA DE TRANSFERENCIA' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT num_cte::CHAR(20), num_cta::CHAR(20),nom_cte::CHAR(104),saldo_con::CHAR(20),saldo_fin::CHAR(18),LPAD(DAY(fecha_con),2,0)||'/'||LPAD(MONTH(fecha_con),2,0)||'/'||YEAR(fecha_con),LPAD(DAY(fecha_tra),2,0)||'/'||LPAD(MONTH(fecha_tra),2,0)||'/'||YEAR(fecha_tra) FROM ""informix"".sw_cb_reportecuentastraspasadastmp WHERE usuario ='"||pUsuario||"'";        
       				
		LET cFechaHoraArchivo = LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||YEAR(dFechaHoy);
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'Cuentas_enviadas_beneficencia_'||TRIM(cFechaHoraArchivo)||'.txt';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   DELETE FROM "informix".sw_ctrlgenreportesart WHERE nombre_reporte = TRIM(cNombreArchivo);
			   INSERT INTO "informix".sw_ctrlgenreportesart(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			   VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,'2');
		
			   
	    UPDATE "informix".sw_verificastatusrepcuentastraspasadas
		SET  status = 'T', error_proceso = 'N', nombre_archivo=cNombreArchivo
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';

       
        -- SE ENVIA LA NOTIFICACIÃN DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','', '1',cNombre,'EXITOSA',TO_CHAR(CURRENT, "%d/%m/%Y"),iTotal,'EL REPORTE DE CUENTAS ENVIADAS','','','','','','','',dTotal,0,0,0,0,'', '') INTO cCodRetSp;
		END IF;
					
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/07/2021',
'DESCRIPCION: SPL que genera el Reporte de las cuentas traspasadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sac_verificastatusctaside(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '00000';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sac_verificastatusctaside.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,error_proceso,error_code
		INTO cStatus,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_verificactaside 
		WHERE usuario = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','';
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA 16/12/2021',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de consultar la ejecucion del proceso en la tabla sw_verificasacmontototal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasoctaside(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasoctaside.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM bdicnweb:"informix".sw_verificactaside WHERE usuario = TRIM(pUsuario);
	
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_verificactaside(usuario,status,error_proceso,error_code)
		VALUES(pUsuario,'I','',TRIM(cCodRet));  
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_ide_soc(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_verificactaside
			SET status = 'E', error_proceso = 'S', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_traspasocuentas_ide_soc';
		END IF;
		
		UPDATE bdicnweb:"informix".sw_verificactaside
		SET status = 'T', error_proceso = 'N', error_code = TRIM(cCodRet) WHERE usuario = TRIM(pUsuario);
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de cuentas ide.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 16/12/2021',
'MODIFICACION: Se realiza tratamiento de volumen',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tc_consultalotepend(pUsuario CHAR(8), pIdFuncion CHAR(10),pSucursal CHAR(4))
	RETURNING CHAR(5) AS codret,
			  CHAR(4) AS sucursal, 
			  CHAR(1) AS tipo_tar, 
			  INTEGER AS num_env, 
			  INTEGER AS ran_ini, 
			  INTEGER AS ran_fin, 
			  CHAR(1) AS status, 
			  CHAR(10) AS fecha;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cSucursal CHAR(4);
	DEFINE cTipoTarjeta CHAR(1);
    DEFINE iNumEnvio INTEGER;
	DEFINE iRangoIni INTEGER;
	DEFINE iRangoFin INTEGER;
    DEFINE cStatus CHAR(1);
	DEFINE dFechaSurtido DATE;
	DEFINE cFecha CHAR(10);
	
	LET cCodRet = '00000';
    LET cSucursal = '';
	LET cCodRetSp = '00000';
	LET iSqlErr = 0;
	LET cTipoTarjeta = '';
    LET iNumEnvio = 0;
	LET iRangoIni = 0;
	LET iRangoFin = 0;
    LET cStatus	= '';
	LET dFechaSurtido = '';	
	LET cFecha = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_tc_consultalotepend.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		FOREACH 
		
		EXECUTE PROCEDURE bditarjcop:"informix".sp_conslotepend(pSucursal, '001')
		INTO cCodRetSp, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido

		IF cCodRetSp::INTEGER = 1 THEN
		LET cCodRet = '01276';
		RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha;
		ELSE
		LET cFecha = LPAD(DAY(dFechaSurtido),2,0)||'/'||LPAD(MONTH(dFechaSurtido),2,0)||'/'||YEAR(dFechaSurtido);
		RETURN cCodRet, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, cFecha WITH RESUME;
		END IF
		END FOREACH;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA 21/01/2022',
'FUNCIONALIDAD: TARJETAS COPPEL',
'DESCRIPCION: SPL que ejecuta el sp productivo sp_conslotepend',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_obtienegrupo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSol CHAR(12))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS tipogrupo, 
				  CHAR(6) AS hit;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSP CHAR(6);
	DEFINE cTipo CHAR(2);
	DEFINE cHit CHAR(6);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP = '000000';
	LET cTipo ='';
	LET cHit ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipo,cHit;  
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_obtienegrupo.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumSol ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipo,cHit; 
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipo,cHit; 
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo(pNumSol) INTO cCodRetSP,cTipo,cHit; 
		
		IF cCodRetSP ='000000' THEN
			LET cCodRet ='00000';
		END IF;
        
		RETURN cCodRet,cTipo,cHit;   
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio Estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_obtienegrupo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_obtienecompingresos_mc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(60) as comprobante;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cComprobante CHAR(60);
	DEFINE iNoRegistros INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cComprobante ='';
	LET iNoRegistros =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cComprobante;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_obtienecompingresos_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cComprobante;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cComprobante;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
		FOREACH
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienecompingresos_mc()
		INTO cComprobante   
		LET iNoRegistros = iNoRegistros+1;
		RETURN cCodRet,cComprobante WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
		RETURN cCodRet,cComprobante;		
		END IF;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio de estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_obtienecompingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_nombreemp_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,					
				 CHAR(60) AS nombre
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	DEFINE cNombreC CHAR(60);
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iEspacios INTEGER;
	DEFINE cNombre CHAR(25);
	DEFINE cApat CHAR(15);
	DEFINE cAmat CHAR(15);
	DEFINE iContador  INTEGER;
	DEFINE cPalabra LVARCHAR;
	DEFINE iAux1 INTEGER;
	DEFINE iAux2 INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;
	LET cNombreC = '';
	LET i =0 ;
	LET iTamCad = 0;
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres =0;
	LET cCaracter ='';
	LET iEspacios = 0;
	LET cNombre ='';
	LET cApat ='';
	LET cAmat ='';
	LET iContador = 0;
	LET iAux1 = 0;
	LET iAux2=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreC;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_nombreemp_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,cNombreC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreC;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
				
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNombreC;
		END IF;		
		
		SELECT nombre INTO cNombreC FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
		
		RETURN cCodRet,cNombreC;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de recuperar el nombre del empleado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_lista_empleados_mc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,					
				 INTEGER AS total
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_lista_empleados_mc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotal;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		 
		SELECT COUNT(*)
		INTO iTotal
		FROM bdisolic:ss_emp_revingresos_mc;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iTotal;
		END IF;		
		
		RETURN cCodRet,iTotal;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de recuperar el total de filas de la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_lista_empleados_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(60) AS nom_emp,
				  CHAR(8) AS num_emp;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomEmp CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumEmp CHAR(8);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomEmp = '';
    LET iNoRegistros = 0;
	LET cNumEmp ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmp,cNumEmp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_lista_empleados_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

        IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNomEmp,cNumEmp;
        END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF(pRegistros == 0) THEN
            DELETE FROM bdicnweb:"informix".sw_ss_emp_revingresos_mc WHERE usuario = pUsuario;

            FOREACH
                
                SELECT TRIM(nombre_empleado) ||' '|| TRIM(apellidop_empleado) ||' '|| TRIM(apellidom_empleado),num_empleado INTO cNomEmp,cNumEmp
                FROM bdisolic:ss_emp_revingresos_mc 
 
                INSERT INTO bdicnweb:"informix".sw_ss_emp_revingresos_mc (usuario,nombre_empleado,num_emp) VALUES(pUsuario,cNomEmp,cNumEmp);
            END FOREACH;
        END IF;

        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion
			nombre_empleado,num_emp
            INTO cNomEmp,cNumEmp FROM bdicnweb:"informix".sw_ss_emp_revingresos_mc
            WHERE usuario = pUsuario
            ORDER BY nombre_empleado
            LET iNoRegistros = iNoRegistros + 1;

           RETURN cCodRet,cNomEmp,cNumEmp WITH RESUME;

        END FOREACH;

        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cNomEmp,cNumEmp;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNomEmp,cNumEmp;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_lista_empleados_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_insert_empleados_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	DEFINE cNombreC CHAR(60);
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE iEspacios INTEGER;
	DEFINE cNombre CHAR(25);
	DEFINE cApat CHAR(15);
	DEFINE cAmat CHAR(15);
	DEFINE iContador  INTEGER;
	DEFINE cPalabra LVARCHAR;
	DEFINE iAux1 INTEGER;
	DEFINE iAux2 INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;
	LET cNombreC = '';
	LET i =0 ;
	LET iTamCad = 0;
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres =0;
	LET cCaracter ='';
	LET iEspacios = 0;
	LET cNombre ='';
	LET cApat ='';
	LET cAmat ='';
	LET iContador = 0;
	LET iAux1 = 0;
	LET iAux2=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_insert_empleados_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
				
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
 		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;		
		
		SELECT nombre INTO cNombreC FROM bdinteg:si_ejecut WHERE ejecutivo = pNumEmpleado;
		
		LET iTamCad = LENGTH(TRIM(cNombreC));
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			
			IF cCaracter = ' ' THEN
				LET iEspacios = iEspacios+1;
			END IF;
			
		END LOOP;
		
        LET iAux1 = iEspacios - 1;
		
		IF iEspacios = 0 THEN
			
		LET cNombre = cNombreC;
		LET cApat = ' ';		
		
		END IF;
		
		IF iEspacios = 1 THEN
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF iContador =1  THEN
					LET cNombre = cPalabra;
				ELSE
					LET cApat = cPalabra;
				END IF;
				
			END IF;
			
		END LOOP;
		
		END IF;
		
		IF iEspacios = 2 THEN
		
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF iContador =1  THEN
					LET cNombre = cPalabra;
				ELIF iContador = 2 THEN
					LET cApat = cPalabra;
				END IF;
				
				
			END IF;
			
				IF i = iTamCad THEN 
					LET cAmat = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				END IF;
		END LOOP;
	 
		END IF;
		
		IF iEspacios > 2 THEN

		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(cNombreC), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			
			IF cCaracter = ' ' THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				LET iContador = iContador+1;
				LET cPalabra = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				
				IF (iContador <=iAux1)  THEN
					LET cNombre = TRIM(cNombre)||' '||TRIM(cPalabra);
				ELIF (iContador = iEspacios) THEN					 
					LET cApat = TRIM(cPalabra);
				END IF;
				
				
			END IF;
			
				IF i = iTamCad THEN 
					LET cAmat = SUBSTR(TRIM(cNombreC), iInicioCadena, iRecuperarCaracteres);
				END IF;
		END LOOP;	 
		
		END IF;
		
		INSERT INTO bdisolic:ss_emp_revingresos_mc(num_empleado, nombre_empleado, apellidop_empleado, apellidom_empleado) 
		VALUES(pNumEmpleado, cNombre, cApat, cAmat);
		
		RETURN cCodRet;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de insertar empleados a la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_elim_empleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret;				  

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_elim_empleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
     
		EXECUTE PROCEDURE bdisolic:"informix".sp_elimina_emp_mc(pNumEmpleado);
	   
		RETURN cCodRet;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_elimina_emp_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_determina_lincred_tc_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20), pCteNvo CHAR(1))
		RETURNING CHAR(5) AS codret,
				  MONEY(14,2) AS linea_cred,
				  MONEY(14,2) AS capacidad_de_pago,
				  INTEGER AS plazo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE mLinCred MONEY(14,2);
	DEFINE mCapPago MONEY(14,2);
	DEFINE iPlazo INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET mLinCred = 0.0;
	LET mCapPago = 0.0;
	LET iPlazo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_determina_lincred_tc_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,mLinCred,mCapPago,iPlazo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pEmpresa, pNumSol, pCteNvo) 
		INTO cCodRet,mLinCred,mCapPago,iPlazo;
        
        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet,mLinCred,mCapPago,iPlazo;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Cambio de estatus',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo determina_lincred_tc_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consultaempleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS existe;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cExiste CHAR(1);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cExiste = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cExiste;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consultaempleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cExiste;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cExiste;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        SELECT COUNT(*) INTO iExiste FROM bdisolic:ss_emp_revingresos_mc WHERE num_empleado = pUsuario;
		
		IF iExiste = 0 THEN 
			LET cExiste='0';
		END IF;
		
		IF iExiste >= 1 THEN 
			LET cExiste='1';
		END IF;
		
		RETURN cCodRet,cExiste;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de consultar si el empleado existe en la tabla ss_emp_revingresos_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_consulparam_cambioestatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(50) as valor,
				  CHAR(1) as estatus;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(50);
	DEFINE cEstatus CHAR(1);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor ='';
	LET cEstatus ='';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cValor,cEstatus;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_consulparam_cambioestatus.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cValor,cEstatus;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   		
		SELECT valor,estatus INTO cValor,cEstatus FROM bdisolic:"informix".ss_paramcambioestatus WHERE descrip_param  = 'Tiempo_Limite' AND tipo_param ='P';
       
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cValor,cEstatus;
		END IF;		
	   
		RETURN cCodRet,cValor,cEstatus;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: Monitor solicitudes',
'DESCRIPCION: SPL encargado de recuperar datos de la tabla ss_paramcambioestatus',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_cons_empleado_mc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,
				  CHAR(60)	AS nom_emp;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNomEmp CHAR(60);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNomEmp = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNomEmp;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_cons_empleado_mc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNomEmp;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNomEmp;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
        FOREACH
        EXECUTE PROCEDURE bdisolic:"informix".sp_cons_empleado_mc(pNumEmpleado) INTO cNomEmp 
        RETURN cCodRet,cNomEmp WITH RESUME;
        END FOREACH;
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_cons_empleado_mc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_pm_califica_scoring2_cjunk(pUsuario CHAR(8), pIdFuncion CHAR(10),pEmpresa CHAR(3), pNumSol CHAR(20))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;  
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_pm_califica_scoring2_cjunk.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pNumSol ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;  
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;  
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
   
  
        EXECUTE PROCEDURE bdisolic:"informix".califica_scoring2_cjunk(pEmpresa, pNumSol) INTO cCodRet; 

        IF cCodRet = '000' THEN
            LET cCodRet ='00000';
        END IF;
        
		RETURN cCodRet;  
       
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 27/09/2021',
'MODULO: CREDITO',
'FUNCIONALIDAD: TABLEROS ANALISTAS',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo califica_scoring2_cjunk',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitorconsultatotsolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT)
	RETURNING CHAR(5) AS codret,
		INTEGER AS total_regs;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- InicializaciÃ³n de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegs;
		END EXCEPTION;
		
		ON EXCEPTION IN (-239)
			LET cCodRet = '00017';
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultatotsolicitudxmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		-- ValidaciÃ³n del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegs;
			END IF;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;	

		-- Conteo del numero de registros
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0 , 'ERROR EN LA EJECUCION DEL SP PRODUCTIVO bdisolic:sp_consultaactualizasolicmc';
				ELIF cCodRetSp::INTEGER = 0 THEN
					LET iTotalRegs = iTotalRegs + 1;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, iTotalRegs;
				ELIF cCodRetSp IN ('00003', '00004', '00005') THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, iTotalRegs;
				END IF;
				
		END FOREACH;
		
		IF iTotalRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iTotalRegs;
		END IF;
		
		RETURN cCodRet, iTotalRegs;

	END;
END PROCEDURE
DOCUMENT "AUTOR: Johnattan Esquivel Sanchez",
"FECHA: 12/03/2020",
"MODIFICACION: Se se modifica procedimiento por control de excepcion",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_monitorconsultasolicitudxmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pEjecutivoAtiende CHAR(8), pStatus CHAR(2), pCausa CHAR(3), pObservaciones CHAR(100), pTipo SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		CHAR(100) AS nombre_cliente,
		CHAR(13) AS rfc,
		CHAR(4) AS sucursal,
		DATE AS fecha_insert,
		DATE AS fecha_modificacion,
		DECIMAL(18,2) AS monto_solicitado,
		DECIMAL(18,2) AS eficiencia,
		SMALLINT AS historial,
		CHAR(2) AS status_inicial,
		DECIMAL(18,2) AS seccion1,
		DECIMAL(18,2) AS seccion2,
		CHAR(3) AS causa_solic,
		CHAR(300) AS observaciones,
		CHAR(4) AS num_producto,
		CHAR(2) AS status_fin,
		CHAR(8) AS ejecutivo_atiende,
		CHAR(8) AS ejecutivo_autoriza,
		DATETIME HOUR TO SECOND AS hora_insert,
		DATE AS fecha_determinacion,
		CHAR(1) AS revisado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(100);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaInsert DATE;
	DEFINE dFechaModificacion DATE;
	DEFINE mMontoSolicitado DECIMAL(18,2);
	DEFINE mEficiencia DECIMAL(18,2);
	DEFINE iHistorial SMALLINT;
	DEFINE cStatusInicial CHAR(2);
	DEFINE mSeccion1 DECIMAL(18,2);
	DEFINE mSeccion2 DECIMAL(18,2);
	DEFINE cCausaSolic CHAR(3);
	DEFINE cObservaciones CHAR(300);
	DEFINE cNumProducto CHAR(4);
	DEFINE cStatusFin CHAR(2);
	DEFINE cEjecutivoAtiende CHAR(8);
	DEFINE cEjcutivoAutoriza CHAR(8);
	DEFINE dHoraInsert DATETIME HOUR TO SECOND;
	DEFINE dFechaDeterminacion DATE;
	DEFINE cRevisado CHAR(1);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegs INTEGER;
	DEFINE iNoRegs INTEGER;

	-- Inicialización de variables
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cCodRetSp = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaInsert = NULL;
	LET dFechaModificacion = NULL;
	LET mMontoSolicitado = NULL;
	LET mEficiencia = NULL;
	LET iHistorial = 0;
	LET cStatusInicial = '';
	LET mSeccion1 = NULL;
	LET mSeccion2 = NULL;
	LET cCausaSolic = '';
	LET cObservaciones = '';
	LET cNumProducto = '';
	LET cStatusFin = '';
	LET cEjecutivoAtiende = '';
	LET cEjcutivoAutoriza = '';
	LET dHoraInsert = NULL;
	LET dFechaDeterminacion = NULL;
	LET cRevisado = '';
	LET cEmpresa = '001';
	LET iTotalRegs = 0;
	LET iNoRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_monitorconsultasolicitudxmc.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pStatus = '' OR pTipo IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		-- Validación del tipo de busqueda
		IF pTipo NOT IN (1,2,3) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF pTipo = 3 THEN
			IF pEjecutivoAtiende = '' OR pNumSolicitud = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			ENd IF;
			
			IF pStatus IN ('CM', 'RT') AND pCausa = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
					mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
					cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
			END IF;
		END IF;
		
		-- Validacción de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		-- Obtención de datos
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_consultaactualizasolicmcsoc(cEmpresa, pNumSolicitud, pEjecutivoAtiende, pStatus, pCausa, pObservaciones, pTipo, pRegistros, pRecuperacion,pUsuario)
			INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado
				
				IF cCodRetSp::INTEGER = 0 THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado WITH RESUME;
				ELIF cCodRetSp = '00001' THEN -- Parametros incorrectos
					LET cCodRet = '00003';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp = '00002' THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD
					LET cCodRet = '00219';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				ELIF cCodRetSp IN ('00003', '00004', '00005') AND pRegistros = 0 THEN -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS
					LET cCodRet = '00220';
					RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
						mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
						cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
				END IF;
				
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaInsert, dFechaModificacion, mMontoSolicitado, 
				mEficiencia, iHistorial, cStatusInicial, mSeccion1, mSeccion2, cCausaSolic, cObservaciones, cNumProducto, cStatusFin,
				cEjecutivoAtiende, cEjcutivoAutoriza, dHoraInsert, dFechaDeterminacion, cRevisado;
		END IF;
		
	END;
END PROCEDURE;