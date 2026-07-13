CREATE PROCEDURE "informix".sp_generainfo_ctesmoral_cred() 
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
DEFINE cFechaConstitucion       DATE;
-------------------------------------------
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

LET cFechaConstitucion='';

LET iContador = 0;
LET sCommit = 0;
LET sParamCta = '';


--------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr 
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
			UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 452;
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/OMC/sp_generainfo_ctesmoral_cred.out";
    --TRACE ON;
	
	SELECT valor-1 INTO sParamCta FROM bdinteg:si_param WHERE cod_param = 452;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
	SELECT b.cliente_institucion,b.credito,b.num_producto, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.razon_social,
	a.tipo_persona, a.status_cliente, a.participacion, a.tipo_contrato, a.fec_inicio_relac, b.fecha_nacimiento_constitucion,
	b.fecha_apertura_credito, b.fecha_cierre, a.grado_riesgo, a.nacionalidad, a.pais, a.actividad, a.numerocalle, a.numeroextcalle, 
	a.numerointcalle, a.numerocolonia, a.cod_postal, a.numerociudad, a.ciudad, a.estado, 
	a.telefono1, a.telefono2, a.telefono3, a.email, a.curp, a.fecha_nac, a.rfc, a.sucursal, a.ejecutivo, a.nombre_ejecutivo, a.apoderado_legal 
	INTO cNumcte,cCuenta,cProducto,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,
	cTipopersona,cEstatusCli,cParticipacion,cTipocontrato,dFecharelaccomer, cFechaConstitucion,
	dFechaApertura,dFechacancela,cGradoRiesgo,cNacionalidad,cPais,cProfesion,iNumerocalle,cNumeroextcalle,
	cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado,
	cTelefono1,cTelefono2,cTelefono3,cEmail,cCurp,dFecha_nac,cRFC,cSucursal,cEjecutivo,cNombreejecutivo,cApoderado
	FROM bdinteg:si_infoctescnbv a INNER JOIN bdinteg:si_infoctescnbv_cred b
	ON a.numcte = b.cliente_institucion
	WHERE b.credito > sParamCta
	order by b.credito
	
	IF dFecharelaccomer < cFechaConstitucion THEN
		LET dFecharelaccomer = dFecharelaccomer;
		ELSE
		LET dFecharelaccomer = cFechaConstitucion;
    END IF;
	
	IF (sCommit = 0) THEN
		BEGIN WORK;
		LET iContador = 0;
		LET sCommit = -1;
	END IF;
		
		INSERT INTO si_infoctescnbv(numcte,cuenta,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
		fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,
		numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
		telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
		VALUES (cNumcte,cCuenta,cProducto,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,
		cTipopersona,cEstatusCli,cParticipacion,cTipocontrato,dFecharelaccomer, 
		dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidad,cPais,cProfesion,iNumerocalle,cNumeroextcalle,
		cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado,
		cTelefono1,cTelefono2,cTelefono3,cEmail,cCurp,dFecha_nac,cRFC,cSucursal,cEjecutivo,cNombreejecutivo,cApoderado);
		
		LET iContador = iContador  + 1;	

			--Ejecutar un commit cada 1000 registros.
			IF (iContador >= 5000) THEN
				COMMIT WORK;	
				LET iContador = 0;
				UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 452;
				BEGIN WORK;
			END IF;	
			
	END FOREACH;
	
	IF sCommit = -1 THEN
		COMMIT WORK;
		UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 452;							
		END IF;
	LET sCommit = 0;
	
	RETURN vc_CodRet;
	
	END;
END PROCEDURE;