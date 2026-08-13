CREATE PROCEDURE "informix".sp_mf_numoperaciones(p_iQuery INTEGER,p_dfecha DATE,p_inumoperaciones INTEGER,p_indice INTEGER)
RETURNING INTEGER AS NumTrans,VARCHAR(16) AS NumTarjeta,VARCHAR(13) AS NumCuenta;

-- Definicion de variables de retorno

DEFINE v_iNumTrans INTEGER;
DEFINE v_sNumTarjeta VARCHAR(16);
DEFINE v_sNumCuenta VARCHAR(13);
DEFINE v_sTerminal VARCHAR(50);
DEFINE v_iNumRen INTEGER;

DEFINE dtFecha_Ini DATETIME YEAR TO FRACTION (5);
DEFINE dtFecha_Fin DATETIME YEAR TO FRACTION (5);

--*********************************************************************
 -- Creado por Manuel Osuna   01/Septiembre/2009                	--*
 -- Debug del Procedure                                         	--*
 -- SET DEBUG FILE TO "/tmp/spmf_NumOperacionesRechazadas.out"; 	--*
 -- TRACE ON;   													--*
 -- Modificado Por: Jose de Jesus Nevarez Peinado					--*
 -- Fecha: 2 septiembre 2009   									 	--*
 -- Modificacion: Se agrego una nueva consuta Por reintentos de NIP	--*
 -- Modificado Por: Casanova Edeza Hector Juan					--*
 -- Fecha: 6 octubre 2009   									 	--*
 -- Modificacion: Se modifico la estructura del Where de las consultas en el campo fecha para que se utilice el indice de la tabla correctamente	--*
--*********************************************************************

-- Inicio del procedimiento
BEGIN

-- Consulta registros para fecha actual

		LET v_iNumTrans = 0;
		LET v_sNumTarjeta ="";
		LET v_sNumCuenta ="";
		LET v_iNumRen =0;
		
		LET dtFecha_Ini = CURRENT;
		LET dtFecha_Fin = CURRENT;


        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

		LET dtFecha_Ini = YEAR (p_dfecha) || '-' || MONTH(p_dfecha) || '-' || DAY (p_dfecha) || ' 00:00:00';
		LET dtFecha_Fin = YEAR (p_dfecha) || '-' || MONTH(p_dfecha) || '-' || DAY (p_dfecha) || ' 23:59:59';
		
		--Registros a Mostrar
		SELECT valor INTO  v_iNumRen FROM param_fraudes;
		
		if (p_iQuery == 1) then --Por Numero de Operaciones Rechazadas

		    FOREACH
				SELECT   SKIP p_indice  FIRST v_iNumRen  b.numtarjeta,  a.numcuenta,count (b.numtarjeta)
				INTO  v_sNumTarjeta,v_sNumCuenta, v_iNumTrans
				FROM MOVIMIENTO AS b INNER JOIN TARJETACUENTA AS a  ON b.NUMTARJETA = a.NUMTARJETA
				--WHERE date(b.FECHAHORAINAUTH) = p_dfecha
				WHERE b.FECHAHORAINAUTH BETWEEN dtFecha_Ini AND dtFecha_Fin
				AND ( b.CodigoISO <> '00' OR b.CodigoISO is Null)
				group by  b.numtarjeta,  a.numcuenta
				Having Count(b.numtarjeta) >= p_inumoperaciones
		             RETURN NVL(v_iNumTrans,''),NVL(v_sNumTarjeta,''),NVL(v_sNumCuenta,'') WITH RESUME;
		    END FOREACH;

		ELIF (p_iQuery == 2) then --Por Numero de Operaciones en la misma Terminal

			FOREACH
				SELECT   SKIP p_indice  FIRST v_iNumRen   b.IdTerminal, b.numtarjeta,  a.numcuenta, count (b.numtarjeta)
				INTO v_sTerminal,v_sNumTarjeta,v_sNumCuenta, v_iNumTrans
				FROM MOVIMIENTO AS b INNER JOIN TARJETACUENTA AS a  ON b.NUMTARJETA = a.NUMTARJETA
				--WHERE date(b.FECHAHORAINAUTH)  = p_dfecha
				WHERE b.FECHAHORAINAUTH BETWEEN dtFecha_Ini AND dtFecha_Fin
				group by  b.numtarjeta,  a.numcuenta, b.IdTerminal
				Having Count(b.numtarjeta) >= p_inumoperaciones
		             RETURN NVL(v_iNumTrans,''),NVL(v_sNumTarjeta,''),NVL(v_sNumCuenta,'') WITH RESUME;
		    END FOREACH;

		ELIF (p_iQuery == 3) then --Por Numero de Operaciones en el mismo  Dia

			FOREACH
				select  SKIP p_indice  FIRST v_iNumRen  b.numtarjeta,  a.numcuenta,  count (b.numtarjeta)
				INTO v_sNumTarjeta,v_sNumCuenta, v_iNumTrans
				FROM MOVIMIENTO AS b INNER JOIN TARJETACUENTA AS a  ON b.NUMTARJETA = a.NUMTARJETA
				--WHERE date(b.FECHAHORAINAUTH)  = p_dfecha
				WHERE b.FECHAHORAINAUTH BETWEEN dtFecha_Ini AND dtFecha_Fin
				group by  b.numtarjeta,  a.numcuenta
				Having Count(b.numtarjeta) >= p_inumoperaciones
					RETURN NVL(v_iNumTrans,''),NVL(v_sNumTarjeta,''),NVL(v_sNumCuenta,'') WITH RESUME;
		    END FOREACH;
			
		ELIF (p_iQuery == 4) then --Por Reintento de NIP.

			FOREACH
				select  SKIP p_indice  FIRST v_iNumRen  b.numtarjeta,  a.numcuenta,  count (b.numtarjeta)
				INTO v_sNumTarjeta,v_sNumCuenta, v_iNumTrans
				FROM MOVIMIENTO AS b INNER JOIN TARJETACUENTA AS a  ON b.NUMTARJETA = a.NUMTARJETA
				--WHERE date(b.FECHAHORAINAUTH)  = p_dfecha 
				WHERE b.FECHAHORAINAUTH BETWEEN dtFecha_Ini AND dtFecha_Fin
				AND b.CodigoISO='55'
				group by  b.numtarjeta,  a.numcuenta
				Having Count(b.numtarjeta) >= p_inumoperaciones
					RETURN NVL(v_iNumTrans,''),NVL(v_sNumTarjeta,''),NVL(v_sNumCuenta,'') WITH RESUME;
		    END FOREACH;

		END IF;


END;
END PROCEDURE;