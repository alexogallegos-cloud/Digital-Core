CREATE PROCEDURE "informix".sp_consultacta_club(pEmpresa CHAR(3), pCliente CHAR(20), pPoliza CHAR(20),pCteCoppel CHAR(20))
RETURNING CHAR(6) as CodRet, CHAR(1) AS Domiciliada, CHAR(20) AS NumCta, CHAR(20) AS NumTarjeta, CHAR(4) AS SucOperante, CHAR(8) AS NumPromotor, CHAR(16) AS FolioOperacion, CHAR(1) AS Respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cDomiciliada CHAR(1);
DEFINE cNumCta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cSucOperante CHAR(4);
DEFINE cNumPromotor CHAR(8);
DEFINE cFolioOperacion CHAR(16);
DEFINE cTipoPago CHAR(1);
DEFINE dFecha DATETIME YEAR TO SECOND;
DEFINE cRespuesta CHAR(1);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;
LET cDomiciliada = '';
LET cNumCta='';
LET cNumTarjeta='';
LET cSucOperante='';
LET cNumPromotor='';
LET cFolioOperacion='';
LET cRespuesta='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacta_club.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pPoliza,''))='' THEN
			LET cCodret	= "000001";
		ELSE
			SELECT  MAX(fecha)
			INTO dFecha
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa;
			
			SELECT respuesta
			INTO cRespuesta
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa
			AND fecha=dFecha;
		
			SELECT suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,foliooperacion
			INTO cSucOperante,cNumPromotor,cTipoPago,cNumTarjeta,cNumCta,cFolioOperacion
			FROM  "informix".si_club_proteccion
			WHERE empresa= pEmpresa AND numcte=pCliente;
			--AND num_poliza= pPoliza;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
			ELSE
				IF TRIM(NVL(cTipoPago,''))='1' THEN
					LET cDomiciliada = 'S';
				ELSE 
					LET cDomiciliada = 'N';
					LET cNumCta='';
					LET cNumTarjeta='';
				END IF
			END IF
		END IF
		
RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
END
END PROCEDURE

DOCUMENT
"Descripción: Retorna la cuenta domiciliada para el Club de protección.",
"Autor : Leslie Rendón",
"FECHA : 07/07/2014",
"BD    : bdinteg",

