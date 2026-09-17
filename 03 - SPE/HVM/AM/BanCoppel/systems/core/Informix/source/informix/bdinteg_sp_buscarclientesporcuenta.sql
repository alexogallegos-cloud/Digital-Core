CREATE PROCEDURE "informix".sp_buscarclientesporcuenta (p_sNumeroCuenta CHAR(30), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE estatus_cta					CHAR(1);
	DEFINE iSqlErr                      	INTEGER;

     -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET estatus_cta = '';
	LET resultado_segundoNombre = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
            END EXCEPTION;

		/*	
		SELECT  status_cta
		INTO estatus_cta
		FROM bdicheq:sc_maechq
		WHERE cuenta = p_sNumeroCuenta;
		
		IF (estatus_cta='2') THEN 
			LET p_sNumeroCuenta = '';
		END IF;
		*/	
			
        FOREACH
            SELECT num_cte
            INTO resultado_numeroCliente
            FROM bdicheq:sc_maechq
            WHERE cuenta = p_sNumeroCuenta
            UNION
            SELECT num_cte
            FROM bdinvers:sv_maeinv
            WHERE empresa = p_sNumeroEmpresa
              AND cuenta = p_sNumeroCuenta
            UNION
            SELECT numcte
            FROM bdicred:sd_maecred
            WHERE empresa = p_sNumeroEmpresa
              AND num_credito = p_sNumeroCuenta
            UNION
            SELECT numcliente 		--JALM
            FROM intercard:tarjeta
			LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numcuenta = p_sNumeroCuenta
			UNION
            SELECT numcte
            FROM bditransfer:tf_maecte
            WHERE empresa = p_sNumeroEmpresa
              AND cuenta_tf = p_sNumeroCuenta
        END FOREACH;

        if ( resultado_numeroCliente IS null ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT si_cliente.numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente;

            if ( resultado_numeroCliente IS null ) THEN
               let resultado_numeroCliente = '';
            END if;
        END if;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT 'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de clientes correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_buscarclientesportarjeta (p_sNumeroTarjeta CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--	    
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE cuenta_tarjeta				CHAR(30);
	DEFINE iSqlErr                     	INTEGER;
	
    -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET cuenta_tarjeta = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;
         
   
		SELECT numcuenta
		INTO cuenta_tarjeta
		FROM intercard:tarjetacuenta
		WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta;
            
        IF (cuenta_tarjeta IS NULL)THEN
        
        SELECT cuenta_tf
		INTO cuenta_tarjeta
		FROM bditransfer:tf_maecte
		WHERE empresa = '001'
		AND bditransfer:tf_maecte.num_tarjeta = p_sNumeroTarjeta;
         
        END IF;

        FOREACH
            SELECT num_cte
            INTO resultado_numeroCliente
            FROM bdicheq:sc_maechq
            WHERE empresa = '001'
              AND cuenta = cuenta_tarjeta
            UNION
             SELECT numcte
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
            AND cuenta_tf = cuenta_tarjeta
            UNION
            SELECT num_cte
            FROM bdinvers:sv_maeinv
            WHERE empresa = '001'
              AND cuenta = cuenta_tarjeta
            UNION
            SELECT numcliente 		--JALM
            FROM intercard:tarjeta
			LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numcuenta = cuenta_tarjeta
			UNION
            SELECT numcte
            FROM bdicred:sd_maecred
            WHERE empresa = '001'
              AND num_credito = cuenta_tarjeta
			  AND status_cred IN ('AA','BA','BT','E1','E2','E3') -- Agregado
			--IFRS Se contemplan los nuevos estatus por Etapas			
			--AND status_cred IN ('AA','BA','BT')			  
           
        END FOREACH;
		
           
     IF ( resultado_numeroCliente IS NULL ) THEN
            let resultado_numeroCliente = '';
        ELSE
            SELECT si_cliente.numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente;
{
            IF ( resultado_numeroCliente IS NULL ) THEN
               
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				
            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT 'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de clientes correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Noviembre/2022',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_regresaticket()

--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(50)	AS ticket;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_regresaticket "
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 27/01/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021

folio:Cambio
Autor.........: Juan Francisco Ponce Damian
Fecha.........: 26/10/2021
Modificacion..: Se limita a 1000 la cantidad maxima de tickets por ejecuciÃ³n y se ordenan de mas antiguas a mas nuevos.
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iContador		INTEGER;
DEFINE cTicket			CHAR(50);
DEFINE cMinutos			INTEGER;
DEFINE dFecha			DATETIME YEAR TO SECOND;

-- SET DEBUG FILE TO '/home/sysifx/sp_regresaticket.out';
-- TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00001';
LET iSqlErr				= 0;
LET iContador			= 0;
LET cTicket				= '';
LET cMinutos			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTicket;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT TO_NUMBER(valor) INTO cMinutos FROM "informix".si_param WHERE cod_param = '502' AND empresa = '001';
	LET dFecha = (CURRENT - cMinutos UNITS MINUTE);
	
	FOREACH
	    SELECT limit 1000 ticket INTO cTicket 
		FROM "informix".si_rostro_linea 
		WHERE status_consulta = '2'
		AND ticket != ''
		AND fecha_env <= dFecha ORDER BY fecha_env ASC

		LET cCodRet = '00000';
		
		LET iContador = iContador + 1;
		
		RETURN cCodRet, cTicket WITH RESUME;
		
	END FOREACH;
		
	IF (iContador <= 0) THEN
		RETURN cCodRet, cTicket WITH RESUME;
	END IF;
END;
END PROCEDURE;