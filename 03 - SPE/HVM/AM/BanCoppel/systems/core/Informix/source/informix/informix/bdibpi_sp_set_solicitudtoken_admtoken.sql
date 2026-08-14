CREATE PROCEDURE "informix".sp_set_solicitudtoken_admtoken(pNumSolicitud CHAR(10), pNumCliente CHAR(9), pNumToken CHAR(9), pStatus CHAR(3))
   returning CHAR(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Realiza la asignación del token a la solicitud del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 15/01/2010
--------------------------------------------------------------------------------------------
-- Modifico: Nubia Janeth Montoya Medina
-- Actividad: Realizar la actualización de la tabla si_bpitoken 
-- Fecha de solicitud: 12/03/2010
--------------------------------------------------------------------------------------------
-- Modificó: Josè de Jesùs Nevarez
-- Actividad: Realizar la actualización en la tabla si_bpitokenpm
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 29-09-2011
---------------------------------------------------------------------------------------------
-- Modificó: Ing. Alfonso Cruz
-- Actividad: Se cubre el flujo para la reversión de estatus en caso de ocurrir un error en  
-- el proceso de activacion individual de token.
-- Solicitó: José de Jesús Nevarez
-- Fecha de Solicitud: 06-09-2012
---------------------------------------------------------------------------------------------

-- Modificó: Juan Daniel Lazalde Centeno
-- Actividad: Se quita la actualización en si_bpitoken cuando es tipo de solictitud por renovación en personas físicas
-- Solicitó: José de Jesús Nevarez
-- Fecha de Solicitud: 20-11-2013

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err 		INTEGER;
    DEFINE cod_ret 		CHAR(5);
	DEFINE vTpoPersona 	CHAR (2);
	DEFINE vTpoSol 	SMALLINT;
    
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
	LET vTpoPersona = '';
	LET vTpoSol = '';
    

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
    
	--SET DEBUG FILE TO "/home/sp_set_solicitudtoken_admtoken.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	
	SELECT tpo_persona INTO vTpoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCliente;
	SELECT tipo INTO vTpoSol from bdibpi:'informix'.bpi_tokensolicitud where numcte = pNumCliente and solicitud = pNumSolicitud;

	IF((pStatus=="100" OR pStatus=="200")  AND pNumToken=="")THEN
		--ACTIVACION INDIVIDUAL DE TOKEN REVERSANDO ESTATUS CUANDO EL CLIENTE YA TIENE TOKEN ASIGNADO EN EL AM
		UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status=pStatus, ns_token = pNumToken WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;

			IF (vTpoPersona == '01') THEN	
				IF (vTpoSol!=6 AND vTpoSol!=7) THEN
					UPDATE bdinteg:"informix".si_bpitoken SET ns_token = pNumToken,id_status_token = pStatus WHERE num_cliente = pNumCliente;
				END IF;
			ELIF (vTpoPersona == '02') THEN				
				UPDATE bdinteg:"informix".si_bpitokenpm SET ns_token = pNumToken,id_status_token = pStatus WHERE num_cliente = pNumCliente;
			ELSE
				 LET cod_ret = '002';
			END IF;
	ELSE
		--FLUJO NORMAL DEL PROCEDIMIENTO
		IF EXISTS(SELECT numcte from bdibpi:"informix".bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente) THEN
				UPDATE bdibpi:"informix".bpi_tokensolicitud SET ns_token = pNumToken WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;
			
			IF EXISTS (SELECT ns_token FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente and ns_token = pNumToken) THEN 
			
				IF (vTpoPersona == '01') THEN	
					IF (vTpoSol!=6 AND vTpoSol!=7) THEN
						UPDATE bdinteg:"informix".si_bpitoken SET ns_token = pNumToken, id_status_token = pStatus WHERE num_cliente = pNumCliente;
					END IF;
				ELIF (vTpoPersona == '02') THEN				
					UPDATE bdinteg:"informix".si_bpitokenpm SET ns_token = pNumToken, id_status_token = pStatus WHERE num_cliente = pNumCliente;
				ELSE
					 LET cod_ret = '002';
				END IF;
			END IF;
		ELSE
			LET cod_ret = '001';
		END IF;
	END IF;
    
    
    RETURN cod_ret;
   
END
END PROCEDURE ;