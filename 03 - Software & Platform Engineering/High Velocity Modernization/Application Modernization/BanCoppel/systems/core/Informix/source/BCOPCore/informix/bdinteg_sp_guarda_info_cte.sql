CREATE PROCEDURE "informix".sp_guarda_info_cte(cEmpresa CHAR(3),cEstadoNac CHAR(5),cNumCte CHAR(20), cGenero CHAR(1), cCURP CHAR(20))

RETURNING CHAR(6) AS codret;

DEFINE clientes INTEGER;
DEFINE vCodret CHAR (6);
DEFINE vSql_err INTEGER;  

LET vCodret  = '000000';
LET vSql_err = 0;


 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_guarda_info_cte.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF cNumCte is null or cNumCte ="" THEN 
		LET vCodret = '000001'; -- Falta parametro de entrada
        RETURN vCodret;
     END IF;
	 
	    SELECT COUNT(*) INTO clientes FROM bdinteg:"informix".si_ctepf WHERE numcte = cNumCte;
		IF clientes >0 THEN
		
		    IF cGenero <> "" THEN 
			
				UPDATE bdinteg:"informix".si_ctepf 
				SET sexo = cGenero
				WHERE numcte = cNumCte;
				
		    END IF;
			
			
			IF cEstadoNac <> "" THEN 
			
				UPDATE bdinteg:"informix".si_ctepf 
				SET lugar_nac = cEstadoNac
				WHERE numcte = cNumCte;
				
		    END IF;
			
			
			IF cCURP <> "" THEN 
			
				UPDATE bdinteg:"informix".si_ctepf 
				SET curp = cCURP
				WHERE numcte = cNumCte;

		    END IF;
			
			
		END IF;
	

     RETURN vCodret;
 END;
END PROCEDURE
DOCUMENT
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_guarda_info_cte"',
'Folio:			101697-2',
'Autor: 		99805696 Aaron Jeronimo Torres Acosta',
'Fecha: 		10/04/2025',
'Solicita:		Fernando Rojas/David Garcia',
'Descripcion:   Se crea sp para realizar el guardado del genero, estado de nacimiento y curp validada ante renapo.',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_guarda_verificacion_curpine(cEmpresa char(3),cNumCte char(20), cCurp char(20), cVerificacion char(20))

RETURNING CHAR(5) AS codret;

DEFINE vCodret CHAR (5);
DEFINE vSql_err INTEGER;  
DEFINE CExistefolio CHAR(50);
DEFINE cFolio CHAR(50);

LET vCodret  = '000000';
LET vSql_err = 0;


BEGIN

    ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/tmp/sp_guarda_verificacion_curpine.out";
    --TRACE ON;
    
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
    
    IF cNumCte is null or cNumCte ='' THEN 
    
        LET vCodret = '000001'; -- Falta parametro de entrada
        RETURN vCodret;
        
    ELSE

        SELECT CONCAT(TRIM(cNumCte),to_char(CURRENT,"%d%m%Y%H%M%S")) into cFolio;
        SELECT folio INTO CExistefolio FROM bdinteg:"informix".si_validacion_curp WHERE folio=cFolio;
        if NVL(CExistefolio,"")="" THEN
            INSERT INTO bdinteg:"informix".si_validacion_curp (folio,numcte,curp,verificacion,fecha_tran) values (cFolio,cNumCte,cCurp,cVerificacion,today);
        ELSE
            UPDATE bdinteg:"informix".si_validacion_curp SET numcte=cNumCte,curp=cCurp,verificacion=cVerificacion,fecha_tran=today where folio=cFolio;
        END IF;
        
    END IF;

    RETURN vCodret;
END;
END PROCEDURE
DOCUMENT
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_guarda_verificacion_curpine"',
'Folio:			101697-2',
'Autor: 		99805696 Aaron Jeronimo Torres Acosta',
'Fecha: 		29/11/2022',
'Solicita:		Fernando Rojas/David Garcia',
'Descripcion:   Se crea sp para realizar el guardado del genero y estado de nacimiento que se obtiene de la Ine y pasaporte.',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_validacion_alterna_curp_ine(pNumcte char(20)) 
                                                        
    RETURNING CHAR(6);

    DEFINE cCodRet CHAR(6);    
    DEFINE iSqlErr INTEGER;
    DEFINE vcurp   CHAR(20);
    DEFINE vocr    CHAR(20);
    DEFINE vapellpat CHAR(50);
    DEFINE vapellmat CHAR(50);
    DEFINE vnombre CHAR(50);
    DEFINE v_Similitud CHAR(10);   
    DEFINE vPuntoSeguridad CHAR(50);
    DEFINE codigoPuntoSeguridad CHAR(6);    
    DEFINE vCompansi2 CHAR(50);
    DEFINE vCompansi7 CHAR(50);
    DEFINE vPorcentajeFacial CHAR(10);

            
            
    LET cCodRet ='000000';
    LET iSqlErr = 0;
    
