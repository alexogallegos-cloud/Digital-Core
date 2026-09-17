CREATE PROCEDURE "informix".sp_admintasas_actualizastatuspagare(pUsuario CHAR(9), 
                                                                pIdFuncion CHAR(8),
                                                                pIdPromocion INTEGER,
                                                                pFechaVencimiento DATE,
                                                                pGatNominal DECIMAL(9,6),
                                                                pGatReal    DECIMAL(9,6),
                                                                pEstatus    SMALLINT,
																pProducto CHAR(4),
																pMontoSdoCte DECIMAL(14,2))
RETURNING CHAR(5)       AS codret;


    
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIdpromocion     INTEGER;
    DEFINE dFechaVencimiento date;
    DEFINE dGatNominal      DECIMAL(9,6);
	DEFINE dGatReal         DECIMAL(9,6);   
    DEFINE cNombreEstrategia CHAR(100);
    DEFINE iEstatus         INTEGER;
    DEFINE iBanMod          SMALLINT;
    DEFINE iCodEstatusOrg  SMALLINT;
	--Nuevo
	DEFINE iTotalPro1100	INTEGER;
	-- nuevo
	DEFINE dMontoSdoCte		DECIMAL(14,2);


    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iIdpromocion     = '';
    LET dFechaVencimiento = '';
    LET dGatNominal       = 0;
    LET dGatReal          = 0;
    LET cNombreEstrategia = '';
    LET iEstatus          = NULL;
    LET iBanMod           = 0;
    LET iCodEstatusOrg    = NULL;
	--Nuevo
	LET iTotalPro1100	  = 0;
	LET dMontoSdoCte	  = 0;
   

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/admintasas/sp_admintasas_actualizastatuspagare.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pIdPromocion = '' OR pIdPromocion IS NULL OR pFechaVencimiento = '' 
        OR pEstatus = '' OR pEstatus NOT IN (0,1,2) THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
			SELECT id_promocion, nombre_estrategia,  fecha_vencimiento, gat_nominal, gat_real, monto_saldonuevo
			INTO iIdpromocion, cNombreEstrategia, dFechaVencimiento, dGatNominal, dGatReal, dMontoSdoCte
			FROM bdinvers:sv_admintasas_pagare
			WHERE id_promocion = pIdPromocion;
	
			SELECT cod_estatus 
			INTO iCodEstatusOrg
			FROM bdinvers:sv_admintasas_estatus 
			WHERE id_promocion = iIdpromocion
			AND cod_estatus IN (0,1)
			AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));
	
			SELECT cod_estatus 
			INTO iEstatus
			FROM bdinvers:sv_admintasas_estatus 
			WHERE id_promocion = iIdpromocion 
			AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion);
	
			IF iIdpromocion IS NOT NULL OR iIdpromocion <> '' THEN
			-- ActualizaciÃ³n de la campaÃ±a
				UPDATE bdinvers:sv_admintasas_pagare 
				SET fecha_vencimiento = pFechaVencimiento, gat_nominal = pGatNominal, gat_real = pGatReal, monto_saldonuevo = pMontoSdoCte
				WHERE id_promocion = pIdPromocion;
	
				IF pFechaVencimiento <> dFechaVencimiento THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA FECHA VENCIMIENTO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dFechaVencimiento, pFechaVencimiento);
				END IF;
				IF dGatNominal != pGatNominal THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA GAT NOMINAL DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dGatNominal, pGatNominal);
				END IF;
				IF dGatReal != pGatReal THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA GAT REAL DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dGatReal, pGatReal);
				END IF;
				
				IF NVL(dMontoSdoCte,0) <> NVL(pMontoSdoCte,0) THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL MONTO SALDO NUEVO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dMontoSdoCte, pMontoSdoCte);
				END IF;
	
				IF pEstatus = iEstatus THEN --0,0 1,1, 2,2
	
					IF (iBanMod = 1 AND pEstatus = 0) THEN -- 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					
					ELIF iBanMod = 1 AND pEstatus = 1 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
	
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 1 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 0 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					END IF
	
					IF iBanMod = 0 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
	
					END IF
				ELIF pEstatus <> iEstatus THEN
	
					IF  iEstatus = 0 AND pEstatus = 1 AND iBanMod = 1 THEN
	
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 1 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 1 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 0 AND pEstatus = 1 AND iBanMod = 0 THEN
	
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					
					ELIF iEstatus = 2 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
	
					END IF
								
				END IF;
			
			ELSE
				LET cCodRet = '00017';
			END IF;
		ELSE --1100
			SELECT COUNT(*)
			INTO iTotalPro1100
			FROM bdicheq:sc_admintasas_invcreciente
			WHERE id_promocion = pIdPromocion;
			
			IF NVL(iTotalPro1100,0) > 0 THEN 
				SELECT fecha_vencimiento
				INTO dFechaVencimiento
				FROM bdicheq:sc_admintasas_invcreciente
				WHERE id_promocion = pIdPromocion;
				
				SELECT cod_estatus 
				INTO iCodEstatusOrg
				FROM bdicheq:sc_admintasas_inv_estatus 
				WHERE id_promocion = pIdPromocion
				AND cod_estatus IN (0,1)
				AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = pIdPromocion AND cod_estatus IN (0,1));
		
				SELECT cod_estatus 
				INTO iEstatus
				FROM bdicheq:sc_admintasas_inv_estatus 
				WHERE id_promocion = pIdPromocion 
				AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = pIdPromocion);
	
				
				IF dFechaVencimiento <> pFechaVencimiento THEN
					LET iBanMod = 1; 
					UPDATE bdicheq:sc_admintasas_invcreciente
					SET fecha_vencimiento = pFechaVencimiento
					WHERE id_promocion = pIdPromocion;
					
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA FECHA VENCIMIENTO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 1100, pUsuario, dFechaVencimiento, pFechaVencimiento);	
				END IF;
				
				IF pEstatus = iEstatus THEN --0,0 1,1, 2,2
	
					IF (iBanMod = 1 AND pEstatus = 0) THEN -- 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					
					ELIF iBanMod = 1 AND pEstatus = 1 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
	
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 1 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 0 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					END IF
	
					IF iBanMod = 0 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
	
					END IF
				ELIF pEstatus <> iEstatus THEN
	
					IF  iEstatus = 0 AND pEstatus = 1 AND iBanMod = 1 THEN
	
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 1 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 1 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 0 AND pEstatus = 1 AND iBanMod = 0 THEN
	
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					
					ELIF iEstatus = 2 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
	
					END IF
								
				END IF;
				
			ELSE
				LET cCodRet = '00017';
			END IF;
			
		END IF;
		
        RETURN cCodRet;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 28/08/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: MODIFICACIÃN DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado que se encarga de actualizar la fecha de vencimiento, gat Nominal, gat Real y el estatus de la campaÃ±a de la tabla bdinvers:sv_admintasas_pagare',
'AsÃ­ como validar que la fecha de vencimiento no sea menor a la actual e insertar un nuevo registro a la bdinvers:sv_admintasas_pagare, cuando haya un cambio de estatus',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para actualizar los datos del producto 1100',
'AUTOR: Veronica Sanchez',
'FECHA: 26/08/2025',
'DESCRIPCION: Se modifica proceso realizar la insercion del estatus de forma correcta',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se modifica proceso realizar la insercion de los nuevos campos para de producto 3000',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultapagare(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pProducto CHAR(4), 
                                                        pEstatus SMALLINT, 
                                                        pIdPromocion INTEGER,
                                                        pNombrePromocion CHAR(100), 
                                                        pCanal SMALLINT, 
                                                        pCapitalMin DECIMAL(14,2), 
                                                        pCapitalMax DECIMAL(14,2), 
                                                        pFechaInicio DATE, 
                                                        pFechaVencimiento DATE,
                                                        pPlazo_inicio INTEGER, 
                                                        pPlazo_vencimiento INTEGER, 
                                                        pCampoOrden SMALLINT, 
                                                        pOrderBy SMALLINT,
                                                        pRegistros INTEGER, 
                                                        pRecuperacion INTEGER)
