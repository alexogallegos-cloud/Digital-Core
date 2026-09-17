CREATE PROCEDURE "informix".sp_set_direccionreenvio(psNumCte CHAR(9), psSolicitud CHAR(10), psDescTipoDir CHAR(20))
RETURNING CHAR(5);

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  ACTUALIZA LA SECUENCIA DEL DOMICILIO EN LA TABLA bpi_tokensolicitud ----------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 01/08/2011  ------------------------------------------------------------------------------
	-- BD: BDIBPPI  -------------------------------------------------------------------------------------
	-- SISTEMA : Mantenimiento al Proceso de Reenvio de Token  ------------------------------------------
	*****************************************************************************************************
	*/
	
    DEFINE vCodret CHAR(5);
	DEFINE sql_err INTEGER;
	DEFINE vsDireccion VARCHAR(52);
	DEFINE viSecDomicilio INTEGER;
	DEFINE vsTipoDir CHAR(1);
    

    LET vCodret = '00000';
	LET sql_err = 0;
	LET vsDireccion = '';
    LET viSecDomicilio = 0;
	LET vsTipoDir = '';

    BEGIN
    
	ON EXCEPTION SET sql_err
        IF (sql_err <> 0) THEN
            LET vCodret = sql_err;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/soporte/TracESP_SET_DIRECCIONREENVIO.sql';
	--TRACE ON;
	
	IF ( TRIM( NVL( psDescTipoDir,'') ) != '' ) THEN
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		SELECT LIMIT 1 tipo_dir 
		INTO vsTipoDir
		FROM bdinteg:"informix".si_cat_tipo_direcciones 
		WHERE UPPER(TRIM(desc_tipo_dir)) = UPPER(TRIM(NVL(psDescTipoDir,'')));
		
		IF ( TRIM(NVL(vsTipoDir,''))!='' ) THEN 

				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				
				SELECT LIMIT 1 {+INDEX(bdinteg:"informix".si_direcciones_actual idx_diract_ctetpo)} nvl(secuencia,0) AS Sec_Domicilio
				INTO viSecDomicilio
				FROM bdinteg:"informix".si_direcciones_actual AS dr
				WHERE tipo_dir = TRIM(NVL(vsTipoDir,'')) and numcte = TRIM(NVL(psNumCte,''));
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				
				update bdibpi:"informix".bpi_tokensolicitud 
				set sec_domicilio = NVL(viSecDomicilio,0)
				where numcte = TRIM(NVL(psNumCte,'')) and solicitud=TRIM(NVL(psSolicitud,''));
		ELSE
			/*ERROR AL OBTENER EL NUMERO DE TIPO DE DOMICILIO*/
			LET vCodret = '00002';
		END IF;
	ELSE
		/*ERROR EN DOMICILIO DE ENVIO*/
		LET vCodret = '00001';
	END IF;
		RETURN vCodret;
    END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Mantenimiento al Proceso de Reenvio de Token',
'Solicito: Ismael Hernández Monroy',
'Descripcion: Actualiza el domicilio de reenvio de token con el mas actual.',
'Fecha: 2011/08/01',
'Version: 20110801.1603',
'BD: bdibpi';

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