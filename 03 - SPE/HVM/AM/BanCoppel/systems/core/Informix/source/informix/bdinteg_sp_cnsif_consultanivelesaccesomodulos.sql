CREATE PROCEDURE "informix".sp_cnsif_consultanivelesaccesomodulos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdUsuarioC CHAR(8))
        RETURNING CHAR(5) AS codret,
                        CHAR(6) AS idmodulo,
                        SMALLINT AS nivel_acceso;
                        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNivelAcceso SMALLINT;
        DEFINE cIdModulo CHAR(6);
        DEFINE iExiste SMALLINT;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNivelAcceso = 0;
        LET cIdModulo = '';
        LET iExiste = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cIdModulo, iNivelAcceso;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consultanivelesaccesomodulos.out';
                --TRACE ON;
                
                IF pIdUsuario = '' OR pIdFuncion = '' OR pIdUsuarioC = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cIdModulo, iNivelAcceso;
                END IF;
                
                -- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE "informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cIdModulo, iNivelAcceso;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                -- Buscamos si el usuario esta en la tabla de accesos por modulo
                SELECT count(id_usuario)
                INTO iExiste
                FROM bdinteg:si_seg_nivel_acceso_modulo
                WHERE id_usuario = pIdUsuarioC;
                
                IF iExiste = 0 THEN
                        LET cCodRet = '00030';
                        RETURN cCodRet, cIdModulo, iNivelAcceso;
                END IF;
                
                FOREACH 
                        SELECT a.id_modulo, NVL(b.nivel_acceso, 0)
                        INTO cIdModulo, iNivelAcceso
                        FROM bdinteg:si_seg_modulos a LEFT JOIN bdinteg:si_seg_nivel_acceso_modulo b
                                ON b.id_modulo = a.id_modulo AND b.id_usuario = pIdUsuarioC
                        WHERE a.id_modulo NOT IN ('MOD100')
                        ORDER by a.id_modulo
                        
                        RETURN cCodRet, cIdModulo, iNivelAcceso WITH RESUME;
                        
                END FOREACH;

        
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Consulta los niveles de acceso por modulos para un usuario",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_cnsif_ideconstancias(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cPERIODO CHAR(06))

			returning   CHAR(5)     AS Cod_Retorno,
						CHAR(20)    AS Folio,
						CHAR(02)    AS Mes,
						CHAR(04)    AS Ejercicio,
						CHAR(13)    AS RFC,
						CHAR(20)    AS Curp,
						CHAR(26)    AS Apellido_Paterno,
						CHAR(26)    AS Apellido_Materno,
						CHAR(26)    AS Nombre_1,
						CHAR(26)    AS Nombre_2,
						CHAR(60)    AS Razon_Social,
						CHAR(13)    AS RFC_Institucion,
						CHAR(60)    AS Razon_Social_Institucion,
						MONEY(16,2) AS monto_Excedente_IDE,
						MONEY(16,2) AS Monto_Impuesto_Determinado,
						MONEY(16,2) AS Monto_Impuesto_Reca,
						MONEY(16,2) AS Monto_Impuesto_Pend_Reca,
						MONEY(16,2) AS Monto_Remanente_Per_Ant,
						MONEY(16,2) AS Tipo_Cambio;

DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;


DEFINE v_cod_ret    		   CHAR(5);
DEFINE cRfccontribuyente  	   CHAR(13);
DEFINE cCurpcopntribuyente     CHAR(20);
DEFINE cApellpaterno    	   CHAR(26);
DEFINE cApellmaterno           CHAR(26);
DEFINE cNombre1           	   CHAR(26);
DEFINE cNombre2                CHAR(26);
DEFINE cRazoncontribuyente 	   CHAR(60);
DEFINE cRfcinstitucion 		   CHAR(13);
DEFINE cRazoninstitucion 	   CHAR(60);
DEFINE mImpacumulado           MONEY(16,2);
DEFINE mImparecaudar 		   MONEY(16,2);
DEFINE mImprecaudado 		   MONEY(16,2);
DEFINE mImppendiente 		   MONEY(16,2);
DEFINE mImpremanente 		   MONEY(16,2);
DEFINE mTipocambio 			   CHAR(2);
DEFINE cFolio                  CHAR(20);
DEFINE cEjercicio              CHAR(04);
DEFINE cMes                    CHAR(02);

DEFINE mTotalDepositos  	   MONEY(16,2);
DEFINE mMontoExcedente   	   MONEY(16,2);
DEFINE mImpuestoDeterminado    MONEY(16,2);

DEFINE mImpRemPerAnt           MONEY(16,2);
DEFINE cSufijo                    CHAR(60);