'Descripción: Se comenta filtro num_poliza = pPoliza para que no se realice la comparacion en la tabla si_club_proteccion',
'Autor : Bryan Limon',
'FECHA : 16/05/2017',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_consctedetalle(cID_USUARIOC char(8),cID_FUNCIONC char(10),cnumcte char(20),cTPERSONA CHAR(6))
    RETURNING 	CHAR(5)  AS Cod_Retorno,  
				CHAR(20) AS Numero_Cliente, 
				CHAR(15) AS Nacionalidad, 
				CHAR(100) AS E_Mail, 
				CHAR(8)  AS Ejecutivo,  
				CHAR(1)  AS Cve_Domiciliacion,   
				CHAR(30) AS Desc_Domiciliacion, 
				CHAR(1)  AS Cve_BPI,  
				CHAR(30) AS Desc_BPI, 
				CHAR(1)  AS Cve_Pagos, 
				CHAR(30) AS Desc_Pagos,  
				CHAR(20) AS Estado_Civil,  
				CHAR(2)  AS Cve_Lugar_Nacimiento,  
				CHAR(18) AS FM3, 
				CHAR(20) AS CURP, 
				CHAR(30) AS Escolaridad, 
				CHAR(60) AS Profesion,
                CHAR(20) AS Cliente_Co, 
				CHAR(60) AS Puesto_PPES, 
				CHAR(45) AS Actividad_Especial, 
				CHAR(20) AS Familiar_PPES, 
				CHAR(60) AS Razon_Social, 
				CHAR(60) AS Sufijo,  
				CHAR(30) AS Pagina_Internet, 
				CHAR(40) AS Giro, 
				CHAR(45) AS Actividad_Social, 
				CHAR(48) AS Nombre_Titular, 
				CHAR(25) AS SAT_FEA, 
				CHAR(15) AS Telefono_Contacto,  
				CHAR(30) AS Escritura_Constitutiva, 
				CHAR(30) AS Nombre_Notario_CT, 
				CHAR(5)  AS Numero_Notario_CT,  
				CHAR(30) AS Ciudad_Notario_CT, 
				DATE     AS Fecha_Inscripcion_CT,
                DATE     AS Fecha_Contit_CT, 
				CHAR(30) AS Escritura_Poderes, 
				CHAR(30) AS Nombre_Notario_PD, 
				CHAR(5)  AS Numero_Notario_PD,  
				CHAR(30) AS Ciudad_Notario_PD, 
				DATE     AS Fecha_Inscripcion_PD, 
				CHAR(50) AS Nombre_Sociedad,  
				CHAR(4)  AS Sucursal, 
				DATE     AS Fecha_Alta,
				CHAR(30) AS Desc_Lugar_Nacimiento;
				
										
                

	--Variables en comun
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cNumeroCliente	CHAR(20);
	DEFINE cNacionalidad 	CHAR(15);
	DEFINE cCdomiciliacion	CHAR(1);
	DEFINE cDDomiliciacion	CHAR(30);
	DEFINE cCBPI			CHAR(1);
	DEFINE cDBPI			CHAR(30);
	DEFINE cCpagos			CHAR(1);
	DEFINE cDpagos			CHAR(30);
	DEFINE cTpo_persona 	CHAR(2);
	--VARIABLES CORREO ELECTRONICO
	DEFINE vcodret1         CHAR(3);
	DEFINE vtipocorreo      SMALLINT;
	DEFINE vstatuscorreo    CHAR(1);
	
	--Variables persona fisica 
	DEFINE cEstado_civil  	CHAR(20);
	DEFINE clugar_nac 		CHAR(2);
	DEFINE cNo_fm3 			CHAR(18);
	DEFINE cCurp			CHAR(20);
	DEFINE cEscolaridad 	CHAR(30);
	DEFINE cProfesion 		CHAR(60);
	DEFINE cEmail			CHAR(100);
	DEFINE cClienteCop		CHAR(20);
	DEFINE cEjecutivo		CHAR(8);
	DEFINE cPuesto_ppes		CHAR(2);
	DEFINE CDPuesto_ppes    CHAR(60);
	DEFINE cActividad_esp	CHAR(45);
	DEFINE cFamiliar_ppes	CHAR(20);

    --Variables persona moral
	DEFINE crazon_social		CHAR(60);
	DEFINE csufijo				CHAR(60);
	DEFINE cpagina_internet		CHAR(30);
	DEFINE cgiro				CHAR(40);
	DEFINE cDActividad_social 	CHAR(45);
	DEFINE cnombre_titular		CHAR(48);
	DEFINE csat_fea				CHAR(25);
	DEFINE ctelefono_contacto 	CHAR(15);
	DEFINE cemailpm				CHAR(100);
	DEFINE cescritura_constitutiva CHAR(30);
	DEFINE cnombre_notarioct	CHAR(30);
	DEFINE cnumero_notarioct	CHAR(5);
	DEFINE cciudad_notarioct	CHAR(30);
	DEFINE cfecha_inscrip		DATE;
	DEFINE cfecha_constitct		DATE;
	DEFINE cescritura_poderes	CHAR(30);
	DEFINE cnombre_notariopd	CHAR(30);
	DEFINE cnumero_notariopd	CHAR(5);
	DEFINE cciudad_notariopd	CHAR(30);
	DEFINE cfecha_inscrippd		DATE;
	DEFINE cnombre_sociedad		CHAR(50);	
	DEFINE cSucursal			CHAR(4);
	DEFINE dFecha_alta			DATE;
	DEFINE cEjecutivo_alta		CHAR(8);
	DEFINE iTpo_cliente			INT;
	DEFINE cNumCtePrincipal 	CHAR(20);
	DEFINE cDescLugarNacimiento CHAR(30);
	--Variables persona fisica 
	LET cEstado_civil = "";  	
	LET clugar_nac 	= "";
	LET cNo_fm3 		= "";
	LET cCurp			= "";
	LET cEscolaridad 	= "";
	LET cProfesion 		= "";
	LET cEmail			= "";
	LET cClienteCop		= "";
	LET cEjecutivo		= "";
	LET cPuesto_ppes	= "";
	LET cDPuesto_ppes	= "";
	LET cActividad_esp	= "";
	LET cFamiliar_ppes	= "";

    --Variables persona moral
	LET crazon_social		= "";
	LET csufijo				= "";
	LET cpagina_internet	= "";
	LET cgiro				= "";
	LET cDActividad_social 	= "";
	LET cnombre_titular		= "";
	LET csat_fea			= "";
	LET ctelefono_contacto 	= "";
	LET cemailpm			= "";
	LET cescritura_constitutiva = "";
	LET cnombre_notarioct	= "";
	LET cnumero_notarioct	= "";
	LET cciudad_notarioct	= "";
	LET cfecha_inscrip		= "";
	LET cfecha_constitct	= "";
	LET cescritura_poderes	= "";
	LET cnombre_notariopd	= "";
	LET cnumero_notariopd	= "";
	LET cciudad_notariopd	= "";
	LET cfecha_inscrippd	= "";
	LET cnombre_sociedad	= "";	
	LET cSucursal			= "";
	LET cEjecutivo_alta		= "";
	LET dFecha_alta			= "";
	
	--Variables en comun
	LET iexiste 		= 0;
	LET cCodRet 		= "00000";
	LET iSql_err 		= 0;
	LET cNumeroCliente	= "";
	LET cNacionalidad 	= "";
	LET cCdomiciliacion	= "";
	LET cDDomiliciacion	= "";
	LET cCBPI			= "";
	LET cDBPI			= "";
	LET cCpagos			= "";
	LET cDpagos			= "";
	LET cTpo_persona    = "";
	--VARIABLES CORREO ELECTRONICO
	LET vcodret1       = "";
	LET vtipocorreo    = 0;
	LET vstatuscorreo  = "";
	LET iTpo_cliente=0;
	LET cNumCtePrincipal = "";
	LET cDescLugarNacimiento="";
	
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;

            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consctedetalle.out";
		--TRACE ON;	
		IF 	cID_USUARIOC ='' 	OR 
			cID_FUNCIONC = '' 	OR 
			cNumcte = '' 		OR 
			cTPERSONA = '' 		THEN
			LET cCodRet = "00054";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;	
		END IF;		
		IF  cTPERSONA <>'MORAL' AND cTPERSONA <>'FISICA' THEN
			LET cCodRet = "00052";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;	
		END IF;
		
		--VALIDACION
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cnumcte,'11','2')
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN  cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
					cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
					cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
					cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;
		END IF;
	-- TERMINA VALIDACION		
	
