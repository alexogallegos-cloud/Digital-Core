CREATE PROCEDURE "informix".sp_modificaguardacampania(cEmpresa CHAR(3), cSucursal CHAR(5), cZona CHAR(5), cSistema CHAR(2), cProducto CHAR(5), sTransaccion SMALLINT, cEstatus CHAR(1), sNivel SMALLINT, sActiva SMALLINT, sAct_Zona SMALLINT, sCombinable SMALLINT, sCampania SMALLINT, sJerarquia SMALLINT, cMensaje1 CHAR(55), cMensaje2 CHAR(55), cMensaje3 CHAR(55), cMensaje4 CHAR(55), cMensaje5 CHAR(55), cMensaje6 CHAR(55),cNomCamp CHAR(40), cCampNueva CHAR(1)) --DSB 20-08-2013 SE AGREGA EL PARAMETRO CNOMCAMP Y CCAMPNUEVA
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Guarda o modifica la información de la campaña
--Realizó: Nancy Sevilla Camacho
 
--MODIFICACION: 
--DSB 20-08-2013
--DESCRIPCION: Se modifica para que inserte nombre de campaña y cree un solo mensaje por campaña
--MODIFICO: Obed Vega
--FECHA MODIFICACION: 20/Agosto/2013
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5);   -- Código_retorno

--DEFINICION DE VARIABLES--
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);

---------------------------	
DEFINE sIdMensajeMax SMALLINT;
DEFINE sIdMensaje SMALLINT;

--INICIALIZACION DE VARIABLES--
LET iSqlErr       = 0;
LET cCodRet       = '00000';
LET sIdMensajeMax = 0;
LET sIdMensaje    = 0;

	--SET DEBUG FILE TO "/respaldosbd/obed/sp_modificaguardacampania.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(cEmpresa, '') = '' OR NVL(sCampania, 0) = '' OR NVL(sJerarquia, 0) = '' THEN
		
			LET cCodRet = '00002';
			RETURN cCodRet;	
		
		ELSE
				
			IF TRIM(cCampNueva) <> "1" THEN --SI NO ES UNA NUEVA CAMPAÑA
			
				IF TRIM(cProducto) = "0" THEN
					LET cProducto = "T";
				END IF;
	
				--ACTUALIZA EL REGISTRO EN LA TABLA SI_MAECAMP 
				UPDATE bdinteg:"informix".si_maecamp 
				   SET num_producto = TRIM(cProducto), 
					   sistema = cSistema, 
					   estatus = cEstatus, 
					   idnivel = sNivel,					   
					   activa = sActiva, 
					   combinable = sCombinable,
					   tran_nro = sTransaccion,
					   nombre = cNomCamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;			
				
				SELECT FIRST 1 idmensaje
				  INTO sIdMensaje
				  FROM bdinteg:"informix".si_maecamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;
				   
				-- ACTUALIZA EL MENSAJE EN LA TABLA SI_DETCAMP PARA LA CAMPAÑA QUE SE MODIFICA
				IF NVL(sIdMensaje,0) <> '' Or sIdMensaje IS NOT NULL THEN
					DELETE FROM bdinteg:"informix".si_detcamp 
					WHERE empresa = cEmpresa 
					AND idmensaje = sIdMensaje
					AND orden IS NOT NULL;
									
					IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje1, 1);	
					END IF;
					
					IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje2, 2);	
					END IF;
					
					IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
					   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje3, 3);	
					END IF;
					
					IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje4, 4);	
					END IF;
					
					IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje5, 5);	
					END IF;
					
					IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensaje, cMensaje6, 6);							   		   
					END IF;					   
					RETURN cCodRet;
				ELSE
					--NO SE ENCONTRÓ EL IDMENSAJE PARA ESA CAMPAÑA Y JERARQUÍA
					LET cCodRet = '00001';
					RETURN cCodRet;
				END IF;
			
			ELSE
				SELECT FIRST 1 idmensaje
				  INTO sIdMensaje
				  FROM bdinteg:"informix".si_maecamp
				 WHERE idcamp = sCampania
				   AND idJerarquia = sJerarquia
				   AND empresa = cEmpresa
				   AND sucursal IS NOT NULL;
				
				IF NVL(sIdMensaje,0) <> '' Or sIdMensaje IS NOT NULL THEN
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO bdinteg:"informix".si_maecamp
							   (empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
						 VALUES
							   (cEmpresa, cSucursal, cProducto, cSistema, cEstatus, sCampania, sJerarquia, sNivel, cZona, sActiva, sAct_Zona, sCombinable, sIdMensaje, sTransaccion, cNomCamp);
				
				ELSE
					-- SE OBTIENE EL VALOR MÁXIMO DEL ID MENSAJE
					SELECT MAX(idmensaje)
					  INTO sIdMensajeMax
					  FROM bdinteg:"informix".si_maecamp;
									
					IF NVL(sIdMensajeMax,0) = "" OR sIdMensajeMax IS NULL THEN
						LET sIdMensajeMax = 1;			
					ELSE
						LET sIdMensajeMax = sIdMensajeMax + 1;
					END IF;
				
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO bdinteg:"informix".si_maecamp
							   (empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
						 VALUES
							   (cEmpresa, cSucursal, cProducto, cSistema, cEstatus, sCampania, sJerarquia, sNivel, cZona, sActiva, sAct_Zona, sCombinable, sIdMensajeMax, sTransaccion, cNomCamp);   
				
					-- INSERTA EN LA TABLA SI_DETCAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje1, 1);	
					END IF;
					
					IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje2, 2);	
					END IF;
					
					IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
					   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje3, 3);	
					END IF;
					
					IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje4, 4);	
					END IF;
					
					IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje5, 5);	
					END IF;
					
					IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

						INSERT INTO bdinteg:"informix".si_detcamp
								   (empresa, idmensaje, mensaje, orden)
							 VALUES
								   (cEmpresa, sIdMensajeMax, cMensaje6, 6);							   		   
					END IF;					   
				END IF;
				RETURN cCodRet;		
			END IF;
		END IF;
	END;
END PROCEDURE;