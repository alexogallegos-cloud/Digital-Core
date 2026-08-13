CREATE PROCEDURE "informix".sps_validapaws_bpi (pEmpresa char(3), pIdUsuario char(20))
returning char(5),char(50),smallint,char(26),char(26),char(26),char(26), char(13), char(13), char(13), date, date;

	--Modificó: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
--Se crea spl con el nombre modificado
  --RQI CheckmarxB18  BPI
  --Gabrieal Aguilar  
  --10-03-2025  
    
    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_usuario, v_pass, v_pass1, v_pass2, v_pass3 char(50);
    define v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno char(26);
    define v_rfc, v_telefono1, v_telefono2 char(13);
    define v_fecha_nac, v_fecha_actual DATE;
	define sBandera smallint;
	define pNumCte char(20);
	
	--Descripción: Valida Pass
	--22/04/2015
    
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret = "000";
    let v_usuario = "";
    let v_pass = "";
    let v_pass1 = "";
    let v_pass2 = "";
    let v_pass3 = "";
    let v_nombre1 = "";
    let v_nombre2 = "";
    let v_apell_paterno = "";
    let v_apell_materno = "";
    let v_rfc = "";
    let v_telefono1 = "";
    let v_telefono2 = "";
    let  v_fecha_nac = '01-01-1900';
    let  v_fecha_actual = CURRENT ;
	let sBandera="";
    
	--SET DEBUG FILE TO "/home/informix/bibiana/sps_validapaws_bpi.out";
	--TRACE ON;
	
    BEGIN
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_usuario, sBandera, v_nombre1, v_nombre2, 
                   v_apell_paterno, v_apell_materno, v_rfc, v_telefono1, v_telefono2,  v_fecha_nac, v_fecha_actual;
        end if
    end exception;
	
	SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo'; -- ID_usuario
		
		IF pNumCte = '' OR pNumCte IS NULL THEN
			LET pNumCte = "";
			LET pNumCte = pIdUsuario;
		END IF
    
    IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN
        SELECT LIMIT 1 usuario, pass, pass1, pass2, pass3 
          INTO v_usuario, v_pass, v_pass1, v_pass2, v_pass3 
          FROM bdinteg:"informix".si_bpiusuarios 
         WHERE empresa = pEmpresa 
           AND numcte = pNumCte;
		   
		IF (NVL(v_pass1,'') == '' AND NVL(v_pass2,'') == '' AND NVL(v_pass3,'') == '' )THEN
			let sBandera="0";
		ELSE
			let sBandera="1";
		END IF;
		   
        
        SELECT LIMIT 1 nombre1, nombre2, apell_paterno, apell_materno,  rfc
          INTO  v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_rfc
          FROM bdinteg:"informix".si_cliente
         WHERE empresa = pEmpresa
           AND numcte =  pNumCte;

        
        SELECT telefono
          INTO v_telefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT telefono
          INTO v_telefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
        
        SELECT LIMIT 1 fecha_nac 
          INTO v_fecha_nac 
          FROM bdinteg:"informix".si_ctepf 
         WHERE numcte = pNumCte;
    ELSE
        LET cod_ret = '001';
    END IF;
    
    return cod_ret, nvl(v_usuario,''),sBandera, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno,
		nvl(v_rfc,''), nvl(v_telefono1,''), nvl(v_telefono2,''),  v_fecha_nac, v_fecha_actual;
    
    END
    