--    SET DEBUG FILE TO '/home/sysifx/viridiana/sp_validacion_alterna_curp_ine.out';
--    TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
        
        EXECUTE PROCEDURE "informix".sp_obtiene_puntos_seguridad_ine(pNumcte) INTO codigoPuntoSeguridad,vPuntoSeguridad;
    
        IF vPuntoSeguridad = 'Falso'  THEN
            LET cCodRet = '000001'; 
             RETURN cCodRet;
        ELSE
            SELECT LIMIT 1 curp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, compansi2_ife, compansi7_ife
            INTO vcurp, vocr, vapellpat, vapellmat, vnombre, vCompansi2, vCompansi7
            FROM  "informix".si_bitacora_ife
            WHERE numcte = pNumcte
            AND FECHA = (SELECT MAX (FECHA) 
                         FROM "informix".si_bitacora_ife 
                         WHERE numcte = pNumcte 
                         AND (NVL(compansi7_ife, 0) > 0 OR NVL(compansi2_ife, 0) > 0)); --VALIDA QUE LOS CAMPOS DE SIMILITUD TENGAN INFORMACIÃN
            
            IF NVL(vocr,'F') <> 'V' THEN
                LET cCodRet = '000002'; 
                RETURN cCodRet;
            END IF;
            IF NVL(vcurp,'F') <> 'V' THEN
                LET cCodRet = '000003'; 
                RETURN cCodRet;
            END IF;
            IF NVL(vapellpat,'F') <> 'V' THEN
                LET cCodRet = '000004'; 
                RETURN cCodRet;
            END IF;
            IF NVL(vapellmat,'F') <> 'V' THEN
                LET cCodRet = '000005'; 
                RETURN cCodRet;
            END IF;
            IF NVL(vnombre,'F') <> 'V' THEN
                LET cCodRet = '000006'; 
                RETURN cCodRet;
            END IF;
            
            --Valida la similitud de la huella
            --HACE COMPARACIÃN PARA SABER SI LA INFORMACIÃN DE LOS CAMPOS VIENE DEL SERVICIO INE 4.0 O DEL ANTERIOR
            --VALORES MAYORES A 100 SON DEL SERVICIO ANTERIOR
            --VALORES IGUAL Y MENORES A 100 SON DEL SERVICIO INE 4.0
            IF (vCompansi2::INTEGER > 100 OR vCompansi7::INTEGER > 100) THEN 
                SELECT valor INTO v_Similitud FROM si_param WHERE cod_param='523';
            ELSE
                SELECT valor INTO v_Similitud FROM si_param WHERE cod_param='566';
            END IF
            
            IF vCompansi2::INTEGER < v_Similitud::INTEGER THEN
                
                IF vCompansi7::INTEGER < v_Similitud::INTEGER THEN
                    SELECT LIMIT 1 NVL(respuesta_ine,'-1') 
                    INTO vPorcentajeFacial 
                    FROM "informix".si_bitacora_facial_ine 
                    WHERE numcte = pNumcte 
                    AND fecha_insert = (SELECT MAX (fecha_insert) FROM "informix".si_bitacora_facial_ine WHERE numcte = pNumcte AND NVL(respuesta_ine, 0) > 0);
                    
                    
                    IF NVL(vPorcentajeFacial, 0) <= 0  THEN
                        LET cCodRet = '000007'; 
                        RETURN cCodRet;
                    END IF;
                END IF;
                
            END IF;    
        END IF;
    RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Descripcion: SP que valida la bitacora del ine para ver si se puede dar por validada la curp por flujos con credencial',
'AUTOR : Abdi Evans',
'Gerencia de Captacion',
'Fecha: 31/Julio/2025',
'Version: 1.0.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtener_similitud_huellas_biom_facial_ine40( )

	RETURNING CHAR(5) AS CodRet, CHAR(5) AS Similitud;
	
	DEFINE iSqlErr 	    						INTEGER;
	DEFINE cCodRet 	    						CHAR(5);
	DEFINE v_Similitud							CHAR(5);
	DEFINE sql_err 								INTEGER;
	DEFINE isam_err         					INTEGER;
	DEFINE error_info       					VARCHAR(60);
	
	LET		iSqlErr = 0;
	LET 	cCodRet = '00000';
	LET 	v_Similitud = '00000';
	LET 	sql_err = 0;
	LET 	isam_err = 0;
	LET 	error_info = "";
	BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cCodRet = sql_err;
			RETURN cCodRet, v_Similitud;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		SELECT valor INTO v_Similitud FROM si_param WHERE cod_param='566';
		RETURN cCodRet, v_Similitud;
		
	END
END PROCEDURE;