RETURNING CHAR(5)       AS codret,
          INTEGER       AS id_promocion,
          CHAR(100)     AS nombre_estrategia,
          SMALLINT      AS canal,
          INTEGER       AS plazo_inicio,
          INTEGER       AS plazo_vencimiento, 
          DECIMAL(14,2)   AS capital_min,    
          DECIMAL(14,2)   AS capital_max,
          CHAR(10)        AS fecha_inicio,
          CHAR(10)      AS fecha_vencimiento,
          DECIMAL(9,6)  AS tasa,
          DECIMAL(9,6)  AS gat_nominal,
          DECIMAL(9,6)  AS gat_real,
          SMALLINT      AS cod_estatus,
          SMALLINT      AS cod_estatus_orginal,
		  CHAR(2)		AS requiereSdoNuevo, -- NUEVO
		  DECIMAL(14,2) AS montoSdoNuevo, -- NUEVO
		  CHAR(2)		AS requiereInsApertura, -- NUEVO
		  CHAR(60)		AS instrumentoApertura, -- NUEVO
		  CHAR(2)		AS requiereParCteNuevo, -- NUEVO
		  INTEGER		AS diasVigenciaCteNuevo; -- NUEVO

    DEFINE vCampoOrden          INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iRegistro            INTEGER;
    DEFINE iIdpromocion         INTEGER;
    DEFINE cNombreEstrategia    CHAR(100); 
    DEFINE cCanal               SMALLINT;
    DEFINE dCapitalmin          DECIMAL(14,2);
    DEFINE dCapitalmax          DECIMAL(14,2);
    DEFINE iplazoInicio         INTEGER;
    DEFINE iplazoVencimiento    INTEGER;
    DEFINE dFechaInicio         CHAR(10);
    DEFINE dFechaVencimiento    CHAR(10);
    DEFINE dTasa                DECIMAL(9,6);
    DEFINE dGatNominal          DECIMAL(9,6);
	DEFINE dGatReal             DECIMAL(9,6);
    DEFINE iCodEstatus          SMALLINT;
    DEFINE iCodEstatusOrg       SMALLINT;
    DEFINE cCmd1 CHAR(6500);
    DEFINE vOrdenamiento        VARCHAR(50);
    DEFINE cCmd2 CHAR(6500);
	-- Nuevos
	DEFINE cRequiereSdoNuevo	CHAR(2);
	DEFINE dMontoSdoNuevo		DECIMAL(14,2);
	DEFINE cRequiereInstrApertura	CHAR(2);
	DEFINE cInstrumentoApertura	CHAR(50);
	DEFINE cParCteNuevo			CHAR(2);
	DEFINE iDiasVigenciaCteNuevo	INTEGER;
	DEFINE cInstrumentoVenCap		CHAR(2);
	DEFINE cInstrumentoVenInt		CHAR(2);

    

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0;
    LET iIdpromocion     = '';
    LET cNombreEstrategia = '';
    LET cCanal           = '';
    LET dCapitalmin      = '';
    LET dCapitalmax      = '';
    LET iplazoInicio     = 0;
    LET iplazoVencimiento = 0;
    LET dFechaInicio     = '';
    LET dFechaVencimiento = '';
    LET dTasa            = '';
    LET dGatNominal      = '';
	LET dGatReal         = '';
    LET iCodEstatus      = '';
    LET iCodEstatusOrg   = '';
    let vCampoOrden      = '';
    let vOrdenamiento    = '';
	--NUEVO
	LET cRequiereSdoNuevo	= '';
	LET dMontoSdoNuevo	= 0;
	LET cRequiereInstrApertura	= '';
	LET cInstrumentoApertura	= '';
	LET cParCteNuevo	= '';
	LET iDiasVigenciaCteNuevo	= 0;
	LET cInstrumentoVenCap = '';
    LET cInstrumentoVenInt = '';


    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/vero/tasas_f3/sp_admintasas_consultastatuspagare.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pProducto = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;

        --Validamos que el campo orden no exceda de los 13 registros
        IF pCampoOrden IS NOT NULL AND pCampoOrden NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13) THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
        END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;
		
        IF pProducto <> '3000' AND pProducto <> '1100' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
        END IF;

        IF pRegistros = 0 THEN

            DELETE FROM "informix".sw_admintasas_pagare_estatus_temp  WHERE usuario_insert = pUsuario; 

            LET cCmd1 = "";
			IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
				LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.id_promocion, nombre_estrategia, canal, plazo_inicio, plazo_vencimiento, capital_min, capital_max, fecha_inicio, fecha_vencimiento, tasa, gat_nominal, gat_real,";
				LET cCmd1 = ""||TRIM(cCmd1)|| "instruccion_vencimiento_capital, instruccion_vencimiento_intereses, dias_vigencia, monto_saldonuevo, cod_estatus";
				LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdinvers:sv_admintasas_pagare p INNER JOIN bdinvers:sv_admintasas_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = p.id_promocion)";
				LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
	
				IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
				END IF;
	
				IF pEstatus IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND cod_estatus = '" || pEstatus ||"'";
				END IF;
	
				IF pCanal IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
				END IF;
	
				IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
				END IF;
	
				IF pPlazo_inicio IS NOT NULL AND pPlazo_vencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (plazo_inicio >= " || pPlazo_inicio || " AND plazo_vencimiento <= " || pPlazo_vencimiento || ")";
				END IF;
	
				IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND fecha_vencimiento <= '"||pFechaVencimiento||"'";
				END IF;
				
			ELSE -- PRODUCTO 1100
				LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.id_promocion, nombre_estrategia, canal, capital_min, capital_max, fecha_inicio, fecha_vencimiento, cod_estatus";
				LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdicheq:sc_admintasas_invcreciente p INNER JOIN bdicheq:sc_admintasas_inv_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = p.id_promocion)";
				LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
		
				IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
				END IF;
		
				IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
				END IF;
				
				IF pEstatus IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND s.cod_estatus = '" || pEstatus ||"'";
				END IF;
		
				IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (p.fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND p.fecha_vencimiento <= '"||pFechaVencimiento||"'";
				END IF;
				
				IF pCanal IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
				END IF;
				
			END IF;
			
			IF pCampoOrden IS NULL AND (pOrderBy = 1 OR pOrderBy = '') THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion ASC";
			END IF;
			
            IF pCampoOrden IS NULL AND pOrderBy = 2 THEN
                LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion DESC";
            END IF;

            IF pCampoOrden IS NOT NULL AND pOrderBy IS NOT NULL THEN
                IF pOrderBy = '1' THEN
                    LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || pCampoOrden ||"  ASC";
                ELIF pOrderBy = '2' THEN
                    LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || pCampoOrden ||"  DESC";
                END IF
            END IF

            --Ajuste 
            IF NVL(pNombrePromocion,'') <> '' THEN
                LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";
            END IF;

            PREPARE stmtId FROM TRIM(cCmd1);
            DECLARE selectQryCur CURSOR FOR stmtId;
            OPEN selectQryCur;
			
			IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
				FETCH selectQryCur INTO iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, iCodEstatus;
			ELSE
				FETCH selectQryCur INTO iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, iCodEstatus;
			END IF;
			
			IF pProducto = '3000' THEN 
				WHILE(SQLCODE == 0)	
            
                    SELECT cod_estatus 
                    INTO iCodEstatusOrg
                    FROM bdinvers:sv_admintasas_estatus 
                    WHERE id_promocion = iIdpromocion
                    AND cod_estatus IN (0,1)
                    AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));

                    IF iCodEstatusOrg IS NULL OR iCodEstatus = '' THEN
                        LET iCodEstatusOrg = iCodEstatus;
                    END IF;

                    IF pNombrePromocion <> '' THEN
                        LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));

                        IF cNombreEstrategia LIKE pNombrePromocion THEN
                            LET iRegistro = iRegistro + 1;
                            --RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg WITH RESUME;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                        END IF;
                    ELSE
                            LET iRegistro = iRegistro + 1;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                    END IF;
					FETCH selectQryCur INTO  iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, iCodEstatus;
				END WHILE;			
			ELSE 
				WHILE(SQLCODE == 0)	
                    SELECT cod_estatus 
					INTO iCodEstatusOrg
					FROM bdicheq:sc_admintasas_inv_estatus 
					WHERE id_promocion = iIdpromocion
					AND cod_estatus IN (0,1)
					AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));

                    IF iCodEstatusOrg IS NULL OR iCodEstatus = '' THEN
                        LET iCodEstatusOrg = iCodEstatus;
                    END IF;

                    IF pNombrePromocion <> '' THEN
                        LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));

                        IF cNombreEstrategia LIKE pNombrePromocion THEN
                            LET iRegistro = iRegistro + 1;
                            --RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg WITH RESUME;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                        END IF;
                    ELSE
						LET iRegistro = iRegistro + 1;
						INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
						VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                    END IF;
					FETCH selectQryCur INTO  iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, iCodEstatus;
				END WHILE;
			END IF;
			
            CLOSE selectQryCur;
            FREE selectQryCur;
            FREE stmtId;
            
            LET cCmd1 = '';	
            --SE REGISTRA EN BITACORA
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT YEAR TO SECOND, pUsuario, 'CONSULTA DE CAMPAÃAS', 3, "CONSULTA DE CAMPAÃAS", pProducto);
        END IF;

            --AGREGAR PAGINADO
            --SUSTITUIR EN ORDER BY PoRDENAMIENTO
            --AGREGAR ASC O DESC
            --------TODO EN SENTENCIA PREPARADA
            
                

        IF pOrderBy = '2' THEN 

            IF pCampoOrden = 1 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion NVL(id_promocion,0),nombre_estrategia , canal , capital_min , capital_max , plazo_inicio , plazo_vencimiento, fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY id_promocion DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
					
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

                ELIF pCampoOrden = 2 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),NVL(nombre_estrategia,0), CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY nombre_estrategia DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
					
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
               END FOREACH;

            ELIF pCampoOrden = 3 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, NVL(CAST(canal AS INTEGER),0) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE canal
					WHEN 2 THEN 1
					WHEN 4 THEN 2
					WHEN 3 THEN 3
					WHEN 1 THEN 4
					ELSE 999
					END) * -1
                    LET iRegistro = iRegistro + 1;
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
               END FOREACH;

            ELIF pCampoOrden = 4 THEN 
				IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
					
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
					
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
					
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;
            ELIF pCampoOrden = 5 THEN
                IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_vencimiento DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 6 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;

				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;

				END IF;
            ELIF pCampoOrden = 7 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_vencimiento DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 8 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY (CASE cod_estatus WHEN 1 THEN 1
						WHEN 2 THEN 2
						WHEN 0 THEN 3
						ELSE 999
						END) * -1
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 9 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , NVL(fecha_vencimiento,0), tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY fecha_vencimiento DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 10 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, NVL(tasa,0), gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY tasa DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 11 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, NVL(gat_nominal,0), gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_nominal DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 12 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, NVL(gat_real,0), cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_real DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 13 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, NVL(cod_estatus,0), cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE cod_estatus WHEN 1 THEN 1
					WHEN 2 THEN 2
					WHEN 0 THEN 3
					ELSE 999
					END) * -1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;
            END IF;
        ELSE   
            IF pCampoOrden = 1 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion NVL(id_promocion,0),nombre_estrategia , canal , capital_min , capital_max , plazo_inicio , plazo_vencimiento, fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY id_promocion ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

                ELIF pCampoOrden = 2 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),NVL(nombre_estrategia,0), CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY nombre_estrategia ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 3 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, NVL(CAST(canal AS INTEGER),0) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE canal
					WHEN 2 THEN 1
					WHEN 4 THEN 2
					WHEN 3 THEN 3
					WHEN 1 THEN 4
					ELSE 999
					END) * 1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 4 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 5 THEN
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_vencimiento ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 6 THEN 
                IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 7 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_vencimiento ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 8 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY (CASE cod_estatus WHEN 1 THEN 1
						WHEN 2 THEN 2
						WHEN 0 THEN 3
						ELSE 999
						END) * 1
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 9 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , NVL(fecha_vencimiento,0), tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY fecha_vencimiento ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 10 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, NVL(tasa,0), gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY tasa ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 11 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, NVL(gat_nominal,0), gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_nominal ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 12 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, NVL(gat_real,0), cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_real ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 13 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, NVL(cod_estatus,0), cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE cod_estatus WHEN 1 THEN 1
					WHEN 2 THEN 2
					WHEN 0 THEN 3
					ELSE 999
					END) * 1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                   RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;
            END IF;
        END IF;

        IF iRegistro = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
            LET iIdpromocion     = '';
            LET cNombreEstrategia = '';
            LET cCanal           = '';
            LET dCapitalmin      = '';
            LET dCapitalmax      = '';
            LET iplazoInicio     = 0;
            LET iplazoVencimiento = 0;
            LET dFechaInicio     = '';
            LET dFechaVencimiento = '';
            LET dTasa            = '';
            LET dGatNominal      = '';
            LET dGatReal         = '';
            LET iCodEstatus      = '';
            LET iCodEstatusOrg   = '';  

            RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
        END IF;

        IF iRegistro = 0 AND pRegistros > 0 THEN
            LET cCodRet = '1001';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
        END IF;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CONSULTA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de consultar las campaÃ±as promocionales del producto pagare de acuerdo los filtros propocionados por el cliente y se pinten de color donde:',