--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

		FOREACH
		SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste  FROM si_cliente where numcte = cnumcte
		UNION
		SELECT NVL(COUNT(numcte_tf),0)  FROM bditransfer:tf_maecte where numcte_tf = cnumcte
		ORDER BY 1 DESC
		END FOREACH;		
--TRANSFER			
		IF iexiste = 0 THEN
			LET cCodRet = "00055";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;	
		END IF;
		SELECT NVL(COUNT(num_cte),0) INTO iexiste FROM bdidomi:dom_autorizaciones WHERE num_cte = cnumcte  and cve_estatus = '01';
		IF iexiste = 0 THEN
			LET cCdomiciliacion = "0";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		ELIF iexiste >=  1 THEN 
			LET cCdomiciliacion = "1";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		END IF	
		select NVL(COUNT(numcliente),0) INTO iexiste FROM  bdibpi:bpi_usuario WHERE numcliente = cnumcte AND st_portal='activo';
		IF iexiste = 0 THEN 
			LET cCBPI = '0';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCBPI = '1';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		END IF
		SELECT  NVL(COUNT(num_cte),0) INTO iexiste FROM  bdiprog:pp_pagoprog WHERE num_cte = cnumcte;
		IF iexiste = 0 THEN 
			LET cCpagos ='0';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCpagos ='1';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		END IF 
		--VERIFICA EXISTENCIA EN ctppes
		SELECT NVL(COUNT(numcte),0) INTO iexiste FROM informix.si_cteppes WHERE numcte = cnumcte;
		IF iexiste > 0 AND cTPERSONA ='FISICA' THEN 
			SELECT LIMIT 1 puesto_ppes
			INTO cPuesto_ppes
			FROM informix.si_cteppes			
			WHERE numcte = cnumcte
			AND numeroregistro = (SELECT max(numeroregistro) FROM informix.si_cteppes WHERE numcte = cnumcte);
			
		    SELECT descripcion 
			INTO cDPuesto_ppes
			FROM informix.si_puestosppes
			WHERE puesto_ppes = cPuesto_ppes;
			
			LET iexiste = 0;
		END IF
		SELECT tpo_persona INTO cTpo_persona FROM bdinteg:si_cliente where numcte =  cnumcte;
		IF cTPERSONA ='FISICA' THEN -- si el tipo de cliente es persona fisica	
			IF cTpo_persona = '01' THEN 
				SELECT LIMIT 1 CL.numcte,NA.descripcion,CF.estado_civil,CF.lugar_nac,CF.no_fm3,CF.curp,ES.descripcion,PR.descripcion,
					   CL.ejecutivo,AE.descripcion, PA.descripcion,CL.numcte_ref,EDO.NOMBRE
						
				INTO cNumeroCliente, cNacionalidad,	cEstado_civil,clugar_nac,cNo_fm3, cCurp, cEscolaridad,cProfesion, 
					 cEjecutivo_alta,cActividad_esp,cFamiliar_ppes,cClienteCop,cDescLugarNacimiento
						
				FROM si_cliente CL 
				LEFT JOIN si_ctepf CF
				ON CL.numcte = CF.numcte
				LEFT JOIN si_nacion NA
				ON NA.nacion = CF.nacionalidad
				LEFT JOIN si_escolaridad ES
				ON ES.escolaridad = CF.escolaridad
				LEFT JOIN si_profesion PR
				ON PR.profesion = CF.profesion
				LEFT JOIN si_actesp AE
				ON  AE.codigo = CL.actividad_esp
				LEFT JOIN si_parentesco PA
				ON PA.parentesco = CL.familiar_ppes
				LEFT JOIN bdinteg:si_estados EDO 
				ON EDO.ESTADO=CF.lugar_nac
				--LEFT JOIN bdisolic:ss_solicitudes SO
				--ON SO.numcte = CL.numcte
				WHERE CL.numcte = cnumcte; 
				IF cEstado_civil ='D' THEN
					LET cEstado_civil ='DIVORCIADO';
				END IF;
				IF cEstado_civil ='C' THEN
					LET cEstado_civil ='CASADO';
				END IF;
				IF cEstado_civil ='S' THEN
					LET cEstado_civil ='SOLTERO';
				END IF;
				IF cEstado_civil ='V' THEN
					LET cEstado_civil ='VIUDO';
				END IF;
				IF cEstado_civil ='U' THEN
					LET cEstado_civil ='UNION LIBRE';
				END IF;
                --BUSCA CORREO ELECTRONICO
				FOREACH
					EXECUTE PROCEDURE "informix".sp_consulta_correos('001',cnumcte,1,'0')
					INTO
					vcodret1,cEmail,vtipocorreo,vstatuscorreo
				END FOREACH;
				
                --SELECT LIMIT 1 nvl(co_numcte,'') INTO cClienteCop FROM bdisolic:ss_solicitudes WHERE numcte =cnumcte AND empresa='001' AND co_numcte is not null;

                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento with resume;
			ELIF cTpo_persona <> '01' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;	
			END IF		
		ELIF  cTPERSONA='MORAL' THEN -- si el cliente es de tipo moral 
			IF cTpo_persona ='02' THEN 
				SELECT {+INDEX (bdinteg:"informix".si_ctepm 461_1018)} CL.numcte,CL.razon_social,SU.descripcion, PM.nacionalidad,PM.pagina_internet,AC.nombre,SA.descripcion,
				PM.sat_fea,PM.telefono_contacto,PM.escritura_constitutiva,PM.nombre_notarioct,PM.numero_notarioct,PM.ciudad_notarioct,
				PM.fecha_inscrip, PM.fecha_constitct,PM.escritura_poderes,PM.nombre_notariopd,PM.numero_notariopd,PM.ciudad_notariopd,
				PM.fecha_inscrippd,PM.nombre_sociedad,PM.sucursal,CL.ejecutivo,CL.fecha_alta
				INTO
				cNumeroCliente,crazon_social,csufijo,cNacionalidad,cpagina_internet,cgiro,cDActividad_social,csat_fea,ctelefono_contacto,cescritura_constitutiva,
					cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip, cfecha_constitct,cescritura_poderes,cnombre_notariopd,cnumero_notariopd,
					cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,cEjecutivo_alta,dFecha_alta
				FROM si_cliente CL
				LEFT JOIN si_ctepm PM
				ON PM.numcte = CL.numcte
				LEFT JOIN si_sufijos SU
				ON SU.codigo=PM.sufijo
				LEFT JOIN si_actecon AC
				ON AC.actividad = SUBSTRING(PM.giro FROM 1 FOR 3)
				LEFT JOIN si_actividadsocial SA
				ON SA.codigo = PM.actividadsocial
				WHERE  PM.numcte = cnumcte;

                IF LENGTH(cNacionalidad)=1 THEN
                    LET cNacionalidad='00'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=2 THEN
                    LET cNacionalidad='0'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=3 THEN
                    LET cNacionalidad=TRIM(cNacionalidad);
                ELSE
                    LET cNacionalidad='025';
                END IF;
                				
                SELECT descripcion INTO cNacionalidad FROM si_nacion
                WHERE nacion=cNacionalidad;
				
				SELECT nombreapoderado
				INTO cnombre_titular
				FROM si_apoderado
				WHERE empresa = '001' 
				AND numcte = cnumcte
				AND secuencia = 1;
				
				SELECT correo_elec
				INTO cEmail
				FROM si_correos
				WHERE numcte = cnumcte 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cnumcte);
								
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento with resume;
			ELIF cTpo_persona <> '02' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;	
			END IF			
		END IF
		IF 	cTpo_persona IS NULL THEN 
			RETURN 
			cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
            cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
            cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
            cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento;
		END IF
    END
