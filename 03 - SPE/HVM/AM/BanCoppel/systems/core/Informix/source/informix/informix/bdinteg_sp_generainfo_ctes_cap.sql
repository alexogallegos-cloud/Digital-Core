CREATE PROCEDURE "informix".sp_generainfo_ctes_cap() 
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
DEFINE cProductoB        CHAR(4);
DEFINE cPaternoB         CHAR(26);
DEFINE cMaternoB         CHAR(26);
DEFINE cNombre1B         CHAR(26);
DEFINE cNombre2B         CHAR(26);
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

DEFINE cEmailB					CHAR(100);
DEFINE cCurpB					CHAR(20);
DEFINE dFecha_nacB			DATE;
DEFINE cRFCB					CHAR(13);
DEFINE cSucursal					CHAR(4);
DEFINE cEjecutivo					CHAR(8);
DEFINE cNombreejecutivo			CHAR(45);
DEFINE cApoderado			CHAR(104);
DEFINE cNumapoderado			CHAR(20);
--------------------------------------------
DEFINE cSucursalB					CHAR(4);
DEFINE cEjecutivoB					CHAR(8);
DEFINE cNombreejecutivoB			CHAR(45);
DEFINE cApoderadoB			CHAR(104);
DEFINE cNumapoderadoB			CHAR(20);

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
LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
LET dFecharelaccomer='';
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
LET cTipocontratoB='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
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
LET dFechaApertura='';
LET dFechaAperturaB='';