'Si el cod_estatus 0 = color rojo, cod_estatus 1 = color verde, cod_estatus 2 = color amarillo',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para recuperar los datos para el producto 1100',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se agregan nuevos retornos para la recuperacion de 6 campos nuevos del producto 3000',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultapagare_totales(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pProducto CHAR(4), 
                                                        pEstatus SMALLINT, 
                                                        pIdPromocion INTEGER,
                                                        pNombrePromocion CHAR(100), 
                                                        pCanal SMALLINT, 
                                                        pCapitalMin DECIMAL(14,2), 
                                                        pCapitalMax DECIMAL(14,2), 
                                                        pFechaInicio DATE, 
                                                        pFechaVencimiento DATE,
                                                        pPlazo_inicio INTEGER, 
                                                        pPlazo_vencimiento INTEGER, 
                                                        pCampoOrden SMALLINT, 
                                                        pOrderBy SMALLINT)
RETURNING CHAR(5)       AS codret,
          INTEGER       AS total_reg; 

    
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iRegistro            INTEGER;
    DEFINE cCmd1                CHAR(6500);
    DEFINE cNombreEstrategia    CHAR(100);
    

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0;
    LET cCmd1            = '';
    LET cNombreEstrategia = '';


    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistro;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
	
        IF pUsuario = '' OR pIdFuncion = '' OR pProducto = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
		END IF;

        --Validamos que el campo orden no exceda de los 13 registros
        IF pCampoOrden IS NOT NULL AND pCampoOrden NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13) THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
        END IF;


		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistro;
		END IF;


        /*IF pProducto <> '3000' OR pProducto <> '1100' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
        END IF;*/

        --SET DEBUG FILE TO '/admintasas/sp_admintasas_consultapagare_totales.out';
		--TRACE ON;
		
		IF pProducto = '3000' THEN -- VALIDACION PRODUCTO
			LET cCmd1 = "";
			LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.nombre_estrategia";
			LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdinvers:sv_admintasas_pagare p INNER JOIN bdinvers:sv_admintasas_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = p.id_promocion)";
			LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
	
			IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
			END IF;
	
			IF TRIM(pNombrePromocion) <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.nombre_estrategia = p.nombre_estrategia";
			END IF;
	
			IF pEstatus IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND cod_estatus = '" || pEstatus ||"'";
			END IF;
	
			IF pCanal IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
			END IF;
	
			IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
			END IF;
	
			IF pPlazo_inicio IS NOT NULL AND pPlazo_vencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (plazo_inicio >= " || pPlazo_inicio || " AND plazo_vencimiento <= " || pPlazo_vencimiento || ")";
			END IF;
	
			IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND fecha_vencimiento <= '"||pFechaVencimiento||"'";
			END IF;
		ELSE -- Producto 1100
			LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.nombre_estrategia";
			LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdicheq:sc_admintasas_invcreciente p INNER JOIN bdicheq:sc_admintasas_inv_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = p.id_promocion)";
			LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
			
			IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
			END IF;
	
			IF TRIM(pNombrePromocion) <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.nombre_estrategia = p.nombre_estrategia";
			END IF;
	
			IF pEstatus IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND s.cod_estatus = '" || pEstatus ||"'";
			END IF;
	
			IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (p.fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND p.fecha_vencimiento <= '"||pFechaVencimiento||"'";
			END IF;
		
		END IF;
			
		
        IF pCampoOrden IS NULL AND (pOrderBy = 1 OR pOrderBy = '') THEN
            LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion ASC";
        END IF;

        IF pCampoOrden IS NULL AND pOrderBy = 2 THEN
            LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion DESC";
        END IF;

        LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || 1 ||"  ASC";
		
		--- Ajuste
		IF pNombrePromocion <> '' THEN
			LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";
		END IF;

		PREPARE stmtId FROM TRIM(cCmd1);
		DECLARE selectQryCur CURSOR FOR stmtId;
		OPEN selectQryCur;
		FETCH selectQryCur INTO cNombreEstrategia;



        WHILE(SQLCODE == 0)	
            IF pNombrePromocion <> '' THEN
                LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));
                --LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";

                IF cNombreEstrategia LIKE pNombrePromocion THEN
                    LET iRegistro = iRegistro + 1;
                END IF;
            ELSE
                LET iRegistro = iRegistro + 1;
            END IF;

            IF iRegistro < 0 THEN
                LET iRegistro = 0;
            END IF;

			FETCH selectQryCur INTO  cNombreEstrategia;
		END WHILE;
			
		CLOSE selectQryCur;
		FREE selectQryCur;
		FREE stmtId;
		
		LET cCmd1 = '';	

        IF NVL(iRegistro, 0) = 0 THEN
            LET cCodRet = '00017';
            
        END IF;

        RETURN cCodRet, iRegistro;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CONSULTA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de consultar el total de las campaÃ±as promocionales del producto pagare de acuerdo los filtros propocionados por el cliente ',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para recuperar los datos para el producto 1100',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturaeactulizagat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pFecha DATE, pProducto CHAR(4), pTasa DECIMAL(9,6), pGatNominal DECIMAL(9,6), pGatReal DECIMAL(9,6), pPlazaInicio INTEGER, pPlazaFin INTEGER, pPeriodo INTEGER, pRowId INTEGER)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dTasa DECIMAL(9,6);
	DEFINE dFechaMax DATE;
	DEFINE iRowID INTEGER;
	-- NUEVO
	DEFINE dGatReal DECIMAL(9,6);
	DEFINE dGatNominal DECIMAL(9,6);
	DEFINE iPeriodo	INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET dTasa = 0.00;
	LET dFechaMax = '';
	LET iRowID = 0;
	-- NUEVO 
	LET dGatReal = 0;
	LET dGatNominal = 0;
	LET iPeriodo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/sp_cap_capturaeactulizagat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;		
		
		-- actualiza e inserta inversion creciente
		IF pBandera = '1' THEN 		-- inv creciente
			/*SELECT  MAX(fecha_publicacion), MAX(rowid)
			INTO dFechaMax, iRowID
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto;
		
			SELECT  tasa
			INTO dTasa
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto
			AND fecha_publicacion = dFechaMax
			AND rowid = iRowID;
			
			IF dFechaMax <> pFecha THEN 
				LET cCodRet = '00133';
			END IF;*/
			
			SELECT COUNT(*)
			INTO iRowID
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto 
			AND rowid = pRowId;
						
			IF NVL(iRowID,0) <> 0 THEN 	
				
				SELECT tasa, gat_nominal, gat_real, periodo
				INTO dTasa, dGatReal, dGatNominal, iPeriodo
				FROM bdicheq:"informix".sc_gat 
				WHERE producto = pProducto
				AND rowid = pRowId;
				
				IF dTasa <> pTasa THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica) 
					VALUES (dTasa, pTasa, pUsuario, CURRENT);
				END IF;
				
				IF dGatReal <> pGatReal THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica) 
					VALUES (dGatReal, pGatReal, pUsuario, CURRENT);
				END IF;
				
				IF dGatNominal <> pGatNominal THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica)
					VALUES (dGatNominal, pGatNominal, pUsuario, CURRENT);
				END IF;
				
				IF iPeriodo <> pPeriodo THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica)
					VALUES (iPeriodo, pPeriodo, pUsuario, CURRENT);
				END IF;
					
				UPDATE bdicheq:"informix".sc_gat
				SET tasa = pTasa, gat_nominal = pGatNominal, gat_real = pGatReal, periodo = pPeriodo
				WHERE producto = pProducto
				--AND fecha_publicacion = dFechaMax
				AND rowid = pRowId;
								
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
			ELSE 
				INSERT INTO bdicheq:"informix".sc_gat (producto, tasa, gat_nominal, gat_real, fecha_publicacion, periodo)
				VALUES (pProducto, pTasa, pGatNominal, pGatReal, CURRENT, pPeriodo);
				RETURN cCodRet;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00282';
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		ELIF pBandera = '2' THEN  --
			
			UPDATE bdicheq:"informix".sc_gat
				SET gat_nominal = pGatNominal, gat_real = pGatReal, tasa = pTasa, periodo = pPeriodo
				WHERE producto = pProducto
				AND fecha_publicacion = pFecha
				AND rowid = pRowId;
							
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		
		ELIF pBandera = '3' THEN -- producto pagare
		
			UPDATE bdinvers:"informix".sv_gat
				SET gat_nomina = pGatNominal, gat_real = pGatReal, tasa = pTasa, periodo = pPeriodo
				WHERE plazo_inicio = pPlazaInicio
				AND plazo_fin = pPlazaFin
				AND rowid = pRowId;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 09/08/2016',
