CREATE PROCEDURE "informix".sp_obt_solicitud_gen_guia(pRegistros SMALLINT)
   returning char(5), char(10), char(9), char(5), char(5), char(4), char(20), char(8), integer, char(26), char(26), char(26), char(26),char(10),char(200);
   
--Modifico: Jose Ruben Lopez
--Actividad: Se obtienen las solicitudes para la generacion de guia
--Fecha: 20-08-2014
--Solilcitó: Jose de jesus
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
	DEFINE vNtoken		char(10);
	DEFINE vNombreCte   char(29);
	
	DEFINE vFechaVieja date;
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret      = '00000';
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
   LET vNtoken='';
   LET vNombreCte='';
   
   LET vFechaVieja = current - Interval(30) day TO day;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vNtoken, vComentarios;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO '/sp_obt_solicitud_gen_guia.out';
	--TRACE ON ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
	
		FOREACH
			SELECT  SKIP pRegistros FIRST 10 
				{+INDEX(bdibpi:"informix".bpi_tokensolicitud 502_510)} tk.solicitud,tk.ns_token,tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
				si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
				INTO vSolicitud,vNtoken,vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
				FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
				WHERE tk.id_status='110'
				AND tk.guia='f'
				AND NVL(tk.ns_token,'')<>''
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
				
				ELSE --- PF
				    LET vNombreCte=LENGTH(TRIM(vNombre1) || TRIM(vNombre2) || TRIM(vApaterno) || TRIM(vAmaterno));
						IF (vNombreCte > 26) THEN
						    LET vNombreCte=LENGTH(TRIM(vNombre1) || TRIM(vApaterno) || TRIM(vAmaterno));
								IF (vNombreCte > 26) THEN
									LET vNombre2='';
									LET vAmaterno='';
								ELSE
								    LET vNombre2='';
								END IF;
						END IF;
				
								
				END IF;
				
				
				RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, NVL(vUsrSolicita,''), vSecuencia, vNombre1, NVL(vNombre2,''), vApaterno, NVL(vAmaterno,''),NVL(vNtoken,''),NVL(vComentarios,'') WITH RESUME;
				
		END FOREACH;
		IF (vCliente ='') THEN
			LET cod_ret = '001';
			RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno,vNtoken,vComentarios;
		END IF;
END;

END PROCEDURE ;