END PROCEDURE
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp hara una busqueda de los datos del cliente dependiendo si es persona fisica o moral, evalura el numero de cliente y dependiendo del tipo cliente",
"haga la busqueda ya sea persona fisica o moral y regrese los valores correspondientes",
"FECHA : 09-01-2012",
"BD    : bdinteg",
"VER   : 1.0",
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 03/10/2016',
'DESCRIPCION: Se actualiza para extraer EL correo electronico de la tabla si_correos para Persona Moral',
'ID REQUERIMIENTO TASF: CON-01-03-03-B-0449',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/05/2017',
'MODIFICACIÓN: Se agrega campo de retorno cDescLugarNacimiento';

CREATE PROCEDURE "informix".sp_archivo_respuesta_tel(pFechaHoy DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cSql              CHAR(2024);
DEFINE cRuta			 CHAR(100);
DEFINE cNombre           CHAR(100);
DEFINE cNum_cte          CHAR(20);
DEFINE cNumeroTelefono   CHAR(10);
DEFINE cTipoTelefono     CHAR(1);

LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cSql                 = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "Se realizó la actualización correctamente";
LET cRuta				 = "";
LET cNombre			     = "";
LET cNum_cte          	 = '';
LET cNumeroTelefono   	 = '';
LET cTipoTelefono     	 = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN 
     LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_archivo_respuesta_tel.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- obtener el nombre con el que se encuentra el archivo de respuesta de Telefonos
	SELECT valor 
	INTO cNombre 
	FROM bdisolic:ss_param 
	WHERE secuencia = 379;
-- obtener la ruta donde se almacenará el archivo de respuesta de Telefonos	
	SELECT valor 
	INTO cRuta
	FROM bdisolic:ss_param 
	WHERE secuencia = 380;

	LET pFechaHoy = pFechaHoy-1;
	LET cNombre = TRIM(cNombre) || lpad(day(pFechaHoy),2,'0') || lpad(month(pFechaHoy),2,'0') || year(pFechaHoy) ||'.txt';

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM SYSTABLES WHERE tabname = 'busca_archivo') THEN	
		DROP TABLE "informix".busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE "informix".busca_archivo
	( archivo CHAR(50));	

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.unl
	LET cSql = "";
	LET cSql = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'buscar.unl';
	SYSTEM cSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSql = "";
	LET cSql = 'echo "LOAD FROM ' || TRIM(cRuta) || 'buscar.unl' || ' INSERT INTO busca_archivo" > '|| TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSql = "";
	LET cSql = 'dbaccess bdinteg ' || TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	LET cSql = "";
	LET cSQL = "rm " ||TRIM(cRuta)||'Ejecuta_BuscarArchivo.sql';		
	SYSTEM cSql; 
	
	LET cSql = "";
	LET cSQL = "rm " ||TRIM(cRuta)||'buscar.unl';		
	SYSTEM cSql; 
			
	IF EXISTS (SELECT archivo FROM "informix".busca_archivo where archivo = TRIM(cNombre)) THEN
			-- para cargar el archivo insertandolo en la tabla bdinteg:si_respuesta_tel
			-- delete from bdinteg:si_respuesta_tel;
			LET cSql = "";
			LET cSql = 'echo "load from ' || TRIM(cRuta)||TRIM(cNombre)|| ' INSERT INTO si_respuesta_tel (cliente,telefono,estatus ,tipotelefono ,tipored ,horainicio ,numempleado ,flagenviado)  " > '|| TRIM(cRuta)||'archivoinsert.sql';
			SYSTEM cSql;	  
			LET cSql = '';
			LET cSql = "dbaccess bdinteg " ||TRIM(cRuta)||'archivoinsert.sql';
		    SYSTEM cSql;
			--falta borrar los temporales
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'archivoinsert.sql';		
	        SYSTEM cSql; 
			
		    LET cCodRet = "000000";
		    LET cSql    = "";
			
			UPDATE "informix".si_respuesta_tel
			SET nombre_archivo = cNombre
			WHERE nombre_archivo is null;
			
			FOREACH
				--Se actualiza la información del archivo de respuesta de Telefonos a la tabla de respuestas
				SELECT LPAD(TRIM(cliente),9,'0'),telefono,tipotelefono 
				INTO cNum_cte,cNumeroTelefono,cTipoTelefono
				FROM "informix".si_respuesta_tel
				WHERE nombre_archivo = TRIM(cNombre)
					
				IF EXISTS (select numcte from bdinteg:"informix".si_telefonos where numcte = cNum_cte AND telefono = cNumeroTelefono AND tipo_tel=cTipoTelefono AND status_tel='A') THEN 
					--update a bdinteg:si_telefonos 
					UPDATE bdinteg:"informix".si_telefonos 
					   SET verificado  = 'V'
					 WHERE numcte = cNum_cte
					 AND telefono = cNumeroTelefono
					 AND tipo_tel = cTipoTelefono
					 AND status_tel ='A';
				END IF;
			END FOREACH;
					
			DROP TABLE "informix".busca_archivo;
	ELSE
			DROP TABLE "informix".busca_archivo;
	--Se elimina por si tiene que procesar varios archivos y si alguno no existe, no se pare el proceso
			LET cCodRet     = "000015";
		    LET cMensajeRet = "No se encontro el archivo en la ruta indicada";
			RETURN cCodRet, cMensajeRet;
	END IF	
    IF cNombre IS NULL OR cNombre = '' THEN
        LET cCodRet     = "000001";
		LET cMensajeRet = "No se tiene archivo de respuesta a procesar";
		RETURN cCodRet, cMensajeRet;
	END IF
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar a la tabla',
'bdinteg:si_telefonos el campo verificado a "V" de los ',
'telefonos que se recibieron en el archivo de respuesta ',
' /respaldos/',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 11/DICIEMBRE/2015',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_actualiza_clubproteccion(pCliente CHAR(20))

