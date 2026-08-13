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