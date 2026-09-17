CREATE PROCEDURE "informix".sp_operstatusbloqprev ( psNumTarjeta  CHAR (16), psUsuario CHAR (16), psOperacion CHAR (1) )

RETURNING CHAR (2), CHAR (100) ;

--****************************************************************************************************
-- DESCRIPCION: Desarrollo de un Stored Procedure en Informix, para grabar en la Tabla Bitácora Cambios
--		de Estatus de Tarjeta, un registro que indica que se modifico el estatus de la Tarjeta
-- AUTOR : Jorge Quiroz
-- FECHA : 30/08/2010
-- BD: Intercard
-- SISTEMA : InterCard
-- MODIFICADO :
--***************************************************************************************************

--DEFINICION DE VARIABLES Tarjeta
DEFINE viContador INTEGER ;
DEFINE vsQUERY1 CHAR (1000) ;
DEFINE vsStatusTar CHAR (3) ;
DEFINE vsStatusTarNvo CHAR (3) ;
DEFINE vsCodError CHAR (2) ;
DEFINE vsDescError CHAR (100) ;

-- VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr INTEGER ;


--INICIALIZACION DE VARIABLES
LET viContador  = 0 ;
LET vsQUERY1= '' ;
LET vsStatusTar = '' ;
LET vsStatusTarNvo = '' ;
LET vsCodError = '00' ;
LET vsDescError = 'Operacion Exitosa' ;

-- VARIABLE DE MANEJO DE ERRORES
LET visqlerr = 0 ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que no exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN
	    LET vsCodError = '05' ;
	    LET vsDescError = 'ERROR: [' || visqlerr || '], DESCRIPCION: [ Error SPL]' ;
	    RETURN '05', 'ERROR: [' || visqlerr || '], DESCRIPCION: [ Error SPL]' ;
        END IF ;
    END EXCEPTION ;

    SET ISOLATION TO DIRTY READ ;

    SELECT COUNT (NumTarjeta)  INTO viContador FROM Tarjeta
    WHERE  NumTarjeta = psNumTarjeta ;

    IF ( viContador >= 1 ) THEN
        --SE ENCONTRO EL NUMERO DE TARJETA

        SET ISOLATION TO DIRTY READ ;

	SELECT NVL( CodStatusTarjeta , '' ) INTO vsStatusTar FROM Tarjeta WHERE NumTarjeta = psNumTarjeta ;

	IF ( psOperacion = 'D' ) THEN
		--Desbloqueo de Tarjeta
		IF ( vsStatusTar = 'BLT' ) THEN
			LET vsStatusTarNvo = 'ACT' ;
			UPDATE Tarjeta SET CodStatusTarjeta = 'ACT' WHERE NumTarjeta = psNumTarjeta ;
		ELSE
			LET vsCodError = '02' ;
			LET vsDescError = 'Estatus invalido' ;
			--RETURN '02', 'Estatus invalido' ;
		END IF ;
	ELIF ( psOperacion = 'B' ) THEN
		--Bloqueo de Tarjeta
		IF ( vsStatusTar = 'ACT' ) THEN
			LET vsStatusTarNvo = 'BLT' ;
			UPDATE Tarjeta SET CodStatusTarjeta = 'BLT' WHERE NumTarjeta = psNumTarjeta ;
		ELSE
			LET vsCodError = '02' ;
			LET vsDescError = 'Estatus invalido' ;
			--RETURN '02', 'Estatus invalido' ;
		END IF ;
	ELSE
		LET vsCodError = '03' ;
		LET vsDescError = 'Operacion No Valida' ;
		--RETURN '03', 'OPERACION NO VALIDA' ;
	END IF ;
    ELSE
	LET vsCodError = '01' ;
	LET vsDescError = 'Tarjeta No Existe' ;
    END IF ;

	INSERT INTO BitacoraCambiosStatusTarjeta (
			Tarjeta,
			FechaHora,
			CodStatusTarjetaOrig,
			CodStatusTarjetaNvo,
			CambioEstatusInterCard,
			CodigoError,
			DescError,
			Usuario)
	VALUES (psNumTarjeta,CURRENT,vsStatusTar,vsStatusTarNvo,'F',vsCodError,vsDescError,psUsuario) ;


	RETURN vsCodError, vsDescError ;

END
END PROCEDURE
;