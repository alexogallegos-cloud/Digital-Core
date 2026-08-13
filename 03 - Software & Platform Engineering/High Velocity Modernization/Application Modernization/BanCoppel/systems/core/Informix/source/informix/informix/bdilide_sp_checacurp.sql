CREATE PROCEDURE "informix".sp_checacurp(pCurp CHAR(18), pRfc CHAR(13) )
RETURNING CHAR(6),char(80);
--Anselmo Verdugo

DEFINE vcRfc                    CHAR(13);
DEFINE vcNumero                 CHAR(10);
DEFINE I                        SMALLINT;
DEFINE J                        SMALLINT;
DEFINE vcConsonantes            CHAR(30);
define iConsonantes             smallint;
define iNumeros                 smallint;
define cSiglasEdos              char(2);

    LET vcRfc                   = '';
    LET vcNumero                 = '0123456789';
    LET vcConsonantes            = 'BCDFGHJKLMNÑPQRSTVWXYZ';
    Let iConsonantes             = 0;
    Let iNumeros                 = 0;
    LET I = 1;
    LET J = 1;

    -- CHECAR SI LA CURP TRAE 18 DIGITOS
    Let pCurp =trim(upper(pCurp));
    Let pRfc = trim(upper(pRFC));
    
 IF LENGTH(pRfc) < 13 THEN
        RETURN '000009','Longitud no es de 13 caracteres para RFC';
 END IF;    

IF LENGTH(pCurp) < 18 THEN
    RETURN '000001','Longitud no es de 18 caracteres';
ELSE-- si la longitud no es de 18 caracteresz
    IF SUBSTR(pCurp,1,10) <> SUBSTR(pRfc,1,10)THEN
        RETURN '000002','RFC no coincide con curp';
    ELSE
        IF SUBSTR(pCurp,11,1) <> 'H' and SUBSTR(pCurp,11,1)  <> 'M' THEN
            RETURN  '000003','No se encuentra Sexo(H/M)';
        ELSE-- sino cuando es 'H' o es 'M'
            Let cSiglasEdos = SUBSTR(pCurp,12,2);
            If cSiglasEdos not in ('AS','BC','BS','CC','CL','CM','CS','CH','DF','DG') and
               cSiglasEdos not in ('GT','GR','HG','JC','MC','MN','MS','NT','NL','OC') and
               cSiglasEdos not in ('PL','QT','QR','SP','SL','SR','TC','TS','TL','VZ') and
               cSiglasEdos not in ('YN','ZS','NE') THEN
                RETURN '000004','Las siglas de entidad federativa no son validas.';
            ELSE
                --VALIDAR 3 CARACTERES DE CONSONANTES INTERNAS
                WHILE   J < 28  and iConsonantes < 3
                    IF SUBSTR(pCurp,14,1) =  SUBSTR(vcConsonantes,J,1) THEN
                        LET iConsonantes = iConsonantes + 1;
                    END IF;

                    IF SUBSTR(pCurp,15,1) =  SUBSTR(vcConsonantes,J,1) THEN
                        LET iConsonantes = iConsonantes + 1;
                    END IF;

                    IF SUBSTR(pCurp,16,1) =  SUBSTR(vcConsonantes,J,1) THEN
                        LET iConsonantes = iConsonantes + 1;
                    END IF;

                    LET J = J + 1;
                END WHILE;

                IF iConsonantes < 3 THEN
                    RETURN '000005','Tres consonantes internas no validas.';
                ELSE
                    WHILE I < 11 and iNumeros < 2 

                        IF SUBSTR(pCurp,17,1) =  SUBSTR(vcNumero,I,1) THEN
                            LET iNumeros = iNumeros + 1;
                        END IF;

                        IF SUBSTR(pCurp,18,1) =  SUBSTR(vcNumero,I,1) THEN
                            LET iNumeros = iNumeros + 1;
                        END IF;

                        LET I = I + 1;
                    END WHILE;

                            --Para todos los nacidos antes del año 2000, el digito debe ser de 0 a 9
                            --Asumimos que por ahora los ctes de bancoppel son nacidos antes del año 2000
                            --En tanto se actualiza esta funcion

                    IF iNumeros < 2 THEN
                        RETURN '000006','Últimos dos caracteres deben ser numeros.';
                    ELSE
                        return '000000','Curp correcta: '  || pCurp ;                                
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END IF;

return '000000','Curp correcta' || pCurp ;

END PROCEDURE;