END PROCEDURE
Document
'DESCRIPCION: Sp utilizado en el proceso de validacion de contrasenia en HSM', 
'AUTOR: Ilse Gomez',
'FECHA:26/03/2015',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sps_validapaws_bpi(pEmpresa char(3), pIdUsuario char(20), pIndicador CHAR(1))
returning char(5),char(50),smallint,char(26),char(26),char(26),char(26), char(13), char(13), char(13), date, date;

	--Modificó: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
	
	--Modificó: Moisés Soriano
	--Actividad: Se sobrecarga sps_validapass_bpi,
	-- Se agrega parámetro pIndicador, se cambia validacion de recepcion de pIdUsuario
	--Solicito: Jose de Jesus
	--Fecha: 11/04/2016
	
 --Se crea spl con el nombre modificado
  --RQI CheckmarxB18  BPI
  --Gabrieal Aguilar  
  --10-03-2025  
    
    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_usuario, v_pass, v_pass1, v_pass2, v_pass3 char(50);
    define v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno char(26);
    define v_rfc, v_telefono1, v_telefono2 char(13);
    define v_fecha_nac, v_fecha_actual DATE;
	define sBandera smallint;
	define pNumCte char(20);
	
	--Descripción: Valida Pass
	--22/04/2015
    
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret = "000";
    let v_usuario = "";
    let v_pass = "";
    let v_pass1 = "";
    let v_pass2 = "";
    let v_pass3 = "";
    let v_nombre1 = "";
    let v_nombre2 = "";
    let v_apell_paterno = "";
    let v_apell_materno = "";
    let v_rfc = "";
    let v_telefono1 = "";
    let v_telefono2 = "";
    let  v_fecha_nac = '01-01-1900';
    let  v_fecha_actual = CURRENT ;
	let sBandera="";
    
	--SET DEBUG FILE TO "/home/informix/bibiana/sps_validapaws_bpi.out";
	--TRACE ON;
	
    BEGIN
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_usuario, sBandera, v_nombre1, v_nombre2, 
                   v_apell_paterno, v_apell_materno, v_rfc, v_telefono1, v_telefono2,  v_fecha_nac, v_fecha_actual;
        end if
    end exception;
	
	SET LOCK MODE TO WAIT ;

	IF pIndicador = '1' THEN  -- pIdUsuario = id_usuario
		SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
	ELIF pIndicador = '2' THEN -- pIdUsuario = numcliente
		LET pNumCte = pIdUsuario;
	END IF;
	
    IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN
        SELECT LIMIT 1 usuario, pass, pass1, pass2, pass3 
          INTO v_usuario, v_pass, v_pass1, v_pass2, v_pass3 
          FROM bdinteg:"informix".si_bpiusuarios 
         WHERE empresa = pEmpresa 
           AND numcte = pNumCte;
		   
		IF (NVL(v_pass1,'') == '' AND NVL(v_pass2,'') == '' AND NVL(v_pass3,'') == '' )THEN
			let sBandera="0";
		ELSE
			let sBandera="1";
		END IF;
		   
        
        SELECT LIMIT 1 nombre1, nombre2, apell_paterno, apell_materno,  rfc
          INTO  v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_rfc
          FROM bdinteg:"informix".si_cliente
         WHERE empresa = pEmpresa
           AND numcte =  pNumCte;

        
        SELECT telefono
          INTO v_telefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT telefono
          INTO v_telefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
        
        SELECT LIMIT 1 fecha_nac 
          INTO v_fecha_nac 
          FROM bdinteg:"informix".si_ctepf 
         WHERE numcte = pNumCte;
    ELSE
        LET cod_ret = '001';
    END IF;
    
    return cod_ret, nvl(v_usuario,''),sBandera, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno,
		nvl(v_rfc,''), nvl(v_telefono1,''), nvl(v_telefono2,''),  v_fecha_nac, v_fecha_actual;
    
    END
    
END PROCEDURE
Document
'DESCRIPCION: Sp utilizado en el proceso de validacion de contrasenia en HSM', 
'AUTOR: Ilse Gomez',
'FECHA:26/03/2015',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_cont_siejecut(pBandera CHAR(1), pUsuario CHAR(8), pPass_cod CHAR(40))
	--Se asignan los valores de retorno en las consultas, valores seleccionados, se definen tal cual de la consulta
	RETURNING CHAR(5)  AS codret, 
			  CHAR(45)  AS nombre,
			  CHAR(3) As departamento,
			  CHAR(3)  AS empresa, 
			  CHAR(8) AS ejecutivo, 
			  CHAR(4) AS sucursal, 
			  CHAR(3) AS puesto,
			  VARCHAR(80) AS pas_cod,
			  DECIMAL(14,2) AS limaut_mn,
			  DECIMAL(14,2) AS limaut_dls,
			  DATE AS vigencia,
			  INTEGER AS perfil,
			  CHAR(30) AS user_insert,
			  DATE AS fecha_insert,
			  CHAR(40) AS password, 
			  CHAR(20) AS nombramiento, 
			  CHAR(10) AS asistente;
	
	DEFINE cCodRet				CHAR(5);
	DEFINE iSqlErr				INTEGER;	
	DEFINE cNombre	 			CHAR(45);
	DEFINE cDepartamento 		CHAR(3);
	DEFINE cEmpresa 			CHAR(3);
	DEFINE cEjecutivo 			CHAR(8);
	DEFINE cSucursal 			CHAR(4);
	DEFINE cPuesto 				CHAR(3);
	DEFINE vSpASsword           CHAR(40);
	DEFINE vSpAS_cod            CHAR(40);
	DEFINE dLimaut_mn           DECIMAL(14,2);
	DEFINE dLimaut_dls          DECIMAL(14,2);
	DEFINE cVigencia            DATE;
	DEFINE iPerfil            	INTEGER;
	DEFINE cUser_insert         CHAR(30);
	DEFINE dFecha_insert        DATE;
	DEFINE cNombramiento		CHAR(20);
	DEFINE cAsistente			CHAR(10);
	DEFINE cRazon_social	 	CHAR(30);
	
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	
	LET cNombre	 	        = '';
	LET cDepartamento       = '';
	LET cEmpresa 	        = '';
	LET cEjecutivo 	        = '';
	LET cSucursal 	        = '';
	LET cPuesto 		    = '';
	let vSpASsword			= '';
	LET vSpAS_cod           = '';
	LET dLimaut_mn          = '';
	LET dLimaut_dls         = '';
	LET cVigencia           = '';
	LET iPerfil             = 0;
	LET cUser_insert        = '';
	LET dFecha_insert       = '';
	LET cNombramiento 		= '';
	LET cAsistente			= '';
	LET cRazon_social		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_siejecut.out';
		--TRACE ON;
		
		--se valida si algun parametro viene vacio.
		IF pBandera = '' OR pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			--Se define la consulta.		
			SELECT empresa, ejecutivo, nombre, sucursal, puesto, departamento, password, pass_cod, nombramiento, limaut_mn, limaut_dls, vigencia, perfil, 
			asistente, user_insert, fecha_insert  
			INTO cEmpresa, cEjecutivo, cNombre, cSucursal, cPuesto, cDepartamento, vSpASsword, vSpAS_cod, cNombramiento, dLimaut_mn, dLimaut_dls, cVigencia,
			iPerfil, cAsistente, cUser_insert, dFecha_insert
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pUsuario and pass_cod = pPass_cod;
			
		ELIF pBandera = '2' THEN
			SELECT nombre, departamento  
			INTO cNombre, cDepartamento
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pUsuario;
			
		ELIF pBandera = '3' THEN
			
			SELECT puesto, sucursal 
			INTO cPuesto, cSucursal
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pUsuario AND puesto = (SELECT valor FROM bdinteg:"informix".si_vbparam  WHERE desc_campo='cve_admon');
			
		ELIF pBandera = '4' THEN
			
			SELECT nombre, sucursal 
			INTO cNombre, cSucursal 
			FROM bdinteg:"informix".si_ejecut  
			WHERE ejecutivo = pUsuario;
		
		ELSE
			SELECT asistente, password 
			INTO cAsistente, vSpASsword 
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pUsuario;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
		END IF;
		
		RETURN cCodRet, cNombre, cDepartamento, cEmpresa, cEjecutivo, 
			cSucursal, cPuesto, vSpAS_cod, dLimaut_mn, dLimaut_dls, cVigencia, iPerfil, cUser_insert, dFecha_insert, vSpASsword, cNombramiento, cAsistente;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 30/08/2022',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: APLICATIVOS CONTABILIDAD',