LET  v_cod_ret   			 = "00000";
LET cRfccontribuyente     = '';
LET cCurpcopntribuyente   = '';
LET cApellpaterno         = '';
LET cApellmaterno         = '';
LET cNombre1              = '';
LET cNombre2              = '';
LET cRazoncontribuyente   = "";
LET cRfcinstitucion 	  = "";
LET cRazoninstitucion	  = "";
LET mImpacumulado		  = 0;
LET mImparecaudar 		  = 0;
LET mImprecaudado  		  = 0;
LET mImppendiente 		  = 0;
LET mImpremanente 		  = 0;
LET mTipocambio 		  = "01";
LET cFolio                = '';
LET cEjercicio            = '';
LET cMes                  = '';
LET cSufijo				  = '';

LET mTotalDepositos  		= 0;
LET mMontoExcedente     	= 0;
LET mImpuestoDeterminado    = 0;

LET mImpRemPerAnt           = 0;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cFolio,cMes,cEjercicio,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
				   cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImppendiente,mImprecaudado,mImparecaudar,mImpremanente,mTipocambio;
		END IF
	END EXCEPTION

	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_ideconstancias.out";
	--	TRACE ON;

	IF 	cID_USUARIOC  = '' 	OR
		cID_FUNCIONC  = '' 	OR
		cNUMCLIENTE   = ''	OR
		cPERIODO      = ''  THEN
		LET cCodRet = "00060";
		RETURN cCodRet,cFolio,cMes,cEjercicio,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
			   cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImppendiente,mImprecaudado,mImparecaudar,mImpremanente,mTipocambio;
	END IF

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'23','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,cFolio,cMes,cEjercicio,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
			   cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImppendiente,mImprecaudado,mImparecaudar,mImpremanente,mTipocambio;
	END IF;
	-- TERMINA VALIDACION


	SELECT NVL(COUNT(numcte),0)	INTO iexiste FROM bdinteg:si_cliente WHERE numcte  = cNUMCLIENTE;
	IF iexiste  = 0 THEN
		LET cCodRet = "00062";
		RETURN cCodRet,cFolio,cMes,cEjercicio,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
			   cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImppendiente,mImprecaudado,mImparecaudar,mImpremanente,mTipocambio;
	END IF

	SET ISOLATION TO DIRTY READ;

	EXECUTE PROCEDURE bdilide:sp_ideconstancias(1, cNUMCLIENTE, cPERIODO)
	INTO
	v_cod_ret,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
	cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImparecaudar,mImprecaudado,mImppendiente,mImpremanente,mTipocambio,cFolio,cSufijo;

	IF LENGTH(v_cod_ret) = 3 THEN
		LET  cCodRet = '00' || v_cod_ret;
	ELIF LENGTH(v_cod_ret) = 5 THEN
		LET  cCodRet = v_cod_ret;
	END IF

	LET  cMes = SUBSTR(cPERIODO,5,2);

	LET  cEjercicio = SUBSTR(cPERIODO,1,4);


	RETURN 	cCodRet,cFolio,cMes,cEjercicio,cRfccontribuyente,cCurpcopntribuyente,cApellpaterno,cApellmaterno,cNombre1,cNombre2,cRazoncontribuyente,
				cRfcinstitucion,cRazoninstitucion,mImpacumulado,mImparecaudar,mImprecaudado,mImppendiente,mImpremanente,'0.00';

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener los datos necesarios para la Constancia de Recaudación de LIDE. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Folio.",
"FECHA : 16-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultabenef_inver(pEmpresa CHAR(3), pCuenta CHAR(20),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet, CHAR(20) AS cNumcte, CHAR(104) AS cNombreCompleto, CHAR(1) AS cCodParentesco,CHAR(20) AS cDesParentesco, SMALLINT AS sPorcentaje;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cNumcte CHAR(20);
DEFINE cNombreCompleto CHAR(104);
DEFINE cCodParentesco CHAR(1);
DEFINE cDesParentesco CHAR(20);
DEFINE sPorcentaje 	SMALLINT;
DEFINE iSqlErr INTEGER;