RETURNING CHAR(5) AS codRet;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE dtFechaHoy DATE;

--INICIALIZACION DE VARIABLES
LET cCodret	= "00000";
LET iSqlErr = 0;

--SET DEBUG FILE TO '/home/sysifx/Bryan/137/sp_actualiza_clubproteccion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	IF TRIM(NVL(pCliente,''))='' THEN
		LET cCodret	= "00001";
	ELSE
		SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas;
		
		UPDATE  bdinteg: "informix".si_ctesavencer SET pagado = 1, fecha_pago = CURRENT WHERE numcte_banco = TRIM(pCliente) AND pagado = 0;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 then
            LET cCodret	= "00002";
            RETURN cCodret;
		END IF
		
	END IF;
	
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'Folio: 137 Consulta saldos para Club de proteccion familiar.',
'Autor: Bryan Limon',
'BD: bdinteg',
'Fecha: 03/11/2016',
'DescripciÃ³n: ACTUALIZARA LA BANDERA DE PAGADO Y LA FECHA EN QUE SE PAGO EN LA TABLA SI_CTESAVENCER'
;

CREATE PROCEDURE "informix".sp_cons_correo_celular(pempresa char(3), pnumcte char(20))
--DATOS A REGRESAR---
RETURNING
CHAR(5),     -- Código de retorno
CHAR(100),   -- Cuenta de Correo
CHAR(13),    -- Telefono Celular
CHAR(02);    -- Carrier

