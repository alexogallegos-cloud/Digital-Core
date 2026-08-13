CREATE PROCEDURE "informix".sp_insertarsucursalessorteo( )
RETURNING CHAR(5);

DEFINE  SQL_ERR                  INTEGER;
DEFINE  ISAM_ERR                 INTEGER;
DEFINE  ERROR_INFO           CHAR(80);
DEFINE  P_COD_RET             CHAR(5);
DEFINE  cSucursal                   CHAR(4);

LET SQL_ERR                 = 0;
LET ISAM_ERR                = 0;
LET ERROR_INFO          = '';
LET P_COD_RET            = '';
LET cSucursal                  = '';

BEGIN
 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      RETURN P_COD_RET;
 END EXCEPTION;
 
 --Set debug file to "/respaldosbd/saul/sp_obtparamsorteo.out";
 --Trace on;
   
   LET P_COD_RET = '00000';

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;

   FOREACH
              SELECT sucursal 
              INTO       cSucursal
              FROM     si_sucursales
              WHERE  tpo_sucursal ='S'  
              
              INSERT INTO si_sucursales_sorteo(empresa, sucursal, cve_sorteo_normal, cve_sorteo_inst, flag_sorteo_normal, flag_imprime_normal, flag_sorteo_inst, flag_imprime_inst,  fecha_insert, user_insert)
              VALUES('001', cSucursal,'00002','00003', 0, 0, 0, 0, CURRENT, USER);
 
   END FOREACH;

   RETURN P_COD_RET;   

END;
END PROCEDURE             
DOCUMENT
"Descripción: Procedimiento que Inserta en la tabla que contiene los parametros del sorteo",
"BD: bdinteg",
"Fecha: 19-Octubre-2010",
"Autor: Saúl Ivanhoe Valdespino Hernández";

CREATE PROCEDURE "informix".sp_seleccionsorteo( )

    RETURNING CHAR(5), CHAR(5), CHAR(50);

    -- DEFINICION DE VARIABLES --
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE cCveSorteo CHAR(5);
    DEFINE cResultado CHAR(50);
	DEFINE v_param	  CHAR(5);
	

    -- INICIALIZACION DE VARIABLES --
    LET cCodRet = "00000";
    LET cCveSorteo = "00000";
    LET cResultado = "";

    --SET DEBUG FILE TO '/tmp/sp_seleccionsorteo.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cCveSorteo, cResultado;
        END IF;
    END EXCEPTION;

	 SELECT valor INTO v_param
	FROM bdinteg:si_param
	WHERE cod_param = 118;

    SELECT cve_sorteo, descripcion INTO cCveSorteo, cResultado
    FROM si_sorteo WHERE cve_sorteo = v_param;

    RETURN cCodRet, cCveSorteo, cResultado;    

    END;
END PROCEDURE;