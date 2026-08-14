CREATE PROCEDURE "informix".sp_mf_estadistica(p_dtfecha date)
RETURNING INTEGER , INTEGER , INTEGER ,  INTEGER , INTEGER ,DECIMAL(18,2),DECIMAL(18,2);      

-- Definicion de variables de retorno

DEFINE v_iTransTotales INTEGER;
DEFINE v_iTransAceptadas INTEGER;
DEFINE v_iTransRechazadas INTEGER;
DEFINE v_iReversos INTEGER;
DEFINE v_iForzados INTEGER;
DEFINE v_iHoras INTEGER;
DEFINE v_dTransPorHora DECIMAL(18,2);
DEFINE v_dTransPromAce DECIMAL(18,2);

DEFINE dtFecha_Ini DATETIME YEAR TO FRACTION (5);
DEFINE dtFecha_Fin DATETIME YEAR TO FRACTION (5);

--****************************************************
 -- Creado por Manuel Osuna    28/Agosto/2008       --*
 -- Modificado Por: Casanova Edeza Hector Juan					--*
 -- Fecha: 6 octubre 2009   									 	--*
 -- Modificacion: Se modifico la estructura del Where de las consultas en el campo fecha para que se utilice el indice de la tabla correctamente	--*
 -- Debug del Procedure                            --*
 --SET DEBUG FILE TO "/tmp/estadistica.out"; --*
 --TRACE ON;                                      --*
--****************************************************

BEGIN
-- Inicializacion de variables
    LET v_iTransTotales = 0;
    LET v_iTransAceptadas = 0;
    LET v_iTransRechazadas = 0;    
    LET v_iReversos = 0;
    LET v_iForzados = 0;  
	LET v_dTransPorHora = 0;
	LET v_dTransPromAce = 0;
	LET  v_iHoras = 0;
	LET dtFecha_Ini = CURRENT;
	LET dtFecha_Fin = CURRENT;
	
	LET dtFecha_Ini = YEAR (p_dtfecha) || '-' || MONTH(p_dtfecha) || '-' || DAY (p_dtfecha) || ' 00:00:00';
	LET dtFecha_Fin = YEAR (p_dtfecha) || '-' || MONTH(p_dtfecha) || '-' || DAY (p_dtfecha) || ' 23:59:59';
		
	SET LOCK MODE TO WAIT;
	SET ISOLATION TO DIRTY READ;
	
-- Calculo de transacciones totales       
	  SELECT COUNT (Secuencia) INTO v_iTransTotales FROM movimiento WHERE fechahorainauth BETWEEN dtFecha_Ini AND dtFecha_Fin;	          

-- Calculo de transacciones aceptadas para fecha actual
       SELECT COUNT (Secuencia) INTO v_iTransAceptadas  FROM movimiento WHERE fechahorainauth  BETWEEN dtFecha_Ini AND dtFecha_Fin AND  codigoiso = '00';
      
-- Calculo de transacciones rechazadas para fecha actual
       SELECT COUNT (Secuencia) INTO v_iTransRechazadas  FROM movimiento WHERE  fechahorainauth  BETWEEN dtFecha_Ini AND dtFecha_Fin  AND  ( codigoiso <> '00' OR codigoiso is Null);      
		
-- Calculo de reversos para fecha actual
       SELECT COUNT (Secuencia) INTO v_iReversos  FROM movimiento WHERE fechahorainauth  BETWEEN dtFecha_Ini AND dtFecha_Fin  AND  ( formato = '0420' OR formato = '0421' );
      
-- Calculo de forzados para fecha actual
       SELECT COUNT (Secuencia) INTO v_iForzados FROM movimiento WHERE fechahorainauth  BETWEEN dtFecha_Ini AND dtFecha_Fin  AND  ( formato = '0220' OR formato = '0221' );
	
--Calculo de promedio de Transacciones por hora			
	   IF v_iForzados > 0 THEN
			SELECT max(fechahorainauth::datetime hour to hour ::char(2)::int) INTO v_iHoras FROM movimiento WHERE fechahorainauth BETWEEN dtFecha_Ini AND dtFecha_Fin;
			LET v_dTransPorHora = v_iTransTotales / v_iHoras;
	   END IF;
	   
--Calculo de Porcenteaje  de Transacciones Aprovadas
	   if (v_iTransTotales > 0) then			
			LET v_dTransPromAce = (v_iTransAceptadas / v_iTransTotales) * 100 ;
	   end if;	   

        RETURN v_iTransTotales, v_iTransAceptadas, v_iTransRechazadas, v_iReversos, v_iForzados,v_dTransPorHora,v_dTransPromAce;

-- Fin del procedimiento
END;
END PROCEDURE;