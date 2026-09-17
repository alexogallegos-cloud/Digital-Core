CREATE PROCEDURE "informix".sp_obt_solicitud_admtoken(pSolicitud char(10), pCliente char(9), pStatus char(5), pTipo char(5), pSucursal char(4), pFecha char(20), pRegistros smallint, pTipoConsulta char(1))
   returning char(5), char(10), char(9), char(5), char(5), char(4), char(20), char(8), integer, char(26), char(26), char(26), char(26), char(200);

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene los datos de la consulta de solicitudes del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 05/11/2009.
-- Modificó: Pedro Enrique Zavala Valdez
-- Fecha de Modificación: 22/01/2010
-- Modificación: Se valida si se consulta con una fecha de 30 días
-- Modificó: Pedro Enrique Zavala Valdez
-- Fecha de Modificación: 26/01/2010
-- Modificación: Se valida si se consulta al ingresar al sistema
-- Fecha de Modificación: 07-04-2010
-- Modificación: Se ordenan las solicitudes por número de solicitud
-- Modificó: Nubia Janeth Montoya Medina
--************************************************************************************
--Modifico: José de Jesús Nevarez
--Actividad: Se modifica sp para que obtenga la razon social para los clientes de la EmpresaNet.
--Fecha: 23-08-2011
--Solilcitó: Diana Castellanos
--************************************************************************************
--Modifico: Juan Daniel Lazalde
--Actividad: Se agrego en la tipoConsulta 3 para que consulte por estatus 200 (Recibida) tipo 6 (Nueva Rnv)
--Fecha: 15-11-2013
--Solilcitó: Mauricio León
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret      char(5);
	DEFINE sql_err      integer;
	DEFINE vSolicitud   char(10);
	DEFINE vCliente     char(9);
	DEFINE vStatus      char(5);
    DEFINE vTipo 		char(5) ;
	DEFINE vSucursal    char(4) ;
	DEFINE vFecha       char(50) ;
	DEFINE vUsrSolicita char(8) ;
    DEFINE vNombre1     char(26);
    DEFINE vNombre2     char(26);
    DEFINE vApaterno    char(26);
    DEFINE vAmaterno    char(26);    
    DEFINE vSecuencia   integer;
	DEFINE vComentarios char(200);
	DEFINE vRazonSocial	char(60);
	DEFINE vTipoPersona char (2);
	DEFINE iLongitud    integer;
	
	DEFINE vFechaVieja date;
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret      = '000';
   LET vNombre1     = '';
   LET vNombre2     = '';
   LET vApaterno    = '';
   LET vAmaterno    = '';
   LET vSolicitud   = '';
   LET vCliente     = '';
   LET vStatus      = '';
   LET vSucursal    = '';
   LET vRazonSocial = '';
   LET vFecha       = '01-01-1900';
   LET vUsrSolicita  = '';
   LET vSecuencia   = 0;
   LET vTipo = '';
   LET vComentarios = '';
   LET vTipoPersona = '';
   LET iLongitud =0;
   
   LET vFechaVieja = current - Interval(30) day TO day;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO '/informix/jessica/sp_obtenersol.out';
	--TRACE ON ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
		
	IF (pStatus <> '' OR length(trim(pStatus))>0) THEN
	
	   IF (pStatus='100') then
			LET pTipoConsulta=1;
			IF (length(trim(pTipo))=0) THEN
				LET pTipo= '1';
			END IF
	   ELIF (pStatus='200') then
	        LET pTipoConsulta=1;
			LET pTipo='6';
	   ELIF (pStatus='180') then
	        LET pTipoConsulta=1;
	   END IF
	  
    ELSE 
	
		IF(pTipo <> '' OR length(trim(pTipo))>0 ) THEN
			IF (pTipo=1 or pTipo=3) THEN
				LET pTipoConsulta=1;
				LET pStatus='100';
			ELIF (pTipo=6) THEN
				LET pTipoConsulta=1;
				LET pStatus='200';
			ELSE
				LET pTipoConsulta=2;
				LET pStatus='';
			END IF;
		END IF;
	END IF   
	
	IF(pTipoConsulta = '1') THEN 
	
	-- pTipoConsulta = 1. Consulta todas las solicitudes sin validación a los 30 días
		IF (pFecha <> '' AND pFecha IS NOT NULL) THEN
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				{+INDEX(bdibpi:"informix".bpi_tokensolicitud 502_510)} tk.solicitud, tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
				WHERE tk.solicitud MATCHES ('*' || pSolicitud)
				AND tk.numcte MATCHES ('*' || pCliente)
				AND tk.id_status::char(5) MATCHES ('*' || pStatus)
				AND tk.tipo::char(5) MATCHES ('*' || pTipo)
				AND tk.sucursal MATCHES ('*' || pSucursal)
				AND date(tk.f_solicitud) = pFecha::date
				AND si.numcte = tk.numcte
				AND si.empresa = tk.empresa ORDER BY tk.id_status , tk.tipo, tk.solicitud ASC
			
			IF  (vTipoPersona <> '01') THEN 
				LET vRazonSocial = TRIM(vRazonSocial);
				LET iLongitud = LENGTH(vRazonSocial);
				LET vNombre1 = '';
				LET vNombre2 = '';
				LET vApaterno = '';

				IF (iLongitud <= 24) THEN
					LET vNombre1 = vRazonSocial;
				ELSE 
					LET vNombre1 = SUBSTRING(vRazonSocial FROM 1 FOR 24);
					LET vNombre2 = SUBSTRING(vRazonSocial FROM 25 FOR 24);
					IF (iLongitud > 48) THEN
						LET vApaterno = SUBSTRING(vRazonSocial FROM 49 FOR (iLongitud - 48));
					END IF;
				END IF;
			END IF;

			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''), NVL(vComentarios,'') WITH RESUME;
				
			END FOREACH;
		ELSE
		    
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				{+INDEX(bdibpi:"informix".bpi_tokensolicitud 502_510)} tk.solicitud, tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
				WHERE tk.solicitud MATCHES ('*' || pSolicitud)
				AND tk.numcte MATCHES ('*' || pCliente)
				AND tk.id_status::char(5) MATCHES ('*' || pStatus)
				AND tk.tipo::char(5) MATCHES ('*' || pTipo)
				AND tk.sucursal MATCHES ('*' || pSucursal)
				AND si.numcte = tk.numcte
				AND si.empresa = tk.empresa ORDER BY tk.id_status , tk.tipo, tk.solicitud ASC
				
				IF  (vTipoPersona <> '01') THEN 
					LET vRazonSocial = TRIM(vRazonSocial);
					LET iLongitud = LENGTH(vRazonSocial);
					LET vNombre1 = '';
					LET vNombre2 = '';
					LET vApaterno = '';

					IF (iLongitud <= 24) THEN
						LET vNombre1 = vRazonSocial;
					ELSE 
						LET vNombre1 = SUBSTRING(vRazonSocial FROM 1 FOR 24);
						LET vNombre2 = SUBSTRING(vRazonSocial FROM 25 FOR 24);
						IF (iLongitud > 48) THEN
							LET vApaterno = SUBSTRING(vRazonSocial FROM 49 FOR (iLongitud - 48));
						END IF;
					END IF;
				END IF;
				
				RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''), NVL(vComentarios,'') WITH RESUME;
				
			END FOREACH;
		END IF;


		IF (vCliente ='') THEN
			LET cod_ret = '001';
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios;
		END IF;
		
		
	ELIF(pTipoConsulta = '2') THEN
	
	-- pTipoConsulta = 2. Consulta todas las solicitudes con validación a los 30 días

		FOREACH
		
		SELECT  SKIP pRegistros FIRST 10 
			{+INDEX(bdibpi:"informix".bpi_tokensolicitud 502_510)} tk.solicitud, tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
			si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
			INTO vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
			FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
			WHERE tk.solicitud MATCHES ('*' || pSolicitud)
			AND tk.numcte MATCHES ('*' || pCliente)
			AND tk.id_status::char(5) MATCHES ('*' || pStatus)
			AND tk.tipo::char(5) MATCHES ('*' || pTipo)
			AND tk.sucursal MATCHES ('*' || pSucursal)
			AND vFechaVieja  < date(tk.f_solicitud) 
			AND si.numcte = tk.numcte
			AND si.empresa = tk.empresa ORDER BY tk.id_status , tk.tipo, tk.solicitud ASC
			
			IF  (vTipoPersona <> '01') THEN 
				LET vRazonSocial = TRIM(vRazonSocial);
				LET iLongitud = LENGTH(vRazonSocial);
				LET vNombre1 = '';
				LET vNombre2 = '';
				LET vApaterno = '';

				IF (iLongitud <= 24) THEN
					LET vNombre1 = vRazonSocial;
				ELSE 
					LET vNombre1 = SUBSTRING(vRazonSocial FROM 1 FOR 24);
					LET vNombre2 = SUBSTRING(vRazonSocial FROM 25 FOR 24);
					IF (iLongitud > 48) THEN
						LET vApaterno = SUBSTRING(vRazonSocial FROM 49 FOR (iLongitud - 48));
					END IF;
				END IF;
			END IF;
			
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''), NVL(vComentarios,'') WITH RESUME;
			
		END FOREACH;


		IF (vCliente ='') THEN
			LET cod_ret = '001';
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios;
		END IF;
	
   /* ELIF(pTipoConsulta = '3') THEN
	
	-- pTipoConsulta = 3. Consulta todas las solicitudes cuando se ingresa al sistema

		FOREACH
		
		SELECT  SKIP pRegistros FIRST 10 
			{+INDEX(bdibpi:"informix".bpi_tokensolicitud 502_510)} tk.solicitud, tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
			si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
			INTO vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
			FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
			WHERE tk.solicitud MATCHES ('*' || '')
			AND tk.numcte MATCHES ('*' || '')
			AND (tk.id_status  IN  (100,180,200))
			AND tk.tipo::char(5) MATCHES ('*' || '')
			AND tk.sucursal MATCHES ('*' || '')
			AND (tk.f_solicitud::date)::char(20) MATCHES ('*' || '')
			AND si.numcte = tk.numcte
			AND si.empresa = tk.empresa ORDER BY tk.id_status , tk.tipo, tk.solicitud ASC
			
			IF  (vTipoPersona <> '01') THEN 
				LET vRazonSocial = TRIM(vRazonSocial);
				LET iLongitud = LENGTH(vRazonSocial);
				LET vNombre1 = '';
				LET vNombre2 = '';
				LET vApaterno = '';

				IF (iLongitud <= 24) THEN
					LET vNombre1 = vRazonSocial;
				ELSE 
					LET vNombre1 = SUBSTRING(vRazonSocial FROM 1 FOR 24);
					LET vNombre2 = SUBSTRING(vRazonSocial FROM 25 FOR 24);
					IF (iLongitud > 48) THEN
						LET vApaterno = SUBSTRING(vRazonSocial FROM 49 FOR (iLongitud - 48));
					END IF;
				END IF;
			END IF;
					
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''), NVL(vComentarios,'') WITH RESUME;
		
		END FOREACH;


		IF (vCliente ='') THEN
			LET cod_ret = '001';
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios;
		END IF;
*/
    ELSE
	
		LET cod_ret = '002';
	
		RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios;
	
	END IF;


END

END PROCEDURE ;