--DEFINICION DE VARIABLES--
DEFINE iSql_Err 		INTEGER;
DEFINE iLongitud        SMALLINT;
DEFINE iCarrier         SMALLINT;
DEFINE iTipo            SMALLINT;
DEFINE cSecuencia 		SMALLINT;
DEFINE iStatusValidacion SMALLINT;
DEFINE cCorreo          CHAR(100);
DEFINE cCelular         CHAR(13);
DEFINE cCarrier         CHAR(2);
DEFINE cCod_Ret 		CHAR(5);
DEFINE cStatus  		CHAR(1);
DEFINE cTipoTel 		CHAR(1);
DEFINE cStatus_Tel 		CHAR(1);
DEFINE cExtension 		CHAR(5);
DEFINE cNombreCarrier 	CHAR(20);

--INICIALIZACION DE VARIABLES--
LET cCod_Ret         = "00000";
LET cCorreo          = "";
LET cCelular         = "";
LET cCarrier         = "";
LET iCarrier         = 0;

--  SET DEBUG FILE TO "/tmp/sp_cons_correo_celular.out";
--  TRACE ON;

set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

-- INICIO DEL PROCEDIMIENTO
BEGIN
  -- MANEJADOR DE ERRORES
  ON EXCEPTION SET iSql_Err
     IF iSql_Err <> 0 THEN
   	     LET cCod_Ret = iSql_Err;
	     RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET cCod_Ret = "00001";
	LET cCorreo = 'Parámetros incompletos';
	RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
