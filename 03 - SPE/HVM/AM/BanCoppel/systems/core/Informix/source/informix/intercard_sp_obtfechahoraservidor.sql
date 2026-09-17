CREATE PROCEDURE "informix".sp_obtfechahoraservidor(psRuta_Procesos VARCHAR (90))

RETURNING INTEGER AS Respuesta,  DATETIME YEAR TO FRACTION (5) AS FechaServidor ;

--****************************************************************************************************
-- DESCRIPCION:  obtienen la fecha real del servidor -- fecha real del serv .
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 17/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : --Casanova Edeza Hector Juan 20/02/2012 SE AGREGAN CONTROLES PARA MANEJAR TRANSACCIONES PENDIENTES DE OTROS PROCESOS.
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vdtFechaHoraActual DATETIME YEAR TO FRACTION (5);
DEFINE visqlerr INTEGER ;
DEFINE vsEnTransaccion CHAR(1);

DEFINE viAux INTEGER;


/* INICIALIZACION DE VARIABLES */
LET vdtFechaHoraActual = '1900-01-01 00:00:00' ;
LET visqlerr = 0;
LET vsEnTransaccion = 'F';

LET viAux = 0;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
		
		RETURN visqlerr, vdtFechaHoraActual ;
		
	END EXCEPTION;
	
	--EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA	
	ON EXCEPTION IN (-535)
		EXECUTE PROCEDURE Intercard:"informix".sp_Insertar_Bitacora ( '00000', '000',  'sp_obtfechahoraservidor', 'TRANSACCION ABIERTA EN OTRO PROCESO CONTROLADA. (' || TRIM(psRuta_Procesos) || ')' ) INTO viAux; 
		LET vsEnTransaccion = 'V'; --TERMINA LA TRANSACCION ACTUAL Y CONTINUA
	END EXCEPTION WITH RESUME;

    
	IF (vsEnTransaccion = 'V') THEN
		COMMIT WORK;
        BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--OBTIENE FECHA SERVIDOR
	SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) INTO vdtFechaHoraActual FROM SysMaster:"informix".Sysshmvals ;	
	
	COMMIT WORK;
	
	RETURN visqlerr, vdtFechaHoraActual ;
	
END

END PROCEDURE;