--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
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

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCuenta,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
			RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
		ELSE
		
			IF TRIM(NVL(pOpcion,''))='1' THEN
				FOREACH
					SELECT parentesco, porcentaje,numcte
					INTO   cCodParentesco,sPorcentaje,cNumcte
					FROM bdicheq:"informix".sc_beneficiario
					WHERE cuenta=TRIM(NVL(pCuenta,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					
						SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
						INTO cNombreCompleto
						FROM bdinteg:"informix".si_cliente
						WHERE numcte=TRIM(NVL(cNumcte,'')) 
						AND empresa=TRIM(NVL(pEmpresa,''));
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '000002'; --No se encontraron registros
							LET cNumCte ="";
							LET cNombreCompleto ="";
							LET cCodParentesco="";
							LET cDesParentesco="";
							LET sPorcentaje=0;
						ELSE
							SELECT descripcion
							INTO cDesParentesco
							FROM bdinteg:"informix".si_parentesco
							WHERE parentesco= TRIM(NVL(cCodParentesco,''))
							AND empresa=TRIM(NVL(pEmpresa,''));
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCodret = '000002'; --No se encontraron registros
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
						LET cCodret = '000002'; --No se encontraron registros
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
					WHERE cuenta=TRIM(NVL(pCuenta,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
			
						SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
						INTO cNombreCompleto
						FROM bdinteg:"informix".si_cliente
						WHERE numcte=TRIM(NVL(cNumcte,'')) 
						AND empresa=TRIM(NVL(pEmpresa,''));
						
						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '000002'; --No se encontraron registros
							LET cNumCte ="";
							LET cNombreCompleto ="";
							LET cCodParentesco="";
							LET cDesParentesco="";
							LET sPorcentaje=0;
						ELSE
							SELECT descripcion
							INTO cDesParentesco
							FROM bdinteg:"informix".si_parentesco
							WHERE parentesco= TRIM(NVL(cCodParentesco,''))
							AND empresa=TRIM(NVL(pEmpresa,''));
							
							IF dbinfo("sqlca.sqlerrd2") = 0 THEN
								LET cCodret = '000002'; --No se encontraron registros
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
						LET cCodret = '000002'; --No se encontraron registros
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
"Descripción: Consulta datos de los beneficiarios de una cuenta de Inversión Creciente o Pagaré",
"Autor : Leslie Rendón",
"FECHA : 27/10/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consultacte_altaunica(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cCodRet2  CHAR(5);
DEFINE cPrimerNombre  CHAR(26);
DEFINE cSegundoNombre CHAR(26);
DEFINE cApellidoPaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE dFechaNacimiento DATE;
DEFINE cRfc CHAR(13);
DEFINE cClienteCoppel CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE cNumCte CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cCodret2 = "00000";
LET cPrimerNombre = "";
LET cSegundoNombre ="";
LET cApellidoPaterno ="";
LET cApellidoMaterno ="";
LET dFechaNacimiento ="";
LET cRfc ="";
LET cClienteCoppel ="";
LET iSqlErr = 0;
LET cNumCte ="";
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,cClienteCoppel,cNumcte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pNumero,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicheq:"informix".sc_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT num_cte
					INTO cNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					UNION
					SELECT num_cte
					FROM bdinvers:"informix".sv_maeinv
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
				END FOREACH;
			ELIF TRIM(NVL(pOpcion,''))='3' THEN
				LET cNumCte=pNumero;
			ELIF TRIM(NVL(pOpcion,''))='4' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicred:"informix".sd_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			END IF
			
			SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
			INTO cApellidoPaterno, cApellidoMaterno, cPrimerNombre, cSegundoNombre, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte=TRIM(NVL(cNumcte,''))
			AND empresa=TRIM(NVL(pEmpresa,''));
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
				LET cPrimerNombre='';
				LET cSegundoNombre='';
				LET cApellidoPaterno='';
				LET cApellidoMaterno='';
				LET dFechaNacimiento='';
				LET cRfc='';
				LET cClienteCoppel='';
			ELSE
				SELECT fecha_nac
				INTO dFechaNacimiento
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte= TRIM(NVL(cNumcte,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"Descripción: Consulta datos generales del cliente",
"Autor : Leslie Rendón",
"FECHA : 24/10/2014",
"Descripción: Se modifica para agregar consulta por Tarjeta de crédito",
"Modifico : Leslie Rendón",
"FECHA : 16/12/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consultabiometria(pTipo CHAR(1), pCodSuc CHAR(4), pNumCte CHAR(20))
	RETURNING 	CHAR(5) AS CodRet, 
				CHAR(1) AS SucBiometria, 
				CHAR(1) AS CteBiometria;

	--Definicion de Variables
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cSucBiometria CHAR(1);
	DEFINE cCteBiometria CHAR(1);

	--Inicializacion de Variables
	LET iSqlErr = 0;
	LET cCodRet = '000';
	LET cSucBiometria = '0';
	LET cCteBiometria = '0';

	--SET DEBUG FILE TO '/informix/IrisA/sp_consultabiometria.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucBiometria, cCteBiometria;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			SELECT ibanbiometria INTO cSucBiometria
			FROM "informix".si_sucursales WHERE sucursal = pCodSuc;

			IF NVL(cSucBiometria,'') = '1' AND NVL(pNumCte,'') <> '' THEN
				SELECT tpo_biometria INTO cCteBiometria
				FROM "informix".si_cliente WHERE numcte = pNumCte;
			END IF;

		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

		RETURN cCodRet, NVL(cSucBiometria,''), NVL(cCteBiometria,'');
	END;
END PROCEDURE;