END IF;

SET ISOLATION TO DIRTY READ;
-- Recupera Cuenat de Correo Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_correos(pEmpresa, pNumCte, 1, 0)
INTO cCod_Ret, cCorreo, iTipo, cStatus;
-- Recupera Telefono Celular Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_telefonos(pEmpresa, pNumCte, 2, 0)
INTO cCod_Ret, cCelular, cTipoTel, cSecuencia, cStatus_Tel, cExtension, iCarrier, cNombreCarrier, iStatusValidacion;

LET cCarrier =  LPAD(NVL(iCarrier,0),2,'0');

RETURN LPAD(TRIM(cCod_Ret), 5,'0'), cCorreo, cCelular, cCarrier;
END;
END PROCEDURE
DOCUMENT
'Consulta Cuenta de Correo y Telefono Celular',
'AUTOR : Jaime González',
'FECHA : 02/Marzo/2012',
'Ver.  : 1.0',
'BD    : bdinteg';

CREATE PROCEDURE  "informix".sp_llena_ctes_infosat()
       returning CHAR(5)  AS Cod_Retorno;

DEFINE vcodret     CHAR(5);
DEFINE vsqlerr     INTEGER;
DEFINE ultcte      CHAR(9);
DEFINE iContador   INTEGER;
DEFINE sCommit     SMALLINT;
DEFINE sEmpresa    CHAR(3);
DEFINE sNumcte     CHAR(20); 


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

LET vcodret="00000";
LET ultcte='';
LET iContador = 0;
LET sCommit = 0;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/informix/OMC/sp_llena_ctes_infosat.out";
--TRACE ON;

            --Obteniendo el ultimo cliente generado con la info para el SAT
			  SELECT valor INTO ultcte
			  FROM si_param WHERE empresa='001' AND cod_param='139';	
			  
            --Obteniendo los registros de clientes ordenados
            SET ISOLATION TO DIRTY READ;
            FOREACH WITH HOLD
                SELECT LIMIT 1000000  empresa, numcte
				INTO sEmpresa, sNumcte
                FROM bdinteg:si_cliente
                WHERE empresa='001' AND tpo_persona='01'
                AND tipo_cliente='1' AND numcte >ultcte ORDER BY numcte
                

            --Llenando la tabla de control
                
                IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iContador = 0;
					LET sCommit = -1;
                END IF;
                
                INSERT INTO si_ctessat(empresa, numcte,estatus_proc)
                VALUES(sEmpresa, sNumcte, 0);

				LET iContador = iContador  + 1;	
				
                --Ejecutar un commit cada 10000 registros.
                IF (iContador >= 10000) THEN
                    COMMIT WORK;	
                    LET iContador = 0;				
                    BEGIN WORK;
                END IF;	
			END FOREACH;

            IF sCommit = -1 THEN
            	COMMIT WORK;                
            END IF;
            LET sCommit = 0;
			
END;
return vcodret;   
END PROCEDURE;