'MODULO: DeBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la actualizacion e insercion de los registros de inversion creciente, cuenta jovenes y producto pagare ',
'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'DESCRIPCION: Se realizo una actualizaciÃ³n a los updates ahora actualiza el nuevo campo de periodo',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/11/2025',
'DESCRIPCION: Se agresa insert a tabla de bitacoreo para actualizacion de datos del producto 1100',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 26/01/2026',
'DESCRIPCION: Se ajusta seccion de producto 1100, para actualizar el valor de la tasa',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_cuentascanceladas(id_usuarioc CHAR(8), id_funcionc CHAR(10), pBandera CHAR(2), pNumCte CHAR(20), pCuenta CHAR(20), pFechaCancelacion CHAR(20), pUsuarioCancela CHAR(8),
													pRegistro INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret, 
			  CHAR(20) AS no_cliente, 
			  CHAR(120) AS nombre_cliente, 
			  CHAR(20) AS no_cuenta, 
			  CHAR(20) AS fecha_ultimo_mov, 
			  DECIMAL(9,2) AS saldo, 
			  CHAR(1) AS cte_notificado, 
			  CHAR(20) AS fecha_cancelacion, 
			  CHAR(40) AS folio_cancelacion, 
			  CHAR(8) AS usuario_cancelacion,
			  CHAR(15) AS status_ant;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE v_TotalRegistros INTEGER;
	
	DEFINE v_NoCliente CHAR(20);
	DEFINE v_NoCuenta CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_FechaUltimoMov DATE;
	DEFINE v_Saldo DECIMAL(9,2);
	DEFINE v_ClienteNotificado BOOLEAN;
	DEFINE v_Contador INTEGER;
	DEFINE v_FechaCancelacion CHAR(20);
	DEFINE v_FolioCancelacion CHAR(40);
	DEFINE v_UsuarioCancelacion CHAR(8);
	DEFINE status_ant CHAR(15);
	DEFINE cIdStatusAnt	CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET v_TotalRegistros = 0;
	
	LET v_NoCliente = '';
	LET v_NoCuenta = '';
	LET v_RazonSocial = '';
	LET v_FechaUltimoMov = TODAY;
	LET v_Saldo = 0;
	LET v_ClienteNotificado = 'f';
	LET v_Contador = 0;
	LET v_FechaCancelacion = '';
	LET v_FolioCancelacion = '';
	LET v_UsuarioCancelacion = '';
	LET status_ant = '';
	LET cIdStatusAnt = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/EAPT/sp_extrae_cuentascan.out';
		-- TRACE ON;
		
		IF pBandera='' OR id_usuarioc = '' OR id_funcionc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(id_usuarioc, id_funcionc) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			FOREACH
				SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.status_ant
				INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, cIdStatusAnt
				FROM bdinteg:si_cliente cliente 
				INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente 
				WHERE canc.status = '0' OR canc.status IS NULL or canc.status = ''
				
				IF cIdStatusAnt = '1' THEN
					LET status_ant = "ACTIVA";
				ELIF cIdStatusAnt = '2' THEN 
					LET status_ant = "CANCELADA";
				ELIF cIdStatusAnt = '3' THEN
					LET status_ant = "BLOQUEADA";
				ELIF cIdStatusAnt = '4' THEN 
					LET status_ant = "INACTIVA";
				ELIF cIdStatusAnt = '5' THEN 
					LET status_ant = "INFORMADA";
				ELIF cIdStatusAnt = '6' THEN 
					LET status_ant = "CONCENTRADA";
				ELIF cIdStatusAnt = '7' THEN 
					LET status_ant = "BENEFICIENCIA";
				ELIF cIdStatusAnt = '8' THEN 
					LET status_ant = "DESCONCENTRADA";
				END IF;
				
				LET v_Contador = v_Contador + 1;
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
			END FOREACH;
			IF v_Contador = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
			
		ELIF pBandera = '2' THEN
		
			IF pNumCte IS NOT NULL AND pNumCte <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and no_cliente = pNumCte
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
				
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pCuenta IS NOT NULL AND pCuenta <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and no_cuenta = pCuenta
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pFechaCancelacion IS NOT NULL AND pFechaCancelacion <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and fecha_cancelacion = pFechaCancelacion
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pUsuarioCancela IS NOT NULL AND pUsuarioCancela <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and usuario_cancela = pUsuarioCancela
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion,status_ant WITH RESUME;
				END FOREACH;
			END IF
			
			IF pRegistro = 0 AND v_Contador = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
			
			IF pRegistro > 0 AND v_Contador = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento encargado de realizar la cancelacion de las cuentass',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_cuentascanceladas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2), pNumCte CHAR(20), pCuenta CHAR(20), pFechaCancelacion DATE, pUsuarioCancela CHAR(8))
	RETURNING CHAR(5) AS codret, INTEGER as total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE v_TotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET v_TotalRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_TotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_cap_cuentascanceladas_totales.out';
		--TRACE ON;
		
		IF pBandera='' OR pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_TotalRegistros;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_TotalRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			SELECT COUNT(*) 
			INTO v_TotalRegistros 
			FROM bdicheq:si_cliente_cancela_notifica 
			WHERE (status = 0 OR status IS NULL OR status = '') AND cliente_notificado = 't'; 
			IF NVL(v_TotalRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_TotalRegistros;
			ELSE
				RETURN cCodRet, v_TotalRegistros;
			END IF;
		ELIF pBandera = '2' THEN
			IF pNumCte <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and no_cliente = pNumCte; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pCuenta <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and no_cuenta = pCuenta; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pFechaCancelacion IS NOT NULL THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and fecha_cancelacion = pFechaCancelacion; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pUsuarioCancela <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and usuario_cancela = pUsuarioCancela; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
		END IF;
		RETURN cCodRet, v_TotalRegistros;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado de recuperar el total de registros de las cuentas canceladad y no canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_genrep_ctascanceladas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150), pNumCte CHAR(20), pNumCta CHAR(20), pFechaCancelacion CHAR(20), 
																	pUsuarioCancelacion CHAR(20))
	RETURNING CHAR(5) AS codret,
			  CHAR(150) AS nomArchivo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cSql CHAR(5000);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(150);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	--Ruta Desarollo
	--LET cRutaInformix = '/informix/bin/';
	--Ruta Produccion
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_genrep_ctascanceladas.out';
		--TRACE ON;

		IF pUsuario = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;

		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'REPORTE_CUENTAS_CANCELADAS_'||TO_CHAR(CURRENT,'%Y%m%d')||'.xls'; --.csv .txt
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'NO. CLIENTE','NOMBRE CLIENTE','NO. CUENTA','ESTATUS ANTES CANCELACION','ESTATUS ACTUAL','FECHA ULTIMO MOVIMIENTO','SALDO','CLIENTE NOTIFICADO','FECHA CANCELACION','FOLIO CANCELACION','USUARIO CANCELACION' FROM systables WHERE tabid = 1 ";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT cliente.numcte, cliente.razon_social, ''''||cliente_notifica.no_cuenta, CASE WHEN cliente_notifica.status_ant = 1 THEN 'ACTIVA' WHEN cliente_notifica.status_ant = 4 THEN 'INACTIVA' ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHEN cliente_notifica.status_ant = 6 THEN 'CONCENTRADA' WHEN cliente_notifica.status_ant = 7 THEN 'BENEFICIENCIA' WHEN cliente_notifica.status_ant = 8 THEN 'DESCONCENTRADA' ELSE '' END CASE, 'CANCELADO',TO_CHAR(cliente_notifica.fec_ultimo_mov,'%d/%m/%Y'), TO_CHAR(cliente_notifica.saldo), ";
		LET cCmd1 =""||TRIM(cCmd1)||" CASE WHEN cliente_notificado = 'f' THEN 'NO' ELSE 'SI' END, TO_CHAR(cliente_notifica.fecha_cancelacion,'%d/%m/%Y'), ''''||cliente_notifica.folio_cancelacion,  ";
		LET cCmd1 =""||TRIM(cCmd1)||" cliente_notifica.usuario_cancela FROM bdinteg:si_cliente cliente ";
		LET cCmd1 =""||TRIM(cCmd1)||" INNER JOIN bdicheq:si_cliente_cancela_notifica cliente_notifica ON cliente.numcte = cliente_notifica.no_cliente ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE cliente_notifica.status = '2'";
		
		IF pNumCte <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente.numcte = '"||TRIM(pNumCte)||"'";
		END IF;
		IF pNumCta <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.no_cuenta = '"||TRIM(pNumCta)||"'";
		END IF;
		IF pFechaCancelacion <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.fecha_cancelacion = '"||TRIM(pFechaCancelacion)||"'";
		END IF;
		IF pUsuarioCancelacion <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.usuario_cancela = '"||TRIM(pUsuarioCancelacion)||"'";
		END IF;
		
		--LET cCmd1 =""||TRIM(cCmd1)||" ";
		
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';		--Cambiar Base de datos segun el reporte
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);


		RETURN cCodRet, cNombreReporte;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de generar el reporte de las cuentas canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_genrep_ctasnocanceladas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150))
	RETURNING CHAR(5) AS codret,
			  CHAR(150) AS nomArchivo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cSql CHAR(5000);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(150);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	--Ruta Desarollo
	--LET cRutaInformix = '/informix/bin/';
	--Ruta Produccion
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;

		SET DEBUG FILE TO '/tmp/mfinis/sp_cap_genrep_ctasnocanceladas.out';
		TRACE ON;

		IF pUsuario = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;

		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'REPORTE_CUENTAS_NOCANCELADAS_'||TO_CHAR(CURRENT,'%Y%m%d')||'.xls'; --.csv .txt
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'NO. CLIENTE','NOMBRE CLIENTE','NO. CUENTA','FECHA ULTIMO MOVIMIENTO','SALDO','CLIENTE NOTIFICADO','MOTIVO' FROM systables WHERE tabid = 1 ";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT no_cliente,nombre_cliente,TO_CHAR(no_cuenta),TO_CHAR(fec_ultimo_mov,'%d/%m/%Y'), TO_CHAR(saldo),CASE WHEN cliente_notificado = 'f' THEN 'NO' ELSE 'SI' END, motivo_no_cancelar ";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:'informix'.sw_ctasnocanceladas ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_usuario = '"||pUsuario||"'";
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryRepCuentasNoCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryRepCuentasNoCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

        --DEPURACION DE TABLA DE TRABAJO
		DELETE FROM bdicnweb:"informix".sw_ctasnocanceladas WHERE id_usuario = pUsuario;

		RETURN cCodRet, cNombreReporte;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de generar el reporte de las cuentas que no fueron canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_cuentacan(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret, 
	          BOOLEAN AS resultado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_Cliente CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_SdoActual MONEY;
	DEFINE v_SdoCongelado MONEY;
	DEFINE v_LimSbgCCC MONEY;
	DEFINE v_ImpChqSbg MONEY;
	DEFINE v_ComPendiente MONEY;
	DEFINE v_FecUltMov DATE;
	DEFINE v_Producto CHAR(4);
	DEFINE v_ProdNoCancelacion INTEGER;
	DEFINE anio_actual INTEGER;
    DEFINE anio_pasado INTEGER;
    DEFINE mes_actual INTEGER;
	DEFINE v_Anio SMALLINT;
	
	DEFINE v_capvigprom1 MONEY; 
	DEFINE v_capvigprom2 MONEY;
	DEFINE v_capvigprom3 MONEY;
	DEFINE v_capvigprom4 MONEY; 
	DEFINE v_capvigprom5 MONEY;
	DEFINE v_capvigprom6 MONEY;
	DEFINE v_capvigprom7 MONEY;
	DEFINE v_capvigprom8 MONEY;
	DEFINE v_capvigprom9 MONEY;
	DEFINE v_capvigprom10 MONEY;
	DEFINE v_capvigprom11 MONEY;
	DEFINE v_capvigprom12 MONEY;
	
	DEFINE v_SaldoProm1 MONEY; 
	DEFINE v_SaldoProm2 MONEY;
	DEFINE v_SaldoProm3 MONEY;
	DEFINE v_SaldoProm4 MONEY; 
	DEFINE v_SaldoProm5 MONEY;
	DEFINE v_SaldoProm6 MONEY;
	DEFINE v_SaldoProm7 MONEY;
	DEFINE v_SaldoProm8 MONEY;
	DEFINE v_SaldoProm9 MONEY;
	DEFINE v_SaldoProm10 MONEY;
	DEFINE v_SaldoProm11 MONEY;
	DEFINE v_SaldoProm12 MONEY;
	
	DEFINE v_CreditosVigentes INTEGER;
	DEFINE v_CreditosVigentes1 INTEGER;
	DEFINE v_CreditosVigentes2 INTEGER;
	
	DEFINE v_AclaracionPendiente INTEGER;
	
	DEFINE v_Spei INTEGER;
	
	define v_EmpresaPrueba INTEGER;
	DEFINE v_CuentaFideicomiso INTEGER;
	DEFINE v_FechaActual DATE;
	
	DEFINE v_mes_actual INTEGER;
	
	DEFINE v_mes_anio_actual INTEGER;
	DEFINE v_mes_anio_anterior INTEGER;
	
	DEFINE v_SaldoPromedioTotal MONEY;
	
	DEFINE v_SaldoSobregirado MONEY;
	DEFINE v_SaldoActual MONEY;
	
	DEFINE v_SaldoActualSegVal MONEY;
	DEFINE v_SaldoCuenta MONEY;
	
	DEFINE v_Resultado BOOLEAN;

    LET v_FechaActual = TODAY;
    --LET p_cuenta = '10305923635';
    
    LET mes_actual = MONTH(v_FechaActual);
	
	LET v_capvigprom1 = 0; 
	LET v_capvigprom2 = 0;
	LET v_capvigprom3 = 0;
	LET v_capvigprom4 = 0; 
	LET v_capvigprom5 = 0;
	LET v_capvigprom6 = 0;
	LET v_capvigprom7 = 0;
	LET v_capvigprom8 = 0;
	LET v_capvigprom9 = 0;
	LET v_capvigprom10 = 0;
	LET v_capvigprom11 = 0;
	LET v_capvigprom12 = 0;
	
	LET v_SaldoProm1 = 0; 
	LET v_SaldoProm2 = 0;
	LET v_SaldoProm3 = 0;
	LET v_SaldoProm4 = 0; 
	LET v_SaldoProm5 = 0;
	LET v_SaldoProm6 = 0;
	LET v_SaldoProm7 = 0;
	LET v_SaldoProm8 = 0;
	LET v_SaldoProm9 = 0;
	LET v_SaldoProm10 = 0;
	LET v_SaldoProm11 = 0;
	LET v_SaldoProm12 = 0;
	
	LET v_SaldoPromedioTotal = 0;
	
	LET v_Anio = 0;
	
	LET v_mes_anio_actual = 0;
	LET v_mes_anio_anterior = 0;

	LET v_Cuenta = '';
	LET v_Cliente  = '';
	LET v_RazonSocial = '';
	LET v_SdoActual = 0;
	LET v_SdoCongelado = 0;
	LET v_LimSbgCCC = 0;
	LET v_ImpChqSbg = 0;
	LET v_ComPendiente = 0;
	LET v_FecUltMov = CURRENT;
	LET v_Producto = '0000';
	LET v_ProdNoCancelacion = 0;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	
	LET v_SaldoSobregirado = 0;
	LET v_SaldoActual = 0;
	
	LET v_CreditosVigentes = 0;
	LET v_CreditosVigentes1 = 0;
	LET v_CreditosVigentes2 = 0;
	
	LET v_SaldoActualSegVal = 0;
	LET v_SaldoCuenta = 0;
	
	LET v_AclaracionPendiente = 0;
	LET v_EmpresaPrueba = 0;
	LET v_CuentaFideicomiso = 0;
	
	LET v_Spei = 0;
	
	LET v_Resultado = 'f';
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Resultado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/sp_extrae_cuentascan.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Resultado;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Resultado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT FIRST 1 chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto
		INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto
		FROM bdinteg:si_cliente cli
		INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
		WHERE chq.cuenta = pCuenta AND chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
		AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH;
		
		SELECT COUNT(*) INTO v_ProdNoCancelacion 
		FROM bdicheq:sc_productonocancelacion 
		WHERE producto = v_Producto;
		
		IF NVL(v_ProdNoCancelacion,0) = 0 THEN
			LET v_mes_anio_actual = mes_actual - 1;
			LET v_mes_anio_anterior = 12 - v_mes_anio_actual;
			FOREACH
				SELECT
					capvigprom1, capvigprom2, capvigprom3, capvigprom4, capvigprom5, 
					capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, 
					capvigprom11, capvigprom12, anio
				INTO 
					v_capvigprom1, v_capvigprom2, v_capvigprom3, v_capvigprom4, v_capvigprom5,
					v_capvigprom6, v_capvigprom7, v_capvigprom8, v_capvigprom9, v_capvigprom10,
					v_capvigprom11, v_capvigprom12, v_Anio
				FROM 
					bdicheq:sc_sdomensualc
				WHERE
					cuenta = v_Cuenta
				AND				
					(anio = YEAR(v_FechaActual - 12 UNITS MONTH)
				OR
					anio = YEAR(v_FechaActual - 1 UNITS MONTH))
					
				IF v_Anio = YEAR(v_FechaActual - 1) THEN
					IF v_mes_anio_anterior = 1 THEN
						LET v_SaldoProm1 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 2 THEN
						LET v_SaldoProm1 = v_capvigprom11;
						LET v_SaldoProm2 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 3 THEN
						LET v_SaldoProm1 = v_capvigprom10;
						LET v_SaldoProm2 = v_capvigprom11;
						LET v_SaldoProm3 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 4 THEN
						LET v_SaldoProm1 = v_capvigprom9;
						LET v_SaldoProm2 = v_capvigprom10;
						LET v_SaldoProm3 = v_capvigprom11;
						LET v_SaldoProm4 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 5 THEN
						LET v_SaldoProm1 = v_capvigprom8;
						LET v_SaldoProm2 = v_capvigprom9;
						LET v_SaldoProm3 = v_capvigprom10;
						LET v_SaldoProm4 = v_capvigprom11;
						LET v_SaldoProm5 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 6 THEN
						LET v_SaldoProm1 = v_capvigprom7;
						LET v_SaldoProm2 = v_capvigprom8;
						LET v_SaldoProm3 = v_capvigprom9;
						LET v_SaldoProm4 = v_capvigprom10;
						LET v_SaldoProm5 = v_capvigprom11;
						LET v_SaldoProm6 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 7 THEN
						LET v_SaldoProm1 = v_capvigprom6;
						LET v_SaldoProm2 = v_capvigprom7;
						LET v_SaldoProm3 = v_capvigprom8;
						LET v_SaldoProm4 = v_capvigprom9;
						LET v_SaldoProm5 = v_capvigprom10;
						LET v_SaldoProm6 = v_capvigprom11;
						LET v_SaldoProm7 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 8 THEN
						LET v_SaldoProm1 = v_capvigprom5;
						LET v_SaldoProm2 = v_capvigprom6;
						LET v_SaldoProm3 = v_capvigprom7;
						LET v_SaldoProm4 = v_capvigprom8;
						LET v_SaldoProm5 = v_capvigprom9;
						LET v_SaldoProm6 = v_capvigprom10;
						LET v_SaldoProm7 = v_capvigprom11;
						LET v_SaldoProm8 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 9 THEN
						LET v_SaldoProm1 = v_capvigprom4;
						LET v_SaldoProm2 = v_capvigprom5;
						LET v_SaldoProm3 = v_capvigprom6;
						LET v_SaldoProm4 = v_capvigprom7;
						LET v_SaldoProm5 = v_capvigprom8;
						LET v_SaldoProm6 = v_capvigprom9;
						LET v_SaldoProm7 = v_capvigprom10;
						LET v_SaldoProm8 = v_capvigprom11;
						LET v_SaldoProm9 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 10 THEN
						LET v_SaldoProm1 = v_capvigprom3;
						LET v_SaldoProm2 = v_capvigprom4;
						LET v_SaldoProm3 = v_capvigprom5;
						LET v_SaldoProm4 = v_capvigprom6;
						LET v_SaldoProm5 = v_capvigprom7;
						LET v_SaldoProm6 = v_capvigprom8;
						LET v_SaldoProm7 = v_capvigprom9;
						LET v_SaldoProm8 = v_capvigprom10;
						LET v_SaldoProm9 = v_capvigprom11;
						LET v_SaldoProm10 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 11 THEN
						LET v_SaldoProm1 = v_capvigprom2;
						LET v_SaldoProm2 = v_capvigprom3;
						LET v_SaldoProm3 = v_capvigprom4;
						LET v_SaldoProm4 = v_capvigprom5;
						LET v_SaldoProm5 = v_capvigprom6;
						LET v_SaldoProm6 = v_capvigprom7;
						LET v_SaldoProm7 = v_capvigprom8;
						LET v_SaldoProm8 = v_capvigprom9;
						LET v_SaldoProm9 = v_capvigprom10;
						LET v_SaldoProm10 = v_capvigprom11;
						LET v_SaldoProm11 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 12 THEN
						LET v_SaldoProm1 = v_capvigprom1;
						LET v_SaldoProm2 = v_capvigprom2;
						LET v_SaldoProm3 = v_capvigprom3;
						LET v_SaldoProm4 = v_capvigprom4;
						LET v_SaldoProm5 = v_capvigprom5;
						LET v_SaldoProm6 = v_capvigprom6;
						LET v_SaldoProm7 = v_capvigprom7;
						LET v_SaldoProm8 = v_capvigprom8;
						LET v_SaldoProm9 = v_capvigprom9;
						LET v_SaldoProm10 = v_capvigprom10;
						LET v_SaldoProm11 = v_capvigprom11;
						LET v_SaldoProm12 = v_capvigprom12;
					END IF;
				ELIF v_Anio = YEAR(v_FechaActual) THEN
					IF v_mes_anio_actual = 1 THEN
						LET v_SaldoProm12 = v_capvigprom1;
					ELIF v_mes_anio_actual = 2 THEN
						LET v_SaldoProm11 = v_capvigprom1;
						LET v_SaldoProm12 = v_capvigprom2;
					ELIF v_mes_anio_actual = 3 THEN
						LET v_SaldoProm10 = v_capvigprom1;
						LET v_SaldoProm11 = v_capvigprom2;
						LET v_SaldoProm12 = v_capvigprom3;
					ELIF v_mes_anio_actual = 4 THEN
						LET v_SaldoProm9 = v_capvigprom1;
						LET v_SaldoProm10 = v_capvigprom2;
						LET v_SaldoProm11 = v_capvigprom3;
						LET v_SaldoProm12 = v_capvigprom4;
					ELIF v_mes_anio_actual = 5 THEN
						LET v_SaldoProm8 = v_capvigprom1;
						LET v_SaldoProm9 = v_capvigprom2;
						LET v_SaldoProm10 = v_capvigprom3;
						LET v_SaldoProm11 = v_capvigprom4;
						LET v_SaldoProm12 = v_capvigprom5;
					ELIF v_mes_anio_actual = 6 THEN
						LET v_SaldoProm7 = v_capvigprom1;
						LET v_SaldoProm8 = v_capvigprom2;
						LET v_SaldoProm9 = v_capvigprom3;
						LET v_SaldoProm10 = v_capvigprom4;
						LET v_SaldoProm11 = v_capvigprom5;
						LET v_SaldoProm12 = v_capvigprom6;
					ELIF v_mes_anio_actual = 7 THEN
						LET v_SaldoProm6 = v_capvigprom1;
						LET v_SaldoProm7 = v_capvigprom2;
						LET v_SaldoProm8 = v_capvigprom3;
						LET v_SaldoProm9 = v_capvigprom4;
						LET v_SaldoProm10 = v_capvigprom5;
						LET v_SaldoProm11 = v_capvigprom6;
						LET v_SaldoProm12 = v_capvigprom7;
					ELIF v_mes_anio_actual = 8 THEN
						LET v_SaldoProm5 = v_capvigprom1;
						LET v_SaldoProm6 = v_capvigprom2;
						LET v_SaldoProm7 = v_capvigprom3;
						LET v_SaldoProm8 = v_capvigprom4;
						LET v_SaldoProm9 = v_capvigprom5;
						LET v_SaldoProm10 = v_capvigprom6;
						LET v_SaldoProm11 = v_capvigprom7;
						LET v_SaldoProm12 = v_capvigprom8;
					ELIF v_mes_anio_actual = 9 THEN
						LET v_SaldoProm4 = v_capvigprom1;
						LET v_SaldoProm5 = v_capvigprom2;
						LET v_SaldoProm6 = v_capvigprom3;
						LET v_SaldoProm7 = v_capvigprom4;
						LET v_SaldoProm8 = v_capvigprom5;
						LET v_SaldoProm9 = v_capvigprom6;
						LET v_SaldoProm10 = v_capvigprom7;
						LET v_SaldoProm11 = v_capvigprom8;
						LET v_SaldoProm12 = v_capvigprom9;
					ELIF v_mes_anio_actual = 10 THEN
						LET v_SaldoProm3 = v_capvigprom1;
						LET v_SaldoProm4 = v_capvigprom2;
						LET v_SaldoProm5 = v_capvigprom3;
						LET v_SaldoProm6 = v_capvigprom4;
						LET v_SaldoProm7 = v_capvigprom5;
						LET v_SaldoProm8 = v_capvigprom6;
						LET v_SaldoProm9 = v_capvigprom7;
						LET v_SaldoProm10 = v_capvigprom8;
						LET v_SaldoProm11 = v_capvigprom9;
						LET v_SaldoProm12 = v_capvigprom10;
					ELIF v_mes_anio_actual = 11 THEN
						LET v_SaldoProm2 = v_capvigprom1;
						LET v_SaldoProm3 = v_capvigprom2;
						LET v_SaldoProm4 = v_capvigprom3;
						LET v_SaldoProm5 = v_capvigprom4;
						LET v_SaldoProm6 = v_capvigprom5;
						LET v_SaldoProm7 = v_capvigprom6;
						LET v_SaldoProm8 = v_capvigprom7;
						LET v_SaldoProm9 = v_capvigprom8;
						LET v_SaldoProm10 = v_capvigprom9;
						LET v_SaldoProm11 = v_capvigprom10;
						LET v_SaldoProm12 = v_capvigprom11;
					ELIF v_mes_anio_actual = 12 THEN
						LET v_SaldoProm1 = v_capvigprom1;
						LET v_SaldoProm2 = v_capvigprom2;
						LET v_SaldoProm3 = v_capvigprom3;
						LET v_SaldoProm4 = v_capvigprom4;
						LET v_SaldoProm5 = v_capvigprom5;
						LET v_SaldoProm6 = v_capvigprom6;
						LET v_SaldoProm7 = v_capvigprom7;
						LET v_SaldoProm8 = v_capvigprom8;
						LET v_SaldoProm9 = v_capvigprom9;
						LET v_SaldoProm10 = v_capvigprom10;
						LET v_SaldoProm11 = v_capvigprom11;
						LET v_SaldoProm12 = v_capvigprom12;
					END IF;
				END IF;
				
			END FOREACH
			LET v_SaldoPromedioTotal = v_capvigprom1 + v_capvigprom2 + v_capvigprom3 + v_capvigprom4 + v_capvigprom5 + v_capvigprom6 + v_capvigprom7 + v_capvigprom8 + v_capvigprom9 + v_capvigprom10 + v_capvigprom11 + v_capvigprom2;
			IF NVL(v_SaldoPromedioTotal,0) = 0 THEN
				FOREACH
					SELECT imp_chq_sbg, sdo_actual 
					INTO v_SaldoSobregirado, v_SaldoActual 
					FROM bdicheq:sc_maechq 
					WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
				END FOREACH
				IF NVL(v_SaldoSobregirado,0) = 0 THEN
					IF NVL(v_SaldoActual,0) = 0 THEN
						--Aqui va el otro calculo del saldo actual
						SELECT (cheq.sdo_actual - (cheq.sdo_retenido + cheq.sdo_cong + cheq.imp_sbg_ccc)) AS saldo_actual, bal.sdo_cta
						INTO v_SaldoActualSegVal, v_SaldoCuenta
						FROM bdicheq:sc_maechq cheq
						INNER JOIN bditransfer:tf_maecte mae ON mae.numcte_tf = cheq.num_cte
						INNER JOIN bditransfer:tf_account_balance_customer bal ON bal.cuenta = mae.cuenta_tf
						WHERE cheq.num_cte = v_Cliente  AND (mae.numcte = v_Cliente OR mae.numcte_tf = v_Cliente) AND mae.status_cta != '2' AND bal.fecha_proceso = (SELECT MAX(bal2.fecha_proceso)
						FROM bditransfer:tf_account_balance_customer bal2
						WHERE bal2.cuenta = bal.cuenta);
						
						IF NVL(v_SaldoActualSegVal,0) = 0 AND NVL(v_SaldoCuenta,0) = 0 THEN
							SELECT COUNT(*) INTO v_CreditosVigentes FROM bdicred:sd_ctascarg WHERE num_cta = v_Cuenta AND naturaleza = naturaleza;
							IF v_CreditosVigentes > 0 THEN
								SELECT count(ctascar.num_cta)
								INTO v_CreditosVigentes1
								FROM bdicred:sd_ctascarg ctascar
								INNER JOIN bdicred:sd_maecred cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
								WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
								
								SELECT count(ctascar.num_cta)
								INTO v_CreditosVigentes2
								FROM bdicred:sd_ctascarg ctascar
								INNER JOIN bdicred:sd_maecredcrd cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
								WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
							END IF;
							
							IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
								SELECT count(producto.numero_cuenta)
								INTO v_AclaracionPendiente
								FROM bdiaclaracion:acl_producto producto
								INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
								WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
								IF NVL(v_AclaracionPendiente,0) = 0 THEN
									SELECT COUNT(*) 
									INTO v_EmpresaPrueba
									FROM bdicnweb:si_cliente_emp_pru
									WHERE no_cliente = v_Cliente;
										
									IF NVL(v_EmpresaPrueba,0) = 0 THEN
										SELECT COUNT(*) 
										INTO v_CuentaFideicomiso
										FROM bdinteg:si_ctepm 
										WHERE numcte = v_Cliente AND 
										(giro IS NULL OR giro = '' OR actividadsocial IS NULL OR actividadsocial = '' OR sufijo IS NULL OR sufijo = '' OR telefono_contacto IS NULL OR telefono_contacto = '' 
												OR tipo_poder IS NULL OR tipo_poder = '' OR tipo_admon IS NULL OR tipo_admon = '' OR tipo_org IS NULL OR tipo_org = '');
										IF v_CuentaFideicomiso <= 0 THEN
											SELECT COUNT(*) 
											INTO v_Spei
											FROM bdicheq:sc_movdia 
											WHERE cuenta = v_Cuenta AND transacc = '0274';
											IF NVL(v_Spei,0) = 0 THEN
												LET v_Resultado = 't';
											ELSE 
												INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
												VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTE TIENE UN SPEI EN PROCESO', pUsuario);
											
												LET v_Resultado = 'f';
											END IF;
										ELSE 
											INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
											VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE TIPO FIDEICOMISO', pUsuario);
											LET v_Resultado = 'f';
										END IF;
									ELSE
										INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
										VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE PRUEBA', pUsuario);
		
										LET v_Resultado = 'f';
									END IF;
								ELSE 
									INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
									VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE ACLARACIONES PENDIENTES', pUsuario);
		
									LET v_Resultado = 'f';
								END IF;
							ELSE
								INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
								VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE CREDITOS VIGENTES', pUsuario);
		
								LET v_Resultado = 'f';
							END IF;
						ELSE 
							INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
							VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
							LET v_Resultado = 'f';
						END IF;
					ELSE
						INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
						VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
						LET v_Resultado = 'f';
					END IF;
				ELSE 
					INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
					VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA PRESENTA SALDO SOBREGIRADO', pUsuario);
		
					LET v_Resultado = 'f';
				END IF;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
				VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO PROMEDIO DE LA CUENTA ES MAYOR A 0', pUsuario);
		
				LET v_Resultado = 'f';
			END IF;
		ELSE
			INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
			VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL PRODUCTO NO PERMITE CANCELAR', pUsuario);
		
			LET v_Resultado = 'f';
		END IF;
		
		RETURN cCodRet, v_Resultado;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de validar si la cuenta es candidata a cancelar',
'BD: bdicheq';


CREATE PROCEDURE "informix".sp_inserta_creditoexcluir( pCuenta CHAR(20))

-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "sp_inserta_creditoexcluir.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
    	
 SELECT id_registro, status
	INTO vRegistro, vStatusSol
	FROM bdicnweb:"informix".sw_evc_excluidos
	WHERE  cuenta = pCuenta
	AND id_registro = (select max(id_registro) from bdicnweb:"informix".sw_evc_excluidos where cuenta = pCuenta);

	IF (SELECT COUNT(*) FROM bdicnweb:"informix".sw_evc_excluidos WHERE cuenta = pCuenta) > 1 THEN

         IF vStatusSol <> 'P' THEN
						
			delete from sw_evc_excluidos where cuenta = pCuenta
			and id_registro < vRegistro;
			
         END IF;
	END IF;
END PROCEDURE;