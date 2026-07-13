CREATE PROCEDURE "informix".sp_obtienebancos (pBanco CHAR(3))
RETURNING CHAR(6)     AS cCodRet,
		  CHAR(3)     AS CveBanco,
		  CHAR(40)    AS Descripcion,
		  CHAR(1)     AS TipoBanco,
		  INTEGER     AS CveSIF, 
		  VARCHAR(20) AS NombreCorto,
		  CHAR(1)     AS FlagDomiR,
		  CHAR(1)     AS FlagDomiP;		  		  

    DEFINE cCodRet             CHAR(6);
    DEFINE iSql_Err            INTEGER;
    DEFINE iSam_Err            INTEGER;
    DEFINE cCveBanco           CHAR(3);  
    DEFINE cDescripcion        CHAR(40);
    DEFINE cTipoBanco		   CHAR(1);
    DEFINE iCvecesif           INTEGER;
    DEFINE vNombreCorto		   VARCHAR(20);
    DEFINE cFlgdomiR	       CHAR(1);
    DEFINE cFlgdomiP		   CHAR(1);

    LET cCodRet         = '000000';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET cCveBanco       = '';
    LET cDescripcion    = '';
    LET cTipoBanco      = ''; 
    LET iCvecesif       = 0;
    LET vNombreCorto    = '';
    LET cFlgdomiR       = '';
    LET cFlgdomiP       = '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtienebancos.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP;
        END IF;
    END EXCEPTION;

    -- // SE OBTIENE INFORMACION BASICA DEL BANCO.	
    FOREACH 
        SELECT banco, descripcion, tp_banco, cvecesif, vchrnombrecorto, flg_domi_r, flg_domi_p
          INTO cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP
          FROM bdinteg:"informix".si_bancos
         WHERE banco = CASE WHEN pBanco <> ''  THEN pBanco  ELSE banco END
         ORDER BY banco::INTEGER

        RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP WITH RESUME;
    END FOREACH;

    -- // SE VERIFICA SI LA CONSULTA REGRESO INFORMACION.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000002';
        LET cDescripcion = 'No Existe Banco con esa Clave.';
        RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'FECHA CREACION: 15 de Julio del 2011',
'DESCRIPCION: Regresa todos los bancos por su clave de banco.',
'MODIFICO: Guadalupe Payan',
'FECHA MODIFICACION: 15 de Agosto del 2011',
'DESCRIPCION: Se eliminaron dos campos que no se encontraban en la tabla', 
'si_bancos productiva y se elimino la variable bandera iCont,se sustituyo por el comando: DBINFO',
'VERSION: 20110815.1046',
'BD: BDINTEG';

create procedure "informix".sp_validar_telefono(pTelefono char(20) )
 returning char(5);
 
 define v_codret char(5);
 --define v_cadena char(10);
 define i smallint;
 define v_long_word smallint;
 define v_caracter char(1);
 --define v_result char(1);
 
 let v_codret = '00000';
 --let v_cadena = '';
 let i = 0;
 let v_long_word = 0;
 let v_caracter = '';
 --let v_result = 'S';
 
 let v_long_word = length(pTelefono);
 
  BEGIN

    FOR i IN (0 TO v_long_word)
          let v_caracter = substr(pTelefono, i, 1);     
          IF ( v_caracter <> '0' and v_caracter <> '1' and v_caracter <> '2' and v_caracter <> '3' and v_caracter <> '4' and v_caracter <> '5' and
               v_caracter <> '6' and v_caracter <> '7' and v_caracter <> '8' and v_caracter <> '9')   THEN

               --let v_result = 'N';
               let v_codret = "00700";
               RETURN v_codret;
          END IF;
    END FOR;
   
    --let v_codret = "Telefono correcto!";
    RETURN v_codret;
    
  END;
end procedure;