--------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr 
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/CNBV/sp_generainfo_ctes_cap.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    FOREACH c1 FOR
		SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
        INTO cNumcte,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cRFC FROM si_cliente 
		WHERE fecha_insert between '04/01/2016' and '03/31/2017' and tipo_cliente=1

		SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
        INTO cNacionalidad,cPais,cProfesion,cCurp,dFecha_nac FROM si_ctepf 
		WHERE numcte =cNumcte;

		LET cEmail='';
		LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
		IF cTipopersona='MORAL' THEN
			SELECT fecha_constitct,giro,emailpm,nacionalidad INTO dFecha_nac,cProfesion,cEmail,cNacionalidad FROM si_ctepm WHERE numcte=cNumcte;
			
			SELECT FIRST 1 numcteapoderado INTO cNumapoderado FROM si_apoderado WHERE numcte=cNumcte;

			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) INTO cApoderado FROM si_cliente WHERE numcte=cNumapoderado;
			LET cTipocontrato='CONTRATO UNICO DE PRODUCTOS Y SERVICIOS BANCARIOS PARA EMPRESAS';
		END IF;
		

		FOREACH
			SELECT a.producto,a.cuenta,b.fecha_alta,a.sucursal,b.ejecutivo INTO cProducto,cCuenta,dFechaApertura,cSucursal,cEjecutivo FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
			WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte

			SELECT count(*) INTO iNoRegs3 FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
			WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;

			--PARTICIPACION CONTRATO
			LET cParticipacion='TITULAR';
			----TIPO CONTRATO

			-----------------------
			--FECHA DE INCIIO DE RELACION COMERCIAL,CONTRATO Y GRADO DE RIESGO
			SELECT MIN(B.fecha_alta) INTO dFecharelaccomer FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
			WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;


	------FECHA DE TERMINO DE RELACION
			IF iNoRegs3=1 THEN
				LET dFechacancela='';
				SELECT FIRST 1 fec_cancelac INTO dFechacancela FROM bdicheq:sc_maechq WHERE cuenta=cCuenta and status_cta=2;

				LET iNoRegs = DBINFO('sqlca.sqlerrd2');
				IF	iNoRegs>0 THEN	
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

			IF cEmail='' THEN
				SELECT FIRST 1 correo_elec INTO cEmail FROM si_correos WHERE numcte=cNumcte AND tipo_correo=1 AND status_correo='A';
			END IF;
			SELECT FIRST 1 nombre INTO cNombreejecutivo FROM si_ejecut WHERE ejecutivo=cEjecutivo;

			INSERT INTO si_infoctescnbv (numcte,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
			fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
			telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
			VALUES (cNumcte,cProducto,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cEstatusCli,cParticipacion,cTipocontrato,dFecharelaccomer,
			dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidad,cPais,cProfesion,iNumerocalle,cNumeroextcalle,cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado,
			cTelefono1,cTelefono2,cTelefono3,cEmail,cCurp,dFecha_nac,cRFC,cSucursal,cEjecutivo,cNombreejecutivo,cApoderado);
-----------------------------------------------------------------------------------

			SET ISOLATION TO DIRTY READ;
			FOREACH d1 FOR
			
				SELECT numcte INTO cClientefirmante FROM bdicheq:sc_firmantes WHERE empresa='001' and cuenta=cCuenta AND secuencia>1

				LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');

				IF iNoRegs2>0 THEN
				   FOREACH c1 FOR
						SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
						INTO cNumcte2,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cRFCB FROM si_cliente 
						WHERE numcte=cClientefirmante

						SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
						INTO cNacionalidadB,cPaisB,cProfesionB,cCurpB,dFecha_nacB FROM si_ctepf 
						WHERE numcte =cClientefirmante;

						LET cEmailB='';
						LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
						IF cTipopersona='MORAL' THEN
							SELECT fecha_constitct,giro,emailpm,nacionalidad INTO dFecha_nacB,cProfesionB,cEmailB,cNacionalidadB FROM si_ctepm WHERE numcte=cNumcte;

							SELECT FIRST 1 numcteapoderado INTO cNumapoderadoB FROM si_apoderado WHERE numcte=cNumcte;

							SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) INTO cApoderadoB FROM si_cliente WHERE numcte=cNumapoderado;
							LET cTipocontrato='CONTRATO UNICO DE PRODUCTOS Y SERVICIOS BANCARIOS PARA EMPRESAS';
						END IF;


						FOREACH
							SELECT a.producto,a.cuenta,b.fecha_alta,a.sucursal,b.ejecutivo INTO cProductoB,cCuentaB,dFechaAperturaB,cSucursalB,cEjecutivoB FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
							WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte and a.cuenta=cCuenta

							SELECT count(*) INTO iNoRegs3 FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
							WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte and a.cuenta=cCuenta;

							--PARTICIPACION CONTRATO
							LET cParticipacionB='COTITULAR';
							----TIPO CONTRATO

							-----------------------
							--FECHA DE INCIIO DE RELACION COMERCIAL,CONTRATO Y GRADO DE RIESGO
							SELECT MIN(B.fecha_alta) INTO dFecharelaccomerB FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
							WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;


					------FECHA DE TERMINO DE RELACION
							IF iNoRegs3=1 THEN
								LET dFechacancela='';
								--IF iNoRegs=1 THEN
								SELECT FIRST 1 fec_cancelac INTO dFechacancelaB FROM bdicheq:sc_maechq WHERE cuenta=cCuenta and status_cta=2;

								LET iNoRegs = DBINFO('sqlca.sqlerrd2');
								IF	iNoRegs>0 THEN	
									LET cEstatusCli='INACTIVO';
								ELSE
									LET cEstatusCli='ACTIVO';
								END IF;
							END IF;
							SELECT FIRST 1 numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado 
							INTO iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB  
							FROM si_direcciones_actual WHERE numcte=cNumcte2 AND tipo_dir=1;

							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono1B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=1;
							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono2B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=2;
							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono3B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=3;

							--IF cEmailB='' THEN

								SELECT FIRST 1 correo_elec INTO cEmailB FROM si_correos WHERE numcte=cNumcte2 AND tipo_correo=1 AND status_correo='A';
							--END IF;
							SELECT FIRST 1 nombre INTO cNombreejecutivoB FROM si_ejecut WHERE ejecutivo=cEjecutivo;

							INSERT INTO si_infoctescnbv (numcte,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
							fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
							telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
							VALUES (cNumcte2,cProductoB,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cEstatusCliB,cParticipacionB,cTipocontratoB,dFecharelaccomerB,
							dFechaAperturaB,dFechacancelaB,cGradoRiesgoB,dFechaAperturaB,cNacionalidadB,cPaisB,cProfesionB,iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB,
							cTelefono1B,cTelefono2B,cTelefono3B,cEmailB,cCurpB,dFecha_nacB,cRFCB,cSucursalB,cEjecutivoB,cNombreejecutivoB,cApoderadoB);
						END FOREACH;
					END FOREACH;
				END IF;	
			END FOREACH;
-----------------------------------------------------------------------------------

		END FOREACH;
    END FOREACH;

    RETURN vc_CodRet;

END;
END PROCEDURE;