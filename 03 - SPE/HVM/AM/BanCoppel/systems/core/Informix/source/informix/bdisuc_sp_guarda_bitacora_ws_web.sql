CREATE PROCEDURE "informix".sp_guarda_bitacora_ws_web(pempresa CHAR(3),
								pSucursal Char(4),
								pCodigo_Motor CHAR(5),
								pDescripcion_Codigo_Motor CHAR(30),
								pCodigo_ws CHAR(3),
								pDescripcion_Codigo_ws  CHAR(200),
								pCadena_ent CHAR(600),
								pNotas CHAR(500),
								pUsuario CHAR(8),
								pFecha_Hora_Insert DATETIME YEAR TO SECOND)
								
RETURNING CHAR(5) as cCodRet;

--Declarar variables
DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vFecha CHAR(20);

-- inicializar variables
LET vcodret = '00000';
LET vsqlerr = 0;
--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_guarda_bitacora_ws_web.out";
--TRACE ON;


BEGIN

	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret;
	   END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF( NVL(pempresa,'') = '' OR NVL(pSucursal,'') = ''  OR NVL(pCodigo_Motor,'') = '' OR NVL(pFecha_Hora_Insert,'') = '' 
	   OR  NVL(pUsuario,'') = '') THEN	
		
		LET vcodret = "00002";
	ELSE
		IF (SELECT COUNT(*) FROM  "informix".ss_bitacora_panamericano_errores WHERE user_insert  = pUsuario AND fecha_hora_insert = pFecha_Hora_Insert) = 0 THEN
				
			INSERT INTO  "informix".ss_bitacora_panamericano_errores (empresa,codigo_motor,descripcion_codigo_motor,codigo_ws,descripcion_codigo_ws,Sucursal,cadena_ent,Notas,user_insert,fecha_hora_insert) 
			VALUES (pempresa,pCodigo_Motor,pDescripcion_Codigo_Motor,pCodigo_ws,pDescripcion_Codigo_ws,pSucursal,pCadena_ent,pNotas,pUsuario,pFecha_Hora_Insert);
		ELSE	
			LET vcodret = "00001";
		END IF;
	END IF;

END; 

RETURN vcodret;
END PROCEDURE
DOCUMENT
'FOLIO: 342',
'AUTOR: OMAR LERMA, OMAR GOMEZ',
'FECHA: 03/01/2018',
'MODIFICACIÃN: SE CREA SP PARA GUARDAR BITACORA DE LA EJECUCION DE WS PANAMERICANO',
'SOLICITA: ABRAHAM NERVAEZ',
'DB:BDISUC';

CREATE PROCEDURE "informix".sp_arqueossuc_atm_web(pempresa CHAR(3), psucursal CHAR(4),
											pcajeroprincipal CHAR(8), 
											pfolio_suc CHAR(16),
                                            ptransacc CHAR(4), pdivisa CHAR(2),
                                            psaldototal money(14,2), 
											pfecha DATE,
											pdeno1 CHAR(18), pdeno2 CHAR(18),
											pdeno3 CHAR(18), pdeno4 CHAR(18),
											pdeno5 CHAR(18), pdeno6 CHAR(18),
											pdeno7 CHAR(18), pdeno8 CHAR(18),
											pdeno9 CHAR(18), pdeno10 CHAR(18),
											pdeno11 CHAR(18), pdeno12 CHAR(18),
											pdeno13 CHAR(18), pdeno14 CHAR(18),
											pdeno15 CHAR(18), pcant1 FLOAT(8),
											pcant2 FLOAT(8), pcant3 FLOAT(8),
											pcant4 FLOAT(8),pcant5 FLOAT(8),
											pcant6 FLOAT(8), pcant7 FLOAT(8),
											pcant8 FLOAT(8), pcant9 FLOAT(8),
											pcant10 FLOAT(8),pcant11 FLOAT(8),
											pcant12 FLOAT(8), pcant13 FLOAT(8),
											pcant14 FLOAT(8), pcant15 FLOAT(8))

RETURNING CHAR(5);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;

LET vcodret = "000";
	BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
	IF vsqlerr != 0 THEN
		LET vcodret=vsqlerr;
		RETURN vcodret;
	END IF;
	END EXCEPTION;
	
	--- Verifica recepcion correcta de datos
	IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or pdivisa = '0' or pdivisa = ''  
		or pcajeroprincipal = '0' or pcajeroprincipal = '' then
		LET vcodret = "110";
	ELSE
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (SELECT COUNT(sucursal) FROM "informix".ss_saldossuc WHERE sucursal = psucursal and fecha = pfecha) > 0 THEN
		
			DELETE FROM "informix".ss_saldossuc WHERE sucursal = psucursal and fecha = pfecha;
			
			INSERT INTO ss_saldossuc (empresa, sucursal, divisa,saldo_total, fecha, cajero_principal, denominacion_1, denominacion_2, denominacion_3, 
			denominacion_4,denominacion_5,denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, 
			denominacion_13, denominacion_14, denominacion_15, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5,cantidad_6,cantidad_7,cantidad_8, 
			cantidad_9,cantidad_10,cantidad_11,cantidad_12, cantidad_13,cantidad_14,cantidad_15)
			VALUES (pempresa, psucursal, pdivisa, psaldototal, pfecha, pcajeroprincipal, pdeno1, pdeno2, pdeno3, pdeno4, pdeno5, pdeno6, pdeno7, pdeno8,
			pdeno9, pdeno10, pdeno11, pdeno12, pdeno13, pdeno14, pdeno15, pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10,
			pcant11, pcant12, pcant13, pcant14, pcant15);
		
		ELSE
		
			INSERT INTO ss_saldossuc (empresa, sucursal, divisa,saldo_total, fecha, cajero_principal, denominacion_1, denominacion_2, denominacion_3, 
			denominacion_4,denominacion_5,denominacion_6, denominacion_7, denominacion_8, denominacion_9, denominacion_10, denominacion_11, denominacion_12, 
			denominacion_13, denominacion_14, denominacion_15, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5,cantidad_6,cantidad_7,cantidad_8, 
			cantidad_9,cantidad_10,cantidad_11,cantidad_12, cantidad_13,cantidad_14,cantidad_15)
			VALUES (pempresa, psucursal, pdivisa, psaldototal, pfecha, pcajeroprincipal, pdeno1, pdeno2, pdeno3, pdeno4, pdeno5, pdeno6, pdeno7, pdeno8,
			pdeno9, pdeno10, pdeno11, pdeno12, pdeno13, pdeno14, pdeno15, pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10,
			pcant11, pcant12, pcant13, pcant14, pcant15);
		
		END IF;
	END IF;       
		
	RETURN vcodret;
	END;
END PROCEDURE;