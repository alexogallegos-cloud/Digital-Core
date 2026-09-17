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