CREATE PROCEDURE "informix".sp_obt_datos_generaguia(pSolicitud varchar(10),pNumcte varchar(9))
	returning char(5), char(10),char(9),char(5),char(5), char(4), char(20),char(8), integer,char(26), char(26),char(26),char(26),char(200),
	char(5), char(9),char(30),char(60),char(25),char(30),char(30),char(30),char(100),char(10),char(10),char(22),char(5),CHAR(6),CHAR(6),CHAR(6)
	,CHAR(6),CHAR(6),CHAR(6),CHAR(6),CHAR(80),char(5);

---------------------------------------------------------------------------------------------
--Modifico: Ilse Jazmín Gómez Pérez
--Actividad: Obtiene los datos para generar el PDF del modulo de reimpresión de guía.
--Fecha: 03-09-2014
--Solilcitó: José de Jesus Nevarez Peinado
---------------------------------------------------------------------------------------------
--Modifico: Héctor Ramón Moreno Moreno
--Actividad: Se cambia campo vEmail a 100 caracteres.
--Fecha: 13-09-2016
--Solicitó: Gabriela Aguilar
---------------------------------------------------------------------------------------------
	DEFINE cod_ret char(5);
	DEFINE sql_err integer;
	
	--Datos Retorno sp_obt_solicitud_admtoken 
	DEFINE vSolicitud char(10);
	DEFINE vCliente   char(9);
	DEFINE vStatus      char(5);
    DEFINE vTipo 		char(5) ;
	DEFINE vSucursal    char(4) ;
	DEFINE vFecha       char(20) ;
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
	
	--Datos Retorno sp_obt_dir_admtoken 
	DEFINE vEstado  char(30);
    DEFINE vCiudad char(60);
    DEFINE vMunicipio char(25);
    DEFINE vColonia char(30);
    DEFINE vCalle char(30);
    DEFINE vCalleCom char(30);
    DEFINE vEmail char(100);
    DEFINE vNumExterior char(10);
    DEFINE vNumInterior char(10);
    DEFINE vTelefono char(10);
    DEFINE vTel char(22);
    DEFINE vCodPostal char(5);
    DEFINE vDepto char(6);
    DEFINE vTipoDir char(1);
	
	--Datos Adicionales
	DEFINE vManzana 		CHAR(6);
	DEFINE vAndador 		CHAR(6);
	DEFINE vEtapa   		CHAR(6);
	DEFINE vLote    		CHAR(6);
	DEFINE vEdificio 		CHAR(6);
	DEFINE vEntrada			CHAR(6);
	DEFINE vOtros			CHAR(6);
	DEFINE vObservaciones2 	CHAR(80);
	DEFINE vid_estado char(5);
	
	LET cod_ret       = '00000';
	
	--Datos Retorno sp_obt_solicitud_admtoken 
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
	
	--Datos Retorno sp_obt_dir_admtoken 
	LET vCalle = '';
    LET vCalleCom = '';
    LET vNumExterior = '';
    LET vNumInterior = '';
    LET vColonia = '';
    LET vMunicipio = '';
    LET vCodPostal = '';
    LET vCiudad = '';
    LET vEstado = '';
    LET vEmail = '';
    LET vDepto = '';
    LET vTipoDir = '';
    LET vTelefono = '';
    LET vTel = '';
	
	LET vManzana ='';
	LET vAndador ='';
	LET vEtapa ='';  
	LET vLote ='';
	LET vEdificio ='';
	LET vEntrada ='';
	LET vOtros ='';
	LET vObservaciones2 ='';

	LET vid_estado='';
	
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios,cod_ret, vCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vEmail, vNumExterior, vNumInterior, vTelefono, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones2,vid_estado;
		
			END IF ;
		END EXCEPTION ;
	   
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO '/home/sysifx/ilse/1482-AdmToken/sp_obt_datos_guia.out';
		--TRACE ON ;
		
		SELECT {+INDEX(bibpi:"informix".si_cliente idx_si_cliente5)}
		tk.solicitud, tk.numcte, tk.id_status::char(5), tk.tipo::char(5), tk.sucursal,tk.f_solicitud::char(50),tk.usr_solicita, tk.sec_domicilio, tk.comentarios,
		si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, si.tpo_persona
		INTO vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vComentarios, vNombre1, vNombre2, vApaterno, vAmaterno, vRazonSocial, vTipoPersona
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
		WHERE tk.solicitud = pSolicitud
		AND tk.numcte = pNumcte
		AND si.numcte = tk.numcte
		AND si.empresa = tk.empresa;
		
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
				
		IF(	vSolicitud <> '' AND vSolicitud IS NOT NULL)THEN
			EXECUTE PROCEDURE "informix".sp_obt_dir_admtoken(pNumcte , vSecuencia)	  
			INTO cod_ret, vCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle, vCalleCom, vEmail, vNumExterior, vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones2,vid_estado;
		ELSE
			LET cod_ret = '00001';
		END IF;
		
		RETURN cod_ret, vSolicitud, vCliente, vStatus, vTipo, vSucursal, vFecha, vUsrSolicita, vSecuencia, vNombre1, vNombre2, vApaterno, vAmaterno, vComentarios,cod_ret, vCliente, vEstado, vCiudad, vMunicipio, vColonia, vCalle,
                            vCalleCom, vEmail, vNumExterior, vNumInterior, vTel, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones2,vid_estado;
		
	END;

END PROCEDURE;