CREATE PROCEDURE "informix".sp_obt_solicitud_admtoken_bei(pSolicitud char(10), pCliente char(9), pStatus char(5), pSucursal char(4), pFecha char(20), pRegistros smallint, pTipoConsulta char(1))
   returning char(5), char(10), char(9), char(5), char(5), char(4), char(20), char(8), integer, char(26), char(26), char(26), char(26),char(60), char(200);

--------------------------------------------------------------------------------------------
-- Realizó: Jose Ruben Lopez
-- Actividad: Obtiene los datos de la consulta de solicitudes del AdmToken personas morales
-- Solicitó: José de Jesús Nevarez.
-- Fecha: 2013-08-26.
-- BD:bdibei.
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret      char(5);
	DEFINE sql_err      integer;
	DEFINE vSolicitud   char(10);
	DEFINE vCliente     char(9);
	DEFINE vStatus      char(5);
    DEFINE vUnidades 		char(5) ;
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
   LET vUnidades = '';
   LET vComentarios = '';
   LET vTipoPersona = '';
   LET iLongitud =0;
   LET vFechaVieja = CURRENT - INTERVAL(62) DAY TO DAY;
	
	--SET DEBUG FILE TO '/tmp/sp_obt_solicitud_admtoken_bei.out';
	--TRACE ON ;
	
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vRazonSocial, vComentarios;
      END IF ;
   END EXCEPTION ;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(pTipoConsulta IS NULL OR pTipoConsulta = '') THEN
	
		LET cod_ret = '002';
	
		RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vRazonSocial, vComentarios;
	
	ELIF(pTipoConsulta = '1') THEN 
	
	-- pTipoConsulta = 1. Consulta todas las solicitudes sin validación a los 3 meses
		IF (pFecha <> '' AND pFecha IS NOT NULL) THEN
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				tk.solicitud, tk.numcte, tk.id_status::char(5), tk.unidades::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM   "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si
				WHERE tk.solicitud MATCHES ('*' || pSolicitud)
				AND tk.numcte MATCHES ('*' || pCliente)
				AND tk.id_status::char(5) MATCHES ('*' || pStatus)
				AND tk.sucursal MATCHES ('*' || pSucursal)
				AND date(tk.f_solicitud) = pFecha::date
				AND si.numcte = tk.numcte
				ORDER BY tk.id_status, tk.solicitud ASC
			
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

			RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''),NVL(vRazonSocial,''),NVL(vComentarios,'') WITH RESUME;
				
			END FOREACH;
		ELSE
		
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				tk.solicitud, tk.numcte, tk.id_status::char(5), tk.unidades::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si
				WHERE tk.solicitud MATCHES ('*' || pSolicitud)
				AND tk.numcte MATCHES ('*' || pCliente)
				AND tk.id_status::char(5) MATCHES ('*' || pStatus)
				AND tk.sucursal MATCHES ('*' || pSucursal)
				AND si.numcte = tk.numcte
				ORDER BY tk.id_status, tk.solicitud ASC
				
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
						
				RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''),NVL(vRazonSocial,''), NVL(vComentarios,'') WITH RESUME;
				
			END FOREACH;
				IF (vCliente ='') THEN
					LET cod_ret = '001';
					RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vRazonSocial,vComentarios;
				END IF;
		END IF;

		
	ELIF(pTipoConsulta = '2') THEN
	-- pTipoConsulta = 2. Consulta todas las solicitudes con validación a los 3 meses
		IF (pFecha <> '' AND pFecha IS NOT NULL) THEN
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				tk.solicitud, tk.numcte, tk.id_status::char(5), tk.unidades::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM   "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si
				WHERE tk.solicitud MATCHES ('*' || pSolicitud)
				AND tk.numcte MATCHES ('*' || pCliente)
				AND tk.id_status::char(5) MATCHES ('*' || pStatus)
				AND tk.sucursal MATCHES ('*' || pSucursal)
				AND date(tk.f_solicitud) = pFecha::date
				AND si.numcte = tk.numcte
				ORDER BY tk.id_status, tk.solicitud ASC
			
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

			RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''),NVL(vRazonSocial,''), NVL(vComentarios,'') WITH RESUME;
				
			END FOREACH;
		ELSE	
			FOREACH
			
				SELECT  SKIP pRegistros FIRST 10 
					tk.solicitud, tk.numcte, tk.id_status::char(5), tk.unidades::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
					si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
					INTO vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
					FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si
					WHERE tk.solicitud MATCHES ('*' || pSolicitud)
					AND tk.numcte MATCHES ('*' || pCliente)
					AND tk.id_status::char(5) MATCHES ('*' || pStatus)
					AND tk.sucursal MATCHES ('*' || pSucursal)
					AND si.numcte = tk.numcte
					AND vFechaVieja  < date(tk.f_solicitud) 
					ORDER BY tk.id_status, tk.solicitud ASC
					
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
							
					RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''),NVL(vRazonSocial,''), NVL(vComentarios,'') WITH RESUME;
					
				END FOREACH;

		END IF;
		IF (vCliente ='') THEN
					LET cod_ret = '001';
					RETURN cod_ret, vSolicitud, vCliente, vStatus, vUnidades, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vRazonSocial, vComentarios;
				END IF;
	END IF;
	
END

END PROCEDURE ;