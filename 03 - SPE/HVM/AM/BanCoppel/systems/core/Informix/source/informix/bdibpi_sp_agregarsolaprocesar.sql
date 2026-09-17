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