CREATE PROCEDURE "informix".sp_validanombrefn(p_cPrimNom1 CHAR(160), 
											  p_cSegNom1 CHAR(40), 
											  p_cApePat1 CHAR(40), 
											  p_cApeMat1 CHAR(40),
											  p_dFechaNac1 CHAR(10),
											  p_cPrimNomCmp CHAR(160), 
											  p_cSegNomCmp CHAR(40), 
											  p_cApePatCmp CHAR(40), 
											  p_cApeMatCmp CHAR(40),
											  p_dFechaNacCmp CHAR(10),
											  p_siGrabaBit SMALLINT)
    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    DECIMAL(6,1); -- Porcentaje

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      	INT;
    DEFINE cCodRet      	CHAR(5);
    DEFINE dPorcentaje1  	DECIMAL(6,1);
	DEFINE dPorcentaje2  	DECIMAL(6,1);
	DEFINE dPorcentaje3  	DECIMAL(6,1);
	DEFINE dPorcentaje4  	DECIMAL(6,1);
	DEFINE dPorcMax      	DECIMAL(6,1);	
	DEFINE i            	INTEGER;
	DEFINE iCoicidencia 	INTEGER;
	DEFINE iCantidad    	INTEGER;
	DEFINE cCarBan      	CHAR(1);
	DEFINE cCarBTS      	CHAR(1);
    DEFINE iSuma        	INTEGER;
	DEFINE dPorciento    	DECIMAL(6,1);
    DEFINE cNomCompleto1   	CHAR(160);
    DEFINE cNomCompletoCmp	CHAR(160);
	DEFINE iLong INTEGER;
	
        --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET cCodRet = '00000';
    LET dPorcentaje1 = 0;
	LET dPorcentaje2 = 0;
	LET dPorcentaje3 = 0;
	LET dPorcMax = 0;
    LET i = 0;
	LET iCoicidencia = 0;
	LET iCantidad = 0;
    LET iSuma = 0;
	let dPorciento = 0;
	LET cNomCompleto1 = '';
	LET cNomCompletoCmp = '';
	
	--SET DEBUG FILE TO "/informix/yoselin/sp_validanombrefn.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet, dPorciento;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET iLong = LENGTH(TRIM(p_cPrimNom1));
	LET p_dFechaNac1 = p_dFechaNac1;
	LET p_cPrimNom1 = p_cPrimNom1;
	--IF (((NVL(p_dFechaNac1,'') = '')) AND ((NVL(p_cPrimNom1,'') <> '') AND (LENGTH(TRIM(p_cPrimNom1)) > 40))) THEN--OR 
	IF (((NVL(p_dFechaNac1,'') = '')) AND ((NVL(p_cPrimNom1,'') <> '') AND (NVL(p_cApePat1,'') = ''))) OR 
	   (((NVL(p_dFechaNac1,'') <> '')) AND (NVL(p_cPrimNom1,'') = '') AND (NVL(p_cApePat1,'') = '')) OR
	   ((NVL(p_cPrimNom1,'') = '') AND (NVL(p_cApePat1,'') = '')) THEN
			LET cCodRet =   '00001'; --Faltan parámetros
			RETURN cCodRet, dPorciento;
	END IF;
		
	IF (NVL(p_cPrimNom1,'') <> '') THEN --INICIA PRIMER CICLO DE VALIDACIONES: CARACTER POR CARACTER
		EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(p_cPrimNomCmp), TRIM(p_cPrimNom1))  --VALIDACION DE PRIMER NOMBRE CARACTER POR CARACTER
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));
	END IF;
		
	IF NVL(p_cSegNom1,'') <> '' THEN  --VALIDACION DE SEGUNDO NOMBRE CARACTER POR CARACTER
		EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(p_cSegNomCmp), TRIM(p_cSegNom1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;	
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));
	END IF;	
		
	IF NVL(p_cApePat1,'') <> '' THEN
		EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(p_cApePatCmp), TRIM(p_cApePat1))  --VALIDACION DE APELLIDO PATERNO CARACTER POR CARACTER
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(TRIM(p_cApePat1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApePat1));
	END IF;
		
	IF NVL(p_cApeMatCmp,'') <> '' THEN   
		EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(p_cApeMatCmp), TRIM(p_cApeMat1)) --VALIDACION DE APELLIDO MATERNO CARACTER POR CARACTER
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApeMat1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApeMat1));
	END IF;
	
	IF (NVL(p_dFechaNac1,'') <>'') THEN   
		EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(p_dFechaNacCmp), TRIM(p_dFechaNac1)) --VALIDACION DE FECHA DE NACIMIENTO CARACTER POR CARACTER
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));	
	END IF;

	LET dPorcentaje1 = CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));
	LET dPorcMax = dPorcentaje1;
	
	LET iSuma = 0;
	LET iCantidad  =  0;
				
	IF (NVL(p_cPrimNom1,'') <> '') THEN  								--INICIA SEGUNDO CICLO DE VALIDACIONES: DESPLAZAMIENTO BTS
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBTS(TRIM(p_cPrimNomCmp), TRIM(p_cPrimNom1))  --VALIDACION DE PRIMER NOMBRE 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));	
	END IF;
	
	IF NVL(p_cSegNom1,'') <> '' THEN  																--VALIDACION DE SEGUNDO NOMBRE 
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBTS (TRIM(p_cSegNomCmp), TRIM(p_cSegNom1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;	
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));	
	END IF;	
	
	IF (NVL(p_cApePat1,'') <> '') THEN
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBTS (TRIM(p_cApePatCmp), TRIM(p_cApePat1))  --VALIDACION DE APELLIDO PATERNO 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(TRIM(p_cApePat1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApePat1));			
	END IF;		
	
	IF (NVL(p_cApeMatCmp,'') <> '') THEN   															--VALIDACION DE APELLIDO MATERNO 
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBTS (TRIM(p_cApeMatCmp), TRIM(p_cApeMat1))
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApeMat1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApeMat1));
	END IF;
		
	IF (NVL(p_dFechaNac1,'') <> '') THEN   														--VALIDACION DE FECHA DE NACIMIENTO
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBTS (TRIM(p_dFechaNacCmp), TRIM(p_dFechaNac1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));	
	END IF;
	
	LET dPorcentaje2 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));	 
	LET iSuma = 0;
	LET iCantidad  =  0;
	
	IF dPorcentaje2 > dPorcMax THEN
		LET dPorcMax = dPorcentaje2;
	END IF;
		
	IF (NVL(p_cPrimNom1,'') <> '') THEN								--INICIA TERCER CICLO DE VALIDACIONES: DESPLAZAMIENTO BANCOPPEL	
																										--VALIDAR SEGUNDO NOMBRE 
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBanco(TRIM(p_cPrimNomCmp), TRIM(p_cPrimNom1))
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cPrimNom1));		
	END IF;
	
	IF NVL(p_cSegNomCmp,'') <> '' THEN  																--VALIDAR SEGUNDO NOMBRE 
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBanco (TRIM(p_cSegNomCmp),TRIM(p_cSegNom1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;	
	ELSE 
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cSegNom1));
	END IF;	
	
	IF NVL(p_cApePat1,'') <> '' THEN
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBanco (TRIM(p_cApePatCmp), TRIM(p_cApePat1))  --VALIDAR APELLIDO PATERNO 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(TRIM(p_cApePat1));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApePat1));		
	END IF;
		
	IF NVL(p_cApeMatCmp,'') <> '' THEN  															--VALIDAR APELLIDO MATERNO 
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBanco (TRIM(p_cApeMatCmp),TRIM(p_cApeMat1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(p_cApeMat1);
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE 
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_cApeMat1));
	END IF;
	
	IF (NVL(p_dFechaNac1,'') <> '') THEN															--VALIDAR FECHA DE NACIMIENTO	
		EXECUTE PROCEDURE bdisac:sp_ComparaDesfasamientoBanco (TRIM(p_dFechaNacCmp), TRIM(p_dFechaNac1)) 
		INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));
		ELSE
			RETURN cCodRet, dPorciento;		
		END IF;
	ELSE
		LET iCoicidencia = 0;
		LET iSuma = iSuma + iCoicidencia;
		LET iCantidad  =  iCantidad + LENGTH(TRIM(p_dFechaNac1));	
	END IF;
	
	LET dPorcentaje3 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));

	IF dPorcentaje3 > dPorcMax THEN
		LET dPorcMax = dPorcentaje3;
	END IF;		

		
	--INICIA CUARTO CICLO DE VALIDACIONES: CADENA COMPLETA 
	-- Concatenación del Nombre Completo
	LET cNomCompleto1 = TRIM(p_cPrimNom1);
	LET cNomCompleto1 = TRIM(cNomCompleto1)||' '||TRIM(p_cSegNom1);
	LET cNomCompleto1 = TRIM(cNomCompleto1)||' '||TRIM(p_cApePat1);
	LET cNomCompleto1 = TRIM(cNomCompleto1)||' '||TRIM(p_cApeMat1);
	LET cNomCompleto1 = TRIM(cNomCompleto1)||' '||TRIM(p_dFechaNac1);
	
	LET cNomCompletoCmp = TRIM(p_cPrimNomCmp);
	LET cNomCompletoCmp = TRIM(cNomCompletoCmp)||' '||TRIM(p_cSegNomCmp);
	LET cNomCompletoCmp = TRIM(cNomCompletoCmp)||' '||TRIM(p_cApePatCmp);
	LET cNomCompletoCmp = TRIM(cNomCompletoCmp)||' '||TRIM(p_cApeMatCmp);
	LET cNomCompletoCmp = TRIM(cNomCompletoCmp)||' '||TRIM(p_dFechaNacCmp);
	
	LET cNomCompleto1 = TRIM(cNomCompleto1);
	LET cNomCompletoCmp = TRIM(cNomCompletoCmp);

	LET iSuma = 0;
	LET iCantidad  =  0;	

	EXECUTE PROCEDURE bdisac:sp_ComparaCaracteresBTS (TRIM(cNomCompletoCmp), TRIM(cNomCompleto1))  --VALIDACION DE NOMBRE COMPLETO CARACTER POR CARACTER
	INTO cCodRet, iCoicidencia;
	
	IF cCodRet = '00000' THEN
		LET iSuma = iCoicidencia;
		LET iCantidad = LENGTH(TRIM(cNomCompleto1));
	ELSE
		RETURN cCodRet, dPorciento;	
	END IF;
	
	LET dPorcentaje4 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));

	IF dPorcentaje4 > dPorcMax THEN
		LET dPorcMax = dPorcentaje4;
	END IF;	

    --LET iPorciento = CAST(iPorcMax AS INTEGER);
	LET dPorciento = dPorcMax;
	 
	--Se realiza la insercion a la bitacora de comparacion de nombres
	IF p_siGrabaBit = 1 THEN --Llamado desde BTS
		INSERT INTO bdisac:sac_bts_bitnombres (s_first_nameban, s_middle_nameban,s_last_nameban,s_mother_m_nameban,s_first_namebts,s_middle_namebts,s_last_namebts,s_mother_m_namebts,coicidencia,fecha_insert) 
		VALUES (p_cPrimNom1, p_cSegNom1,p_cApePat1,p_cApeMat1,p_cPrimNomCmp,p_cSegNomCmp,p_cApePatCmp,p_cApeMatCmp,dPorciento,CURRENT);
	END IF;
	
    RETURN cCodRet, dPorciento;