'DESCRIPCION: SPL encargado de recuperar la sucursal y el nombre mediante una consulta interna que obtiene el valor por el ejecutivo, tabla sucursales';

CREATE PROCEDURE "informix".sp_consultarcatejecutivos(p_sEmpresa CHAR(3), p_sEjecutivo CHAR(8), p_sSucursal CHAR(4), p_sPuesto CHAR(3), 
p_sDepartamento CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno, CHAR(8) AS NumEmpleado, CHAR(45) AS NomEmpleado 

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sCodRet		CHAR(5);
	
    DEFINE v_sEjecutivo 	CHAR(8); 
    DEFINE v_sNombre 		CHAR(45); 
    DEFINE v_sSucursal 		CHAR(4); 
    DEFINE v_sPuesto 		CHAR(3); 
    DEFINE v_sDepartamento 	CHAR(3);              
    DEFINE v_sNombramiento 	CHAR(20); 
    DEFINE v_dVigencia 		DATE; 
    DEFINE v_iPerfil 		INTEGER;    
    DEFINE v_sUserInsert 	CHAR(30); 
    DEFINE v_dFechaInsert 	DATE; 

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet, '', '';
			END IF;
		END EXCEPTION;

	   --set debug file to "/tmp/sp_consultarcatejecutivos.out";
	    --trace on;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
		IF NVL(p_sEmpresa, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, '', '';
		END IF;	 
		
		IF NVL(p_sEjecutivo, '') = '' THEN
			LET p_sEjecutivo = NULL;			
		END IF;
		
		IF NVL(p_sSucursal, '') = '' THEN
			LET p_sSucursal = NULL;			
		END IF;
		
		IF NVL(p_sPuesto, '') = '' THEN
			LET p_sPuesto = NULL;			
		END IF;
		
		IF NVL(p_sDepartamento, '') = '' THEN
			LET p_sDepartamento = NULL;			
		END IF;

		FOREACH
		SELECT ejecutivo,nombre,sucursal,puesto,departamento,nombramiento,vigencia,perfil,user_insert,fecha_insert
		INTO v_sEjecutivo,v_sNombre,v_sSucursal,v_sPuesto,v_sDepartamento,v_sNombramiento,v_dVigencia,v_iPerfil,v_sUserInsert,v_dFechaInsert
		FROM bdinteg:si_ejecut
		WHERE 	ejecutivo between '90000001' and '99999999'
				and vigencia >= today - 400
				and nombramiento not in ('PROMOTOR','CAJERO PRINCIPAL', 'CAJERO MIXTO')
				AND ejecutivo = NVL(p_sEjecutivo,ejecutivo) 
				AND sucursal = NVL(p_sSucursal,sucursal) 
				AND puesto = NVL(p_sPuesto,puesto) 
				AND departamento = NVL(p_sDepartamento,departamento) 
        ORDER BY ejecutivo
		
			LET v_sCodRet = '00000';
			RETURN v_sCodRet, v_sEjecutivo,v_sNombre WITH RESUME;			
		END FOREACH;
	END
END PROCEDURE;