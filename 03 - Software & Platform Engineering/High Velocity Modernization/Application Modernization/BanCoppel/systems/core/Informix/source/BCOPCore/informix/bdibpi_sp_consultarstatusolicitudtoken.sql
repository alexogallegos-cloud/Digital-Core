CREATE PROCEDURE  "informix".sp_consultarstatusolicitudtoken(pEmpresa CHAR(3), pNumCte CHAR(20))

--DATOS A REGRESAR---
RETURNING
CHAR(5), -- Codigo de Retorno
CHAR(3), --status de la solicitud de token
CHAR(40); -- Descripcion estatus

--DEFINICION DE VARIABLES--
DEFINE sql_err INT;
DEFINE vCodRet CHAR(5);
DEFINE vStatusSol CHAR(3);
DEFINE vDescEstatus CHAR(40);
DEFINE vSolicitud CHAR(10);

--INICIALIZACION DE VARIABLES--
LET sql_err = 0;
LET vCodRet = '00000';
LET vStatusSol = '';
LET vDescEstatus = '';
LET vSolicitud = '';

--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consultarstatusolicitudtoken.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, vStatusSol, vDescEstatus;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF (SELECT COUNT(solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = pNumCte) > 0 THEN
	
		SELECT MAX (solicitud)
		INTO vSolicitud  
		FROM bdibpi:"informix".bpi_tokensolicitud 
		WHERE numcte = pNumCte;
		
		SELECT id_status 
		INTO vStatusSol 
		FROM bdibpi:"informix".bpi_tokensolicitud 
		WHERE numcte = pNumCte AND solicitud = vSolicitud;
		
		SELECT desc_status 
		INTO vDescEstatus 
		FROM bdinteg:"informix".si_bpistatus 
		WHERE id_status = vStatusSol;
		  
	END IF;
	
	RETURN vCodRet, vStatusSol, vDescEstatus;
END

END PROCEDURE  

DOCUMENT
"Autor : Daniela Ramirez",
"FECHA : 14/04/2011",
"Descripcion: Consulta el status de la solicitud del token",
"BD    : bdibpi", 
"Modifico : Daniela Ramirez",
"FECHA : 02/08/2011",
"Descripcion: Se agrega busqueda de la descripcion del status",
"BD    : bdibpi";

CREATE PROCEDURE "informix".sp_agregarsolaprocesar(pSolicitud varchar(10),
					pNumcte	varchar(9),
					pIdstatus varchar(5),
					pTipo varchar(5),
					pSucursal varchar(4),
					pF_solicitud varchar(50),
					pUsr_solicita varchar(8),
					pSec_domicilio smallint,
					pComentarios varchar(200),
					pNombre1 varchar(26),
					pNombre2 varchar(26),
					pApell_paterno	varchar	(26),
					pApell_materno	varchar	(26),
					pId integer,
					pEnUso integer)
RETURNING CHAR(5);
--------------------------------------------------------------------------------------------
-- Realizó: Francisco Rodríguez Ibarra
-- Actividad: Inserta registro de solicitud que se procesara
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 14/01/2011
---------------------------------------------------------------------------------------------
-- Realizó: josé de Jesús Nevarez
-- Actividad: Inserta nombre de destinatario para solicitudes de personas morales.
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 29/08/2011	
	
--Definición de variables
DEFINE sql_err      INT;
DEFINE vCodRet      CHAR(5);
DEFINE vDestinatario CHAR (30);

--Inicializar valores a variables declaradas
LET vCodRet = '00000';
LET vDestinatario = '';

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
	            let vCodRet = sql_err;
	            RETURN vCodRet;                       
		END IF ;
	END EXCEPTION ;
	
	
   -- SET DEBUG FILE TO "/tmp/manuel/log_agregarsolcitudes.out";
   -- TRACE ON;
	
	
	IF (pEnUso=0) THEN
		DELETE FROM tkn_tmpsolproceso;
	END IF;
	
	IF (pTipo::VARCHAR(1) == '3') THEN
		SELECT usuario_aut INTO vDestinatario FROM bdinteg:"informix".si_bpiusuariospm WHERE num_cliente = pNumcte;
	END IF;
	
	
	INSERT INTO bdibpi:"informix".tkn_tmpsolproceso(solicitud,
					numcte,
					id_status,
					tipo,sucursal,
					f_solicitud,
					usr_solicita,
					sec_domicilio,
					comentarios,
					nombre1,
					nombre2,
					apell_paterno,
					apell_materno,
					destinatario,
					id)
				VALUES (pSolicitud,
					pNumcte,
					pIdstatus,
					pTipo,
					pSucursal,
					pF_solicitud,
					pUsr_solicita,
					pSec_domicilio,
					pComentarios,
					pNombre1,
					pNombre2,
					pApell_paterno,
					pApell_materno,
					vDestinatario,
					pId);
	RETURN vCodRet;
END;
END PROCEDURE;