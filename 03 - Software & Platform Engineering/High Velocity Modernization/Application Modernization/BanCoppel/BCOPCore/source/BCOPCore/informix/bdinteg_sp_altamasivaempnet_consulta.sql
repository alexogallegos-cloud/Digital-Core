CREATE PROCEDURE "informix".sp_altamasivaempnet_consulta( pTipoCons CHAR(1), pNombreArchivo CHAR(30), pCodEmpresa CHAR(3), pNombre1 CHAR(30), pNombre2 CHAR(30), pApePaterno CHAR(30), pApeMaterno CHAR(30), pFechaIni DATE, pFechaFin DATE, pCtaEmpleado CHAR(20), pSecuencia INTEGER)
RETURNING CHAR(5) as vCodRet1,
		  CHAR(30) as vnombre_archivo,
		  CHAR(3) as vidEmpresa,
		  CHAR(15) as vcve_cte,
		  CHAR (30) as vNombre1,
		  CHAR (30) as vNombre2,
		  CHAR (30) as vape_pat,
		  CHAR (30) as vape_mat,
		  CHAR (15) as vrfc,
		  CHAR (20) as vcta_emp,
		  CHAR (9) as vnumcte_emp,
		  CHAR (1) as vStatus,
		  CHAR (1) as vActiva,
          CHAR (10) as vFechaRegistro;

	--****************************************************************************************************
	-- DESCRIPCION: Consulta de los archivos/Clientes generados atravez del Alta Masiva
	-- AUTOR : BanCoppel
	-- FECHA : 2013
	-- BD: bdinteg
	-- SOLICITO :Ismael Hernandez
	-- Modificó: Berenice Noriega
    --Modificó: Gustavo bujano Guzmán
    --Descripción: se permite hacern busquedas generales. tipo 5
	--****************************************************************************************************

	DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2			CHAR(5);
    DEFINE vCodRet3			CHAR(50);
    DEFINE vcNumEmp         CHAR(10);
    DEFINE vnombre1         CHAR(30);
    DEFINE vnombre2         CHAR(30);
    DEFINE vape_pat         CHAR(30);
    DEFINE vape_mat         CHAR(30);
	DEFINE vcta_emp			CHAR(20);
	DEFINE vnumcte_emp		CHAR(9);
	DEFINE vrfc				CHAR(15);
	DEFINE vStatus			CHAR(1);
	DEFINE vcve_cte			CHAR (15);
	DEFINE vidEmpresa		CHAR(3);
	DEFINE vnombre_archivo	CHAR(30);
	DEFINE vActiva			CHAR(1);
	DEFINE vArchivoExt1 	CHAR(18);
	DEFINE vArchivoExt2 	CHAR(18);
    DEFINE  vFechaRegistro  char(10);
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
	LET vCodRet2 = '';
	LET vCodRet3 = '';

    LET vcve_cte	= '';
	LET vnombre1    = '';
    LET vnombre2    = '';
    LET vape_pat    = '';
    LET vape_mat    = '';
	LET vrfc		= '';
	LET vcNumEmp = '';
	LET vcta_emp = '';
	LET vnumcte_emp = '';
	LET vStatus		= '';
	LET vidEmpresa	= '';
	LET vnombre_archivo = '';
	LET vActiva 	= '';
	LET vArchivoExt1 = '';
	LET vArchivoExt2 = '';
    LET vFechaRegistro ='';

  BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consulta.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_consulta.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;

   IF pTipoCons = 1 THEN  --por archivo
      
		IF TRIM(pNombreArchivo) <> '' AND TRIM(pCodEmpresa) <> '' THEN
		
			LET vArchivoExt1 = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 14)||'.txt';
			LET vArchivoExt2 = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 14)||'.dat';
		
			FOREACH WITH HOLD
				SELECT SKIP pSecuencia FIRST 15
				  cod_empresa, nombre_archivo,cve_cte, nombre1, nombre2, ape_pat, ape_mat, rfc, status, numcte, cuenta, fecha_registro
				INTO vidEmpresa, vnombre_archivo, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vrfc, vStatus, vnumcte_emp, vcta_emp, vFechaRegistro
				FROM "informix".si_altamasivaempnet_det
				WHERE TRIM(cod_empresa) = pCodEmpresa AND ( TRIM(nombre_archivo) = vArchivoExt1 OR TRIM(nombre_archivo) = vArchivoExt2 )

				SELECT NVL(marca_ret,'') INTO vActiva
				FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_emp;

				RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro WITH RESUME;

			END FOREACH;
		ELSE
			LET vCodRet1 = '00002'; -- el campo nombre de archivo no puede venir vacio
			RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
		END IF;

   ELIF pTipoCons = 2 THEN  --por nombre
		IF TRIM(pNombre1) <> '' AND TRIM(pApePaterno) <> ''  AND TRIM(pCodEmpresa) <> '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pSecuencia FIRST 15
				  cod_empresa, nombre_archivo,cve_cte, nombre1, nombre2, ape_pat, ape_mat, rfc, status, numcte, cuenta, fecha_registro
				INTO vidEmpresa, vnombre_archivo, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vrfc, vStatus, vnumcte_emp, vcta_emp, vFechaRegistro
				FROM "informix".si_altamasivaempnet_det
				WHERE TRIM(cod_empresa) = pCodEmpresa AND TRIM(nombre1) = TRIM(pNombre1) AND TRIM(ape_pat) = TRIM(pApePaterno)

				SELECT NVL(marca_ret,'') INTO vActiva
				FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_emp;

				RETURN vCodRet1,vnombre_archivo,vidEmpresa, vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro WITH RESUME;

			END FOREACH;
		ELSE
			LET vCodRet1 = '00003'; -- el nombre 1 y apellido paterno no pueden estar vacios
			RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
		END IF;

   ELIF pTipoCons = 3 THEN  --por fechas
		IF pFechaIni IS NOT NULL AND pFechaFin IS NOT NULL AND TRIM(pCodEmpresa) <> '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pSecuencia FIRST 15
				  cod_empresa, nombre_archivo,cve_cte, nombre1, nombre2, ape_pat, ape_mat, rfc, status, numcte, cuenta, fecha_registro
				INTO vidEmpresa, vnombre_archivo, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vrfc, vStatus, vnumcte_emp, vcta_emp,vFechaRegistro
				FROM "informix".si_altamasivaempnet_det
				--WHERE  TRIM(cod_empresa) = pCodEmpresa AND fecha_registro BETWEEN pFechaIni AND pFechaFin
				WHERE  TRIM(cod_empresa) = pCodEmpresa AND (fecha_registro >= pFechaIni AND fecha_registro <= pFechaFin)

				SELECT NVL(marca_ret,'') INTO vActiva
				FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_emp;

				RETURN vCodRet1,vnombre_archivo,vidEmpresa, vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro WITH RESUME;

			END FOREACH;
		ELSE
			LET vCodRet1 = '00003'; -- el nombre 1 y apellido paterno no pueden estar vacios
			RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
		END IF;

   ELIF pTipoCons = 4 THEN  --por cuenta empleado
		IF TRIM(pCtaEmpleado) <> '' AND TRIM(pCodEmpresa) <> '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pSecuencia FIRST 15
				  cod_empresa, nombre_archivo,cve_cte, nombre1, nombre2, ape_pat, ape_mat, rfc, status, numcte, cuenta, fecha_registro
				INTO vidEmpresa, vnombre_archivo, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vrfc, vStatus, vnumcte_emp, vcta_emp, vFechaRegistro
				FROM "informix".si_altamasivaempnet_det
				WHERE  TRIM(cod_empresa) = pCodEmpresa AND TRIM(cuenta) = pCtaEmpleado

				SELECT NVL(marca_ret,'') INTO vActiva
				FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_emp;

				RETURN vCodRet1,vnombre_archivo,vidEmpresa, vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro WITH RESUME;

			END FOREACH;
		ELSE
			LET vCodRet1 = '00004'; -- la cuenta no puede estar vacia
			RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
		END IF;
   ELIF pTipoCons = 5 THEN  --por todas las cuentas
		IF TRIM(pCodEmpresa) <> '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pSecuencia FIRST 15
				  cod_empresa, nombre_archivo,cve_cte, nombre1, nombre2, ape_pat, ape_mat, rfc, status, numcte, cuenta , fecha_registro
				INTO vidEmpresa, vnombre_archivo, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vrfc, vStatus, vnumcte_emp, vcta_emp, vFechaRegistro
				FROM "informix".si_altamasivaempnet_det
				WHERE  TRIM(cod_empresa) = pCodEmpresa 

				SELECT NVL(marca_ret,'') INTO vActiva
				FROM bdicheq:"informix".sc_maechq WHERE cuenta = vcta_emp;

				RETURN vCodRet1,vnombre_archivo,vidEmpresa, vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva , vFechaRegistro WITH RESUME;

			END FOREACH;
		ELSE
			LET vCodRet1 = '00005'; -- No existe información.
			RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva,vFechaRegistro;
		END IF;

   ELSE
		LET vCodRet1 = '00001'; -- el tipo de consulta no existe
		RETURN vCodRet1, vnombre_archivo, vidEmpresa,vcve_cte,vnombre1,vnombre2,vape_pat,vape_mat,vrfc,vcta_emp,vnumcte_emp,vStatus,vActiva, vFechaRegistro;
   END IF;

  END;

END PROCEDURE;