END
END PROCEDURE
DOCUMENT
'RESPALDA: RQI 64 023',
'FUNCIONALIDAD: Tiene finalidad de unificar la comparacion de nombres y fechas de nacimiento para ser implementado desde cualquier proceso',
'AUTOR : Jose Angel Lopez Adams',
'FECHA : 09/Julio/2014',
'Ver.  : 20140709.1126',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_ipab_rangoctes_temp()
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE iDesErr      CHAR(50);
    DEFINE vpromedio    INTEGER;
    DEFINE vcont        SMALLINT;
    DEFINE vbrinca      INTEGER;
    DEFINE cNumCte      CHAR(20);
    
    LET cCodRet    = "000";
    LET cCodRet2   = "";
    LET cCodRet3   = "";
    LET iSqlErr    = 0;
    LET iSamErr    = 0;
    LET iDesErr    = '';  
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET cNumCte    = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes_temp.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes_temp.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ROUND(COUNT(*)/20)
      INTO vpromedio
      FROM si_cliente_ipab_temp;
      
    LET vcont = 1;
    
    WHILE vcont <= 21 
        IF vcont = 1 THEN
            SELECT MIN(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_temp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 221;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
             
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 222;
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 223;
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 224;
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 225;
            END FOREACH;
        ELIF vcont = 6 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 226;
            END FOREACH;
        ELIF vcont = 7 THEN
            LET vbrinca = vpromedio * 6;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 227;
            END FOREACH;
        ELIF vcont = 8 THEN
            LET vbrinca = vpromedio * 7;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 228;
            END FOREACH;
        ELIF vcont = 9 THEN
            LET vbrinca = vpromedio * 8;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 229;
            END FOREACH;
        ELIF vcont = 10 THEN
            LET vbrinca = vpromedio * 9;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 230;
            END FOREACH;
        ELIF vcont = 11 THEN
            LET vbrinca = vpromedio * 10;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 231;
            END FOREACH;
        ELIF vcont = 12 THEN
            LET vbrinca = vpromedio * 11;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 232;
            END FOREACH;
        ELIF vcont = 13 THEN
            LET vbrinca = vpromedio * 12;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 233;
            END FOREACH;
        ELIF vcont = 14 THEN
            LET vbrinca = vpromedio * 13;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 234;
            END FOREACH;
        ELIF vcont = 15 THEN
            LET vbrinca = vpromedio * 14;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 235;
            END FOREACH;
        ELIF vcont = 16 THEN
            LET vbrinca = vpromedio * 15;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 236;
            END FOREACH;
        ELIF vcont = 17 THEN
            LET vbrinca = vpromedio * 16;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 237;
            END FOREACH;
        ELIF vcont = 18 THEN
            LET vbrinca = vpromedio * 17;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 238;
            END FOREACH;
        ELIF vcont = 19 THEN
            LET vbrinca = vpromedio * 18;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 239;
            END FOREACH;
        ELIF vcont = 20 THEN
            LET vbrinca = vpromedio * 19;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 240;
            END FOREACH;
        ELIF vcont = 21 THEN
            SELECT MAX(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_temp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 241;
        END IF;
        
        LET vcont = vcont + 1;  
        LET cNumCte = '';
    END WHILE;    

    END;
    
    RETURN cCodRet;

END PROCEDURE;