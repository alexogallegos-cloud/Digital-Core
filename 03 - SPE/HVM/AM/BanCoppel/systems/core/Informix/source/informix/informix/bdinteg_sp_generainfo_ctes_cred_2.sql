CREATE PROCEDURE "informix".sp_generainfo_ctes_cred_2() 
RETURNING CHAR(9);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INT;
DEFINE cNumcte          CHAR(20);
DEFINE cNumcte2          CHAR(20);
DEFINE cProducto        CHAR(4);
DEFINE cPaterno         CHAR(26);
DEFINE cMaterno         CHAR(26);
DEFINE cNombre1         CHAR(26);
DEFINE cNombre2         CHAR(26);

DEFINE cRazon           CHAR(60);
DEFINE cTipopersona     CHAR(6);
DEFINE cEstatusCli     CHAR(8);
DEFINE cParticipacion     CHAR(9);
DEFINE cTipocontrato        CHAR(100);
DEFINE dFecharelaccomer DATE;
DEFINE dFechaApertura DATE;
DEFINE dFechacancela DATE;
DEFINE cGradoRiesgo CHAR(11);
DEFINE dFechagradoriesgo DATE;
DEFINE cNacionalidad CHAR(3);
DEFINE cPais CHAR(3);
DEFINE cProfesion CHAR(3);
------------------------
DEFINE cProductoB        CHAR(4);
DEFINE cPaternoB         CHAR(26);
DEFINE cMaternoB         CHAR(26);
DEFINE cNombre1B         CHAR(26);
DEFINE cNombre2B         CHAR(26);
DEFINE cRazonB           CHAR(60);
DEFINE cTipopersonaB     CHAR(6);
DEFINE cEstatusCliB     CHAR(8);
DEFINE cParticipacionB     CHAR(9);
DEFINE cTipocontratoB        CHAR(100);
DEFINE dFecharelaccomerB DATE;
DEFINE dFechaAperturaB DATE;
DEFINE dFechacancelaB DATE;
DEFINE cGradoRiesgoB CHAR(11);
DEFINE dFechagradoriesgoB DATE;
DEFINE cNacionalidadB CHAR(3);
DEFINE cPaisB CHAR(3);
DEFINE cProfesionB CHAR(3);
------------------------
DEFINE iNoRegs		INTEGER;
DEFINE iNoRegs2		INTEGER;
DEFINE iNoRegs3		INTEGER;
DEFINE iNoRegs4		INTEGER;
DEFINE cCuenta		CHAR(20);
DEFINE cCuentaB		CHAR(20);
DEFINE cCuentaCancel CHAR(20);
DEFINE cClientefirmante		CHAR(20);
-----
DEFINE iNumerocalle    	INTEGER;
DEFINE    cNumeroextcalle 	CHAR(10);
DEFINE    cNumerointcalle 	CHAR(10);
DEFINE    iNumerocolonia  	INTEGER;
DEFINE    cCod_postal     	CHAR(5);
DEFINE    iNumerociudad   	SMALLINT;
DEFINE    cCiudad         	CHAR(3);
DEFINE    cEstado         	CHAR(2);
DEFINE    cTelefono1         	CHAR(13);
DEFINE    cTelefono2         	CHAR(13);
DEFINE    cTelefono3         	CHAR(13);
DEFINE    cTelefono4         	CHAR(13);
DEFINE	  stipo_tel			SMALLINT;
-------------------------------------------------
DEFINE iNumerocalleB    	INTEGER;
DEFINE    cNumeroextcalleB 	CHAR(10);
DEFINE    cNumerointcalleB 	CHAR(10);
DEFINE    iNumerocoloniaB  	INTEGER;
DEFINE    cCod_postalB     	CHAR(5);
DEFINE    iNumerociudadB   	SMALLINT;
DEFINE    cCiudadB         	CHAR(3);
DEFINE    cEstadoB         	CHAR(2);
DEFINE    cTelefono1B         	CHAR(13);
DEFINE    cTelefono2B         	CHAR(13);
DEFINE    cTelefono3B         	CHAR(13);
DEFINE    cTelefono4B         	CHAR(13);
DEFINE	  stipo_telB			SMALLINT;

