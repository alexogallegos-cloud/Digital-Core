CREATE PROCEDURE "informix".sp_consultabenef_inver_web(pEmpresa CHAR(3), pCuenta CHAR(20),pOpcion CHAR(1))
	RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cNumcte, CHAR(104) AS cNombreCompleto, CHAR(1) AS cCodParentesco,CHAR(20) AS cDesParentesco, SMALLINT AS sPorcentaje;

	--DEFINICION DE VARIABLES
	DEFINE cCodRet  CHAR(5);
	DEFINE cNumcte CHAR(20);
	DEFINE cNombreCompleto CHAR(104);
	DEFINE cCodParentesco CHAR(1);
	DEFINE cDesParentesco CHAR(20);
	DEFINE sPorcentaje 	SMALLINT;
	DEFINE iSqlErr INTEGER;

	--INICIALIZACION DE VARIABLES 
	LET cCodret	= "00000";
	LET cNumCte ="";
	LET cNombreCompleto ="";
	LET cCodParentesco="";
	LET cDesParentesco="";
	LET sPorcentaje=0;
	LET iSqlErr = 0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultabenef_inver.out';
    --TRACE ON;
	
BEGIN
    
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
		END IF;
	END EXCEPTION;
	
	LET pCuenta = TRIM(pCuenta);
	LET pEmpresa = TRIM(pEmpresa);
	LET cNumcte = TRIM(cNumcte);
	LET cCodParentesco = TRIM(cCodParentesco);

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	IF NVL(pEmpresa,'')='' OR NVL(pCuenta,'') ='' OR TRIM(NVL(pOpcion,''))='' THEN
		LET cCodret = '00001'; --ParÃ¡metros de entrada vacÃ­os
		RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
	ELSE
	
		IF TRIM(NVL(pOpcion,''))='1' THEN
			FOREACH
				SELECT parentesco, porcentaje,numcte
				INTO   cCodParentesco,sPorcentaje,cNumcte
				FROM bdicheq:"informix".sc_beneficiario
				WHERE cuenta=(NVL(pCuenta,''))
				AND empresa=(NVL(pEmpresa,''))
				
				SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
				INTO cNombreCompleto
				FROM bdinteg:"informix".si_cliente
				WHERE numcte=(NVL(cNumcte,'')) 
				AND empresa=(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
				ELSE
					SELECT descripcion
					INTO cDesParentesco
					FROM bdinteg:"informix".si_parentesco
					WHERE parentesco= (NVL(cCodParentesco,''))
					AND empresa=(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '00002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
					END IF
				END IF
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
			END FOREACH;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
					RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
			END IF
		ELIF TRIM(NVL(pOpcion,''))='2' THEN
			FOREACH
				SELECT parentesco, porcentaje,numcte
				INTO   cCodParentesco,sPorcentaje,cNumcte
				FROM bdinvers:"informix".sv_benefic
				WHERE cuenta=(NVL(pCuenta,''))
				AND empresa=(NVL(pEmpresa,''))
		
				SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
				INTO cNombreCompleto
				FROM bdinteg:"informix".si_cliente
				WHERE numcte=(NVL(cNumcte,'')) 
				AND empresa=(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
				ELSE
					SELECT descripcion
					INTO cDesParentesco
					FROM bdinteg:"informix".si_parentesco
					WHERE parentesco= (NVL(cCodParentesco,''))
					AND empresa=(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '00002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
					END IF
				END IF
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '00002'; --No se encontraron registros
				LET cNumCte ="";
				LET cNombreCompleto ="";
				LET cCodParentesco="";
				LET cDesParentesco="";
				LET sPorcentaje=0;
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
			END IF
		END IF
	END IF
END
END PROCEDURE
DOCUMENT
"DescripciÃ³n: Consulta datos de los beneficiarios de una cuenta de InversiÃ³n Creciente o PagarÃ©",
"Autor : Leslie RendÃ³n",
"FECHA : 27/10/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_datoscte_ivr_web(pEmpresa CHAR(3),pNumCte CHAR(20))
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(110) AS NomCte,
				DATE AS	FechaNacimiento,
				CHAR(13) AS Telefono;


	DEFINE sCodRet   	CHAR(5);
	DEFINE iSqlErr  	INTEGER;
	DEFINE sNom1   		CHAR(26);
	DEFINE sNom2   		CHAR(26);
	DEFINE sApellPat   	CHAR(26);
	DEFINE sApellMat   	CHAR(26);
	DEFINE sNomCte   	CHAR(110);
	DEFINE sFechNac   	DATE;
	DEFINE sNumTel   	CHAR(13);

	LET sCodRet    	= '00000';
	LET iSqlErr  	= 0;
	LET sNom1    	= '';
	LET sNom2    	= '';
	LET sApellPat  	= '';
	LET sApellMat   = '';
	LET sNomCte    	= '';
	LET sFechNac   	= '';
	LET sNumTel    	= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET sCodRet = iSqlErr;
				RETURN sCodRet, TRIM(sNomCte), sFechNac, sNumTel;
			END IF;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/sp_datoscte_ivr.sql';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' THEN
			LET sCodRet='00001';
		ELSE
			SELECT NVL(cte.nombre1,''),NVL(cte.nombre2,''),NVL(cte.apell_paterno,''),NVL(cte.apell_materno,''), NVL(pf.fecha_nac,''), NVL(tel.telefono,'')
			INTO sNom1, sNom2, sApellPat, sApellMat, sFechNac, sNumTel
			FROM "informix".si_cliente cte, "informix".si_ctepf pf, "informix".si_telefonos tel
			WHERE cte.empresa = pEmpresa
			AND cte.empresa = tel.empresa
			AND cte.empresa = pf.empresa
			AND cte.numcte = TRIM(pNumCte)
			AND cte.numcte = pf.numcte
			AND cte.numcte = tel.numcte
			AND tel.status_tel = 'A'
			AND tel.tipo_tel = 1;
			
			IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
				LET sNomCte = TRIM(NVL(sNom1,''))||' '||TRIM(NVL(sNom2,''))||' '||TRIM(NVL(sApellPat,''))||' '||TRIM(NVL(sApellMat,''));
			END IF;			
		END IF;
		RETURN sCodRet, TRIM(NVL(sNomCte,0)), NVL(sFechNac,''), NVL(sNumTel,'');
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	29/DIC/2015',
'DESCRIPCION: Obtener los datos del cliente',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_guardacteprospecto_club_web
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplTitular		CHAR(20),
	pCteCplProspecto	CHAR(20)
)

	RETURNING
	CHAR(05) AS cCodRet

	--VARIABLES
	DEFINE vcCodRet		CHAR(05);
	DEFINE vcCteBanCpl	CHAR(20);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACIÃ?N
	LET vcCodRet	= '00000';
	LET vcCteBanCpl	= '';
	LET iSql_err 	= 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_guardacteprospecto_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARAMETROS VACIOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '00001';
			RETURN vcCodRet;
		END IF;
		
		--BUSQUEDA DE DATOS
		SELECT ctebancpl
		INTO vcCteBanCpl
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESA DATOS
		--IF DBINFO("sqlca.sqlerrd2") = 1 THEN
		IF TRIM(vcCteBanCpl) = '' OR vcCteBanCpl IS NULL THEN
			INSERT INTO "informix".si_club_hiscteprospecto(empresa, ctebancpl, ctecpltitular, ctecplprospecto)
			VALUES (pEmpresa, pCteBanCpl, pCteCplTitular, pCteCplProspecto);
			RETURN vcCodRet;
		ELSE
			LET vcCodRet = '00002';
			RETURN vcCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripcion:	Guarda la relacion del cliente bancoppel con el clinente Coppel titular y prospecto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_guardarhistcomphuellas_web(p_sNoEmpleado CHAR(8), p_sSucursal CHAR(4), p_sNoCteBancoppel CHAR(20), p_sTipoProducto CHAR(4))
RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;

	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 13-03-2009
	-- Guarda en la tabla bdinteg:si_histcomhuellas los datos los empleados que hayan 
	--	validado un cliente con su propia huella
	-- SET DEBUG FILE TO "/tmp/sp_guardarhistcomphuellas.out;
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg:si_histcomphuellas VALUES(p_sNoEmpleado, p_sSucursal, CURRENT, LPAD(TRIM(p_sNoCteBancoppel),9,'0'), p_sTipoProducto);
		RETURN '00000';
	END
END PROCEDURE;