CREATE PROCEDURE "informix".sp_generainfo_ctes_pais() 
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

    --SET DEBUG FILE TO "/informix/VH/CNBV/sp_generainfo_ctes_pais.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    FOREACH c1 FOR
		select numcte,TRIM(motivo_rechazo) INTO cNumcte, cPais from si_bitacoraapertura2017
		where id_pregunta=7 and respuesta<>'C'
		and numcte in (
		select distinct numcte from si_infoctescnbv where pais is null)
		
         

		SELECT FIRST 1 clave_pais,trim(nombre) INTO cPaisB,cNombre1B FROM bdinteg:si_paises WHERE pais in (
		SELECT case 
		when motivo_rechazo::int<10 then '00' || motivo_rechazo
		when motivo_rechazo::int between 10 and 99 then '0' || motivo_rechazo 
		else motivo_rechazo end as pais_codigo
		FROM bdinteg:si_bitacoraapertura2017 
		WHERE id_pregunta = '7' and respuesta <>'C' and numcte=cNumcte);
		
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		
		if iNoRegs=0 then
			SELECT FIRST 1 b.id_pais into cPais FROM si_paises a, si_paisnacion b where a.nombre=b.nombre and b.nombre=cNombre1B;
			LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');
			if iNoRegs2<>0 then
				UPDATE si_infoctescnbv SET pais=cNombre1B where numcte=cNumcte; 	
			else
				UPDATE si_infoctescnbv SET pais='MX'where numcte=cNumcte; 
			end if;
		else
			UPDATE si_infoctescnbv SET pais=cNombre1B where numcte=cNumcte; 	
		end if;



    END FOREACH;
	
	FOREACH c1 FOR
		select numcte,TRIM(motivo_rechazo) INTO cNumcte, cPais from si_bitacoraapertura
		where id_pregunta=7 and respuesta<>'C'
		and numcte in (
		select distinct numcte from si_infoctescnbv where pais is null)
		

		SELECT FIRST 1 clave_pais,trim(nombre) INTO cPaisB,cNombre1B FROM bdinteg:si_paises WHERE pais in (
		SELECT case 
		when motivo_rechazo::int<10 then '00' || motivo_rechazo
		when motivo_rechazo::int between 10 and 99 then '0' || motivo_rechazo 
		else motivo_rechazo end as pais_codigo
		FROM bdinteg:si_bitacoraapertura 
		WHERE id_pregunta = '7' and respuesta <>'C');
		
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		
		if iNoRegs=0 then
			SELECT FIRST 1 b.id_pais into cPais FROM si_paises a, si_paisnacion b where a.nombre=b.nombre and b.nombre=cNombre1B;
			LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');
			if iNoRegs2<>0 then
				UPDATE si_infoctescnbv SET pais=cNombre1B where numcte=cNumcte; 	
			else
				UPDATE si_infoctescnbv SET pais='MX'where numcte=cNumcte; 
			end if;
		else
			UPDATE si_infoctescnbv SET pais=cNombre1B where numcte=cNumcte; 	
		end if;

    END FOREACH;

    RETURN vc_CodRet;

END;
END PROCEDURE;