-------------------------------------------------
DEFINE cEmail					CHAR(100);
DEFINE cCurp					CHAR(20);
DEFINE dFecha_nac			DATE;
DEFINE cRFC					CHAR(13);
DEFINE cSucursal					CHAR(4);
DEFINE cEjecutivo					CHAR(8);
DEFINE cNombreejecutivo			CHAR(45);
DEFINE cApoderado			CHAR(104);
DEFINE cNumapoderado			CHAR(20);
--------------------------------------------
DEFINE cEmailB					CHAR(100);
DEFINE cCurpB					CHAR(20);
DEFINE dFecha_nacB			DATE;
DEFINE cRFCB					CHAR(13);
DEFINE cSucursalB					CHAR(4);
DEFINE cEjecutivoB					CHAR(8);
DEFINE cNombreejecutivoB			CHAR(45);
DEFINE cApoderadoB			CHAR(104);
DEFINE cNumapoderadoB			CHAR(20);

DEFINE iContador            INTEGER;
DEFINE sCommit              SMALLINT;
DEFINE sParamCta            CHAR(20);

-------------------------------------------

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET cNumcte='';
LET cNumcte2='';
LET cProducto='';
LET cPaterno='';
LET cMaterno='';
LET cNombre1='';
LET cNombre2='';
LET cRazon='';
LET cTipopersona='';
LET cEstatusCli='ACTIVO';
LET cParticipacion='';
LET cTipocontrato='CONTRATO MULTIPLE PARA LA APERTURA DE CREDITOS PARA PERSONAS FISICAS';
LET dFecharelaccomer='';
LET dFechaApertura='';
LET dFechacancela='';
LET cGradoRiesgo='BAJO RIESGO';
LET dFechagradoriesgo='';
LET cNacionalidad='';
LET cPais='';
LET cProfesion='';
LET iNoRegs=0;
LET iNoRegs2=0;
LET iNoRegs3=0;
LET iNoRegs4=0;
LET cCuenta='';
LET cCuentaB='';
----
LET iNumerocalle    	=0;
LET    cNumeroextcalle 	='';
LET    cNumerointcalle 	='';
LET    iNumerocolonia  	=0;
LET    cCod_postal     	='';
LET    iNumerociudad   	=0;
LET    cCiudad         	='';
LET    cEstado         	='';

-------
LET    cTelefono1      ='';
LET    cTelefono2      ='';
LET    cTelefono3      ='';
LET    cTelefono4      ='';
LET stipo_tel=0;
LET cEmail='';
LET cCurp				='';
LET dFecha_nac			='';
LET cRFC='';
LET cSucursal					='';
LET cEjecutivo					='';
LET cNombreejecutivo ='';
LET cApoderado='';
LET cNumapoderado='';
LET cClientefirmante='';


---------------------------------------------
LET cProductoB='';
LET cPaternoB='';
LET cMaternoB='';
LET cNombre1B='';
LET cNombre2B='';
LET cRazonB='';
LET cTipopersonaB='';
LET cEstatusCliB='ACTIVO';
LET cParticipacionB='';
LET cTipocontratoB='CONTRATO MULTIPLE PARA LA APERTURA DE CREDITOS PARA PERSONAS FISICAS';
LET dFecharelaccomerB='';
LET dFechacancelaB='';
LET cGradoRiesgoB='BAJO RIESGO';
LET dFechagradoriesgoB='';
LET cNacionalidadB='';
LET cPaisB='';
LET cProfesionB='';
----
LET iNumerocalleB    	=0;
LET    cNumeroextcalleB 	='';
LET    cNumerointcalleB 	='';
LET    iNumerocoloniaB  	=0;
LET    cCod_postalB     	='';
LET    iNumerociudadB   	=0;
LET    cCiudadB         	='';
LET    cEstadoB         	='';

-------
LET    cTelefono1B      ='';
LET    cTelefono2B      ='';
LET    cTelefono3B      ='';
LET    cTelefono4B      ='';
LET stipo_telB=0;
LET cEmailB='';
LET cCurpB				='';
LET dFecha_nacB			='';
LET cRFCB='';
LET cSucursalB					='';
LET cEjecutivoB					='';
LET cNombreejecutivoB ='';
LET cApoderadoB='';
LET cNumapoderadoB='';
LET dFechaAperturaB='';

LET iContador = 0;
LET sCommit = 0;
LET sParamCta = '';
LET cCuentaCancel='';

--------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr 
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
			UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 451;
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/CNBV/sp_generainfo_ctes_cred.out";
    --TRACE ON;
	
	SELECT valor-1 INTO sParamCta FROM bdinteg:si_param WHERE cod_param = 451;

    FOREACH WITH HOLD
		
		SELECT num_credito,numcte,num_producto,fecha_apertura,sucursal,ejecutivo 
		INTO cCuenta, cNumcte,cProducto,dFechaApertura,cSucursal,cEjecutivo FROM bdicred:sd_maecred
		WHERE fecha_apertura <= '03/31/2017'  
        AND num_credito > sParamCta
		ORDER BY num_credito
			
		SELECT FIRST 1 b.fecha_can INTO dFechacancela FROM bdicred:sd_maecred a, bdicred:sd_cred_can b 
		WHERE a.num_credito=b.num_credito 
		and b.fecha_can <='03/31/2016' AND a.num_credito=cCuenta and a.status_cred='FF';	
		LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');
		
		IF(iNoRegs2>0)THEN
			CONTINUE FOREACH;
		END IF;

		SELECT apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
        INTO cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cRFC FROM si_cliente 
		WHERE numcte =cNumcte;

		SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
        INTO cNacionalidad,cPais,cProfesion,cCurp,dFecha_nac FROM si_ctepf 
		WHERE numcte =cNumcte;

		SELECT count(*) INTO iNoRegs3 FROM bdicred:sd_maecred WHERE numcte=cNumcte;

		--PARTICIPACION CONTRATO
		LET cParticipacion='TITULAR';
		----TIPO CONTRATO
		LET cTipocontrato='CONTRATO MULTIPLE PARA LA APERTURA DE CREDITOS PARA PERSONAS FISICAS';
		-----------------------
		--FECHA DE INCIIO DE RELACION COMERCIAL,CONTRATO Y GRADO DE RIESGO
		SELECT MIN(fecha_apertura) INTO dFecharelaccomer FROM bdicred:sd_maecred WHERE numcte=cNumcte;

			------FECHA DE TERMINO DE RELACION
		IF iNoRegs3=1 THEN
			LET dFechacancela='';
			SELECT FIRST 1 b.fecha_can INTO dFechacancela FROM bdicred:sd_maecred a, bdicred:sd_cred_can b WHERE a.num_credito=b.num_credito and a.num_credito=cCuenta and a.status_cred='FF';
			LET iNoRegs = DBINFO('sqlca.sqlerrd2');
			IF iNoRegs=1 THEN
				LET cEstatusCli='INACTIVO';
			ELSE
				LET cEstatusCli='ACTIVO';
			END IF;
		END IF;
		
		SELECT FIRST 1 numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado 
		INTO iNumerocalle,cNumeroextcalle,cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado  
		FROM si_direcciones_actual WHERE numcte=cNumcte AND tipo_dir=1;

		SELECT FIRST 1 telefono,tipo_tel INTO cTelefono1,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=1;
		SELECT FIRST 1 telefono,tipo_tel INTO cTelefono2,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=2;
		SELECT FIRST 1 telefono,tipo_tel INTO cTelefono3,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=3;


		SELECT FIRST 1 correo_elec INTO cEmail FROM si_correos WHERE numcte=cNumcte AND tipo_correo=1 AND status_correo='A';
		SELECT FIRST 1 nombre INTO cNombreejecutivo FROM si_ejecut WHERE ejecutivo=cEjecutivo;
			
		IF (sCommit = 0) THEN
				BEGIN WORK;
				LET iContador = 0;
				LET sCommit = -1;
		END IF;

		INSERT INTO si_infoctescnbv(numcte,cuenta,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
		fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
		telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
		VALUES (cNumcte,cCuenta,cProducto,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cEstatusCli,cParticipacion,cTipocontrato,dFecharelaccomer,
		dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidad,cPais,cProfesion,iNumerocalle,cNumeroextcalle,cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado,
		cTelefono1,cTelefono2,cTelefono3,cEmail,cCurp,dFecha_nac,cRFC,cSucursal,cEjecutivo,cNombreejecutivo,cApoderado);
			
		LET iContador = iContador  + 1;	

		IF (iContador >= 5000) THEN
				COMMIT WORK;	
				LET iContador = 0;
				UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 451;
				BEGIN WORK;
		END IF;	

			SET ISOLATION TO DIRTY READ;
			FOREACH d1 FOR
			
				SELECT numcte INTO cClientefirmante FROM bdicred:sd_tarjeta WHERE empresa='001' and num_credito=cCuenta AND tipo_tarjeta='A' AND status_tar='A'

				LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');

				IF iNoRegs2>0 THEN
					SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
					INTO cNumcte2,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cRFCB FROM si_cliente 
					WHERE numcte=cClientefirmante;

					SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
					INTO cNacionalidadB,cPaisB,cProfesionB,cCurpB,dFecha_nacB FROM si_ctepf 
					WHERE numcte =cClientefirmante;

					SELECT count(*) INTO iNoRegs3 FROM bdicred:sd_maecred WHERE numcte=cNumcte;

					--PARTICIPACION CONTRATO
					LET cParticipacionB='COTITULAR';
					----TIPO CONTRATO
					LET cTipocontratoB='CONTRATO MULTIPLE PARA LA APERTURA DE CREDITOS PARA PERSONAS FISICAS';
					-----------------------
	
					SELECT FIRST 1 numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado 
					INTO iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB  
					FROM si_direcciones_actual WHERE numcte=cNumcte2 AND tipo_dir=1;

					SELECT FIRST 1 telefono,tipo_tel INTO cTelefono1B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=1;
					SELECT FIRST 1 telefono,tipo_tel INTO cTelefono2B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=2;
					SELECT FIRST 1 telefono,tipo_tel INTO cTelefono3B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=3;

					SELECT FIRST 1 correo_elec INTO cEmailB FROM si_correos WHERE numcte=cNumcte2 AND tipo_correo=1 AND status_correo='A';
					SELECT FIRST 1 nombre INTO cNombreejecutivoB FROM si_ejecut WHERE ejecutivo=cEjecutivo;
							
					IF (sCommit = 0) THEN
						BEGIN WORK;
						LET iContador = 0;
						LET sCommit = -1;
					END IF;

					INSERT INTO si_infoctescnbv(numcte,cuenta,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
					fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
					telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
					VALUES (cNumcte2,cCuenta,cProducto,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cEstatusCli,cParticipacionB,cTipocontratoB,dFecharelaccomer,
					dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidadB,cPaisB,cProfesionB,iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB,
					cTelefono1B,cTelefono2B,cTelefono3B,cEmailB,cCurpB,dFecha_nacB,cRFCB,cSucursal,cEjecutivo,cNombreejecutivoB,cApoderado);
							
					LET iContador = iContador  + 1;		
				
					IF (iContador >= 5000) THEN
						COMMIT WORK;	
						LET iContador = 0;
						UPDATE bdinteg:si_param SET valor = cCuentaB WHERE cod_param = 451;
						BEGIN WORK;
					END IF;
							
					IF sCommit = -1 THEN
						COMMIT WORK;
						UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 451;							
					END IF;
					LET sCommit = 0;
				END IF;	

		END FOREACH;
    END FOREACH;

	IF sCommit = -1 THEN
	COMMIT WORK;
	UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 451;
	END IF;
	LET sCommit = 0;

    RETURN vc_CodRet;

END;
END PROCEDURE;