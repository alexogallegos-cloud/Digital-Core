CREATE PROCEDURE "informix".sp_consulta_campania(iTipoBusqueda INTEGER, cId CHAR(5))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se obtienen los datos de las campañas por Zona y Sucursal
--Realizó: Nancy Sevilla Camacho
--Fecha: 09/03/2012  
--BD: BDINTEG                    
--------------------------------------------------------------------
-- MODIFICACIÓN 
--Se agrega condición en la consulta de la tabla si_maecamp
--Modificó: Nancy Sevilla Camacho
--Fecha: 28/06/2012 
--BD: BDINTEG     
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5),   -- Código_retorno
SMALLINT,  -- Número de transacción
CHAR(50),  -- Descripción de la transacción
CHAR(5),   -- Número de producto
CHAR(50),  -- Descripción del producto
CHAR(1),   -- Código Estatus
CHAR(20),  -- Estatus Cta/Tar
SMALLINT,  -- Id Campaña
SMALLINT,  -- Id Jerarquía
SMALLINT,  -- Código Activa                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
CHAR(2),   -- Activa
CHAR(55),  -- Mensaje con variables
CHAR(2),   -- Sistema
SMALLINT,  -- Combinable
CHAR(55),  -- Mensaje1 con valores
SMALLINT,  -- Act_Zona        --28/06/2012	
CHAR(5);   -- Sucursal        --28/06/2012
 
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE iRows        INTEGER;
---------------------------	
DEFINE cNumProducto CHAR(5);
DEFINE cSistema     CHAR(2);
DEFINE cEstatus     CHAR(1);
DEFINE cEstatusDesc CHAR(20);
DEFINE sIdCampania  SMALLINT;
DEFINE sIdJerarquia SMALLINT;
DEFINE sIdZona      SMALLINT;
DEFINE cActivaDesc  CHAR(2);
DEFINE sAct_Zona    SMALLINT;
DEFINE cMensajeVar  CHAR(55);
DEFINE sTransaccion SMALLINT;
DEFINE cDescTransac CHAR(50);
DEFINE cNumProd     CHAR(4);
DEFINE cProducto    CHAR(50);
DEFINE sOrden       SMALLINT;
DEFINE sCombinable  SMALLINT;
DEFINE cMensajeVal  CHAR(55);
DEFINE sIdMensaje   SMALLINT;
DEFINE sActiva      SMALLINT;  --28/06/2012
DEFINE cPlaza       CHAR(3);   --28/06/2012
DEFINE sSucursal    CHAR(5);   --28/06/2012

--INICIALIZACION DE VARIABLES--
LET iSqlErr       = 0;
LET cCodRet       = '00000';
LET cCodRet2      = '00000';
LET iRows         = 0;
LET cNumProducto  = "";
LET cSistema      = "";
LET cEstatus      = "";
LET cEstatusDesc  = "";
LET sIdCampania   = 0;
LET sIdJerarquia  = 0;
LET sIdZona       = 0;
LET sActiva       = "";
LET cActivaDesc   = 0;
LET cMensajeVar   = "";
LET sTransaccion  = 0;
LET cDescTransac  = "";
LET cNumProd      = "";
LET cProducto     = "";
LET sOrden        = 0;
LET sCombinable	  = 0;
LET cMensajeVal   = "";
LET sIdMensaje    = 0;
LET sAct_Zona     = 0;   --28/06/2012
LET cPlaza        = '';  --28/06/2012
LET sSucursal     = '';  --28/06/2012

	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consulta_campania.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,
					   sTransaccion,
					   cDescTransac,
					   cNumProd,					   
					   cProducto,
					   cEstatus,					   
				       cEstatusDesc,
					   sIdCampania,
					   sIdJerarquia,
					   sActiva,					   
					   cActivaDesc,					   
					   cMensajeVar,
					   cSistema,
					   sCombinable,
					   cMensajeVal,
					   sAct_Zona,   --28/06/2012
					   sSucursal;	--28/06/2012	 			   
			END IF;
		END EXCEPTION;	
		
		IF iTipoBusqueda IS NOT NULL OR cId <> "" THEN
		
			IF iTipoBusqueda = 0 THEN
			
				FOREACH

				-- Se obtienen los datos de las campañas
					SELECT num_producto, 
						   sistema, 
						   estatus, 
						   DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS'),
						   idcamp, 
						   idJerarquia, 
						   idZona,
						   activa, 
						   DECODE(activa,'1','SI','0','NO'), 
						   combinable,
						   idmensaje,
						   tran_nro,
						   act_zona,  --28/06/2012 						   
						   sucursal   --28/06/2012 
					  INTO cNumProducto, 
						   cSistema, 
						   cEstatus, 
						   cEstatusDesc, 
						   sIdCampania, 
						   sIdJerarquia,
						   sIdZona,
						   sActiva, 
						   cActivaDesc,				   
						   sCombinable,
						   sIdMensaje,
						   sTransaccion,
						   sAct_Zona,	--28/06/2012	
                           sSucursal	--28/06/2012					   
					  FROM bdinteg:"informix".si_maecamp
					 WHERE (empresa='001' and sucursal = cId)
						OR (empresa='001' and sucursal = "T")  --28/06/2012 
					 
					IF cNumProducto IS NULL OR cSistema IS NULL OR cEstatus IS NULL OR sIdCampania IS NULL OR sIdJerarquia IS NULL OR sActiva IS NULL THEN
						-- No se encontraron datos de las campañas.
						LET cCodRet = '00005';	
					
						RETURN cCodRet,
							   sTransaccion,
							   cDescTransac,
							   cNumProd,					   
							   cProducto,
							   cEstatus,					   
							   cEstatusDesc,
							   sIdCampania,
							   sIdJerarquia,
							   sActiva,					   
							   cActivaDesc,
							   cMensajeVar,
							   cSistema,
							   sCombinable,
							   cMensajeVal,
							   sAct_Zona,  --28/06/2012	
 							   sSucursal   --28/06/2012	
						  WITH RESUME;		
						 
					END IF;	
							
					LET cMensajeVar = "";
					LET sOrden = 0;
					
					FOREACH
						
						SELECT mensaje, 
							   orden
						  INTO cMensajeVar, 
							   sOrden
						  FROM bdinteg:"informix".si_detcamp
						 WHERE empresa='001' and idmensaje = sIdMensaje
						 ORDER BY orden
						   
						EXECUTE PROCEDURE bdinteg:"informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) 
									 INTO cCodRet2, cMensajeVal;
									 
						IF cNumProducto = 'T' THEN
						
							LET cNumProd = 'T';
							LET cProducto = 'TODOS';
						
						ELSE									 
						
							IF cSistema = 'SC' THEN
							 
							-- Se obtiene la descripción del producto en Captación
								SELECT producto, 
									   nombre 
								  INTO cNumProd,
									   cProducto
								  FROM bdicheq:"informix".sc_producto
								 WHERE producto = cNumProducto;	
							 
							ELIF cSistema = 'SD' THEN
							 
							-- Se obtiene la descripción del producto en Crédito
								SELECT num_producto, 
									   nombre_prod
								  INTO cNumProd, 
									   cProducto
								  FROM bdicred:"informix".sd_definicion
								 WHERE num_producto = cNumProducto;								 
							 
							END IF;
							
						END IF;							
						
						IF sTransaccion IS NULL OR sOrden IS NULL OR sOrden = 0 THEN
							-- No se encontraron datos de la tabla detalle de las campañas.
							LET cCodRet = '00002';
						END IF;
					
						IF sTransaccion = 0 THEN
							LET cDescTransac = "TODAS LAS TRANSACCIONES";
						ELSE
							-- Se obtiene la descripción de la transacción
							SELECT descripcion
							  INTO cDescTransac
							  FROM bdinteg:"informix".itran
							 WHERE empresa = '001'
							   AND numero = sTransaccion;

							IF cDescTransac IS NULL OR cDescTransac = "" THEN
							-- No se encontró la descripción de la transacción.
								LET cCodRet = '00004';
							END IF;	
						END IF;		

						RETURN cCodRet,
							   sTransaccion,
							   cDescTransac,
							   cNumProd,					   
							   cProducto,
							   cEstatus,					   
							   cEstatusDesc,
							   sIdCampania,
							   sIdJerarquia,
							   sActiva,					   
							   cActivaDesc,
							   cMensajeVar,
							   cSistema,
							   sCombinable,
							   cMensajeVal,
							   sAct_Zona,  --28/06/2012	
							   sSucursal   --28/06/2012	
						  WITH RESUME;		
						
					END FOREACH;	
						
				END FOREACH;
				
				-- 28/06/2012 
				-- Se consulta si la sucursal pertenece a una zona con campaña activa
				SELECT plaza
				  INTO cPlaza
				  FROM bdinteg:"informix".si_sucursales
				 WHERE sucursal = cId;			
			
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_maecamp WHERE idzona = cPlaza) THEN
				
					FOREACH				

							SELECT num_producto, 
								   sistema, 
								   estatus, 
								   DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS'),
								   idcamp, 
								   idJerarquia, 
								   idZona,
								   activa, 
								   DECODE(activa,'1','SI','0','NO'), 
								   combinable,
								   idmensaje,
								   tran_nro,
								   act_zona,
								   sucursal
							  INTO cNumProducto, 
								   cSistema, 
								   cEstatus, 
								   cEstatusDesc, 
								   sIdCampania, 
								   sIdJerarquia,
								   sIdZona,
								   sActiva, 
								   cActivaDesc,				   
								   sCombinable,
								   sIdMensaje,
								   sTransaccion,
								   sAct_Zona,
								   sSucursal
							   FROM bdinteg:"informix".si_maecamp
							  WHERE idzona = cPlaza

						IF cNumProducto <> "" OR cSistema <> "" OR cEstatus <> "" OR sIdCampania <> "" OR sIdJerarquia <> "" OR sActiva <> "" THEN
						
							LET cMensajeVar = "";
							LET sOrden = 0;
							
							FOREACH
								
								SELECT mensaje, 
									   orden
								  INTO cMensajeVar, 
									   sOrden
								  FROM bdinteg:"informix".si_detcamp
								 WHERE empresa='001' and idmensaje = sIdMensaje
								 ORDER BY orden
								   
								EXECUTE PROCEDURE bdinteg:"informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) 
											 INTO cCodRet2, cMensajeVal;
											 
								IF cNumProducto = 'T' THEN
								
									LET cNumProd = 'T';
									LET cProducto = 'TODOS';
								
								ELSE									 
								
									IF cSistema = 'SC' THEN
									 
									-- Se obtiene la descripción del producto en Captación
										SELECT producto, 
											   nombre 
										  INTO cNumProd,
											   cProducto
										  FROM bdicheq:"informix".sc_producto
										 WHERE producto = cNumProducto;	
									 
									ELIF cSistema = 'SD' THEN
									 
									-- Se obtiene la descripción del producto en Crédito
										SELECT num_producto, 
											   nombre_prod
										  INTO cNumProd, 
											   cProducto
										  FROM bdicred:"informix".sd_definicion
										 WHERE num_producto = cNumProducto;								 
									 
									END IF;
									
								END IF;							
								
								IF sTransaccion IS NULL OR sOrden IS NULL OR sOrden = 0 THEN
									-- No se encontraron datos de la tabla detalle de las campañas.
									LET cCodRet = '00002';
								END IF;
							
								IF sTransaccion = 0 THEN
									LET cDescTransac = "TODAS LAS TRANSACCIONES";
								ELSE
									-- Se obtiene la descripción de la transacción
									SELECT descripcion
									  INTO cDescTransac
									  FROM bdinteg:"informix".itran
									 WHERE empresa = '001'
									   AND numero = sTransaccion;

									IF cDescTransac IS NULL OR cDescTransac = "" THEN
									-- No se encontró la descripción de la transacción.
										LET cCodRet = '00004';
									END IF;	
								END IF;								
						
								RETURN cCodRet,
									   sTransaccion,
									   cDescTransac,
									   cNumProd,					   
									   cProducto,
									   cEstatus,					   
									   cEstatusDesc,
									   sIdCampania,
									   sIdJerarquia,
									   sActiva,					   
									   cActivaDesc,
									   cMensajeVar,
									   cSistema,
									   sCombinable,
									   cMensajeVal,
									   sAct_Zona,  --28/06/2012									   
									   sSucursal   --28/06/2012
								  WITH RESUME;	
								  
							END FOREACH;								  
							 
						END IF;									

					END FOREACH;

				END IF;
				--
			
			ELSE
			
				FOREACH

				-- Se obtienen los datos de las campañas
					SELECT num_producto,
						   sistema,
						   estatus,
						   DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS'),
						   idcamp,
						   idJerarquia,
						   activa,				   
						   DECODE(activa,'1','SI','0','NO'),
						   combinable,
						   idmensaje,
						   tran_nro,
						   act_zona,  --28/06/2012
						   sucursal   --28/06/2012
					  INTO cNumProducto,
						   cSistema,
						   cEstatus,
						   cEstatusDesc,
						   sIdCampania,
						   sIdJerarquia,
						   sActiva,
						   cActivaDesc,
						   sCombinable,
						   sIdMensaje,
						   sTransaccion,
						   sAct_zona,  --28/06/2012
						   sSucursal   --28/06/2012
					  FROM bdinteg:"informix".si_maecamp
					 WHERE IdZona = cId	
					 
					IF cNumProducto IS NULL OR cSistema IS NULL OR cEstatus IS NULL OR sIdCampania IS NULL OR sIdJerarquia IS NULL OR sActiva IS NULL THEN
						-- No se encontraron datos de las campañas.
						LET cCodRet = '00005';	
					
						RETURN cCodRet,
							   sTransaccion,
							   cDescTransac,
							   cNumProd,					   
							   cProducto,
							   cEstatus,					   
							   cEstatusDesc,
							   sIdCampania,
							   sIdJerarquia,
							   sActiva,					   
							   cActivaDesc,
							   cMensajeVar,
							   cSistema,
							   sCombinable,
							   cMensajeVal,
							   sAct_Zona,  --28/06/2012
							   sSucursal   --28/06/2012
						  WITH RESUME;		
						 
					END IF;						 

					LET cMensajeVar = "";
					LET sOrden = 0;
					
					FOREACH
						
						SELECT mensaje, 
							   orden
						  INTO cMensajeVar, 
							   sOrden
						  FROM bdinteg:"informix".si_detcamp
						 WHERE empresa='001' and idmensaje = sIdMensaje
						   
						EXECUTE PROCEDURE bdinteg:"informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) 
									 INTO cCodRet2, cMensajeVal;					   

						IF cNumProducto = 'T' THEN
						
							LET cNumProd = 'T';						
							LET cProducto = 'TODOS';
						
						ELSE
						
							IF cSistema = 'SC' THEN
							 
							-- Se obtiene la descripción del producto en Captación
								SELECT producto,
									   nombre
								  INTO cNumProd,
									   cProducto
								  FROM bdicheq:"informix".sc_producto
								 WHERE producto = cNumProducto;	
							 
							ELIF cSistema = 'SD' THEN
							 
							-- Se obtiene la descripción del producto en Crédito
								SELECT num_producto,
									   nombre_prod
								  INTO cNumProd,
									   cProducto
								  FROM bdicred:"informix".sd_definicion
								 WHERE num_producto = cNumProducto;			
							 
							END IF;
							
						END IF;		

						IF sTransaccion IS NULL OR sOrden IS NULL OR sOrden = 0 THEN
							-- No se encontraron datos de la tabla detalle de las campañas.
							LET cCodRet = '00002';
						END IF;
						
						IF sTransaccion = 0 THEN
							LET cDescTransac = "TODAS LAS TRANSACCIONES";
						ELSE
							-- Se obtiene la descripción de la transacción
							SELECT descripcion
							  INTO cDescTransac
							  FROM bdinteg:"informix".itran
							 WHERE empresa = '001'
							   AND numero = sTransaccion;

							IF cDescTransac IS NULL OR cDescTransac = "" THEN
							-- No se encontró la descripción de la transacción.
								LET cCodRet = '00004';
							END IF;	
						END IF;								
					
						RETURN cCodRet,
							   sTransaccion,
							   cDescTransac,
							   cNumProd,					   
							   cProducto,
							   cEstatus,					   
							   cEstatusDesc,
							   sIdCampania,
							   sIdJerarquia,
							   sActiva,					   
							   cActivaDesc,
							   cMensajeVar,
							   cSistema,
							   sCombinable,
							   cMensajeVal,
							   sAct_Zona,   --28/06/2012
						       sSucursal    --28/06/2012							   
						  WITH RESUME;	
					  
					END FOREACH;				  
						
				END FOREACH;				 
			
			END IF;

		ELSE 
		
			-- Parámetros de entrada vacíos
			LET cCodRet = '00001';

		END IF;				
		
	END
END PROCEDURE;