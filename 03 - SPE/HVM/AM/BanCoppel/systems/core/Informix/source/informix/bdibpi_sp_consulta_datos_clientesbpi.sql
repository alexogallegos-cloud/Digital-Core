CREATE PROCEDURE "informix".sp_consulta_datos_clientesbpi(pEmpresa CHAR(3), pNumCte CHAR(20))

--DATOS A REGRESAR---
RETURNING
CHAR(5), -- Codigo de Retorno
CHAR(10), --numero de solicitud
CHAR(20), -- Numero de Cliente
CHAR(26), -- Apellido Paterno
CHAR(26), -- Apellido Materno
CHAR(26), -- Nombre1
CHAR(26), -- Nombre2
CHAR(10), -- Fecha Nacimiento
CHAR(4), -- Id Status
CHAR(40), -- Descripción Status
SMALLINT, --Tipo Servicio
CHAR(30), --direccion
CHAR(50), --colonia
CHAR(50),--municipio
CHAR(5),--cp
CHAR(30),--dirCom
CHAR(200),--comentarios
DATE,	--Fecha envio
CHAR(250); --Mensaje Status

--DEFINICION DE VARIABLES--
DEFINE sql_err INT;
DEFINE vCodRet CHAR(5);
DEFINE vNumCte CHAR(20);
DEFINE vApePat CHAR(26);
DEFINE vApeMat CHAR(26);
DEFINE vNombre1 CHAR(26);
DEFINE vNombre2 CHAR(26);
DEFINE vFechaNac CHAR(10);
DEFINE vStatus SMALLINT;
DEFINE vDescStatus CHAR(40);
DEFINE vTipoServicio SMALLINT;
DEFINE vDireccion CHAR(30);
DEFINE vColonia CHAR(50);
DEFINE vDelMpio	CHAR(50);
DEFINE vCP CHAR(5);
DEFINE vDirCom CHAR(30);                
DEFINE vComentarios CHAR(200);
DEFINE vFechaEnvio DATE;
DEFINE vSolicitud CHAR(10);
DEFINE vStatus2 SMALLINT;
DEFINE vMensaje CHAR(250);

--INICIALIZACION DE VARIABLES--
LET sql_err = 0;
LET vCodRet = '00000';
LET vNumCte = '';
LET vApePat = '';
LET vApeMat = '';
LET vNombre1 = '';
LET vNombre2 = '';
LET vFechaNac = '';
LET vStatus = 0;
LET vDescStatus = '';
LET vTipoServicio = 0;
LET vDireccion = '';
LET vColonia = '';
LET vDelMpio = '';
LET vCP = '';
LET vDirCom = '';        
LET vComentarios = '';
LET vFechaEnvio = '';
LET vSolicitud = '';
LET vStatus2 = 0;
LET vMensaje = '';

    --SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consulta_datos_clientesbpi.out";
   --TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, vSolicitud, vNumCte, vApePat, vApeMat, vNombre1, vNombre2,  vFechaNac, vStatus, vDescStatus, vTipoServicio, vDireccion,  vColonia, vDelMpio, vCP, vDirCom, vComentarios, vFechaEnvio, vMensaje;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF (SELECT count(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) > 0 AND (SELECT COUNT(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) > 0 THEN

		IF (SELECT servicio FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 1 THEN
			LET vCodRet = '00003'; -- El cliente cuenta con servicio de internet basico
		ELSE
		
			IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) > 0 AND (SELECT count(numcte) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = pNumCte) > 0 THEN
			
				SELECT MAX (solicitud)
				INTO vSolicitud  
				FROM bdibpi:"informix".bpi_tokensolicitud 
				WHERE numcte = pNumCte;

				SELECT id_status
				INTO vStatus
				FROM bdibpi:"informix".bpi_tokensolicitud 
				WHERE numcte = pNumCte
				AND solicitud = vSolicitud;

				SELECT  bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, 
						bdi_sictepf.fecha_nac, bdi_tkbpi.id_status, bdi_sista.desc_status, bdi_sibpi.servicio, bdi_catmsj.mensaje
				INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vFechaNac, vStatus, vDescStatus, vTipoServicio, vMensaje
				FROM bdinteg:"informix".si_cliente bdi_sicte, 
					 bdinteg:"informix".si_ctepf bdi_sictepf, 
					 bdibpi:"informix".bpi_tokensolicitud bdi_tkbpi,
					 bdinteg:"informix".si_bpiusuarios bdi_sibpi, 
					 bdinteg:"informix".si_bpistatus bdi_sista,
					 bdibpi:"informix".bpi_catmensajes bdi_catmsj
				WHERE bdi_sicte.numcte = pNumCte
				AND bdi_sicte.empresa = pEmpresa
				AND bdi_sicte.numcte = bdi_sictepf.numcte
				AND bdi_sicte.numcte = bdi_sibpi.numcte
				AND bdi_sicte.numcte = bdi_tkbpi.numcte
				AND bdi_sista.id_status = vStatus
				AND bdi_tkbpi.solicitud = vSolicitud
				AND bdi_catmsj.status_servicio = vStatus;

				EXECUTE PROCEDURE bdibpi:"informix".sp_consultar_status_solicitud_token(vNumCte, vSolicitud)
				INTO vCodRet, vStatus2, vDireccion,  vColonia, vDelMpio, vCP, vDirCom, vComentarios, vFechaEnvio;
				
			ELSE
				LET vCodRet = '00004'; -- El cliente no ha concluido su pre-activacion del servicio
			END IF;

		END IF;

	ELSE

		IF (SELECT count(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) = 0 AND (SELECT COUNT(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 0 THEN
			LET vCodRet = '00001'; -- Cliente No existe
		ELIF (SELECT count(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte) > 0 AND (SELECT COUNT(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 0 THEN
			LET vCodRet = '00002'; -- El cliente no tiene activado el servicio de banca por internet
		END IF;

	END IF;

	RETURN vCodRet, vSolicitud, vNumCte, vApePat, vApeMat, vNombre1, vNombre2,  vFechaNac, vStatus, vDescStatus, vTipoServicio, vDireccion,  vColonia, vDelMpio, vCP, vDirCom, vComentarios, vFechaEnvio, vMensaje;

END
END PROCEDURE

DOCUMENT
"Autor : Daniela Ramirez",
"FECHA : 29/06/2011",
"Descripcion: Consulta datos del cliente y estatus de la solicitud del cliente",
"Ver.  : 1.0",
"BD    : bdibpi", 
"Modifico : Daniela Ramirez",
"FECHA : 20/07/2011",
"Descripcion: Se agregan validaciones con codret = 00001, 00002 y 00003",
"BD    : bdibpi",
"Modifico : Daniela Ramirez",
"FECHA : 01/08/2011",
"Descripcion 1: Se agrega validacion con codret = 00004, para cuando el cliente dejo su preactivacion inconclusa",
"Descripcion 2: Se realiza consulta de solicitud maxima para cuando el cliente tiene mas de una solicitud en la bpi_tokensolicitud",
"BD    : bdibpi";

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