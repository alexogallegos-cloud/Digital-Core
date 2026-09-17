CREATE PROCEDURE "informix".sp_obtenerposicion(
    pCadena LVARCHAR, 
    pCaracter VARCHAR(30)
)
RETURNING INTEGER,
          INTEGER;

DEFINE iSalida      INTEGER;
DEFINE iSalida2     INTEGER;
DEFINE cCadenaAux   LVARCHAR;
DEFINE cComparaAux  LVARCHAR;  
DEFINE cCadenaFin   LVARCHAR;  
DEFINE i            INTEGER;
define cComparacion LVARCHAR;
define cCaracter    LVARCHAR;
DEFINE iTotal       INTEGER;
DEFINE cBan         CHAR(1);

LET iSalida         = 0;
LET iSalida2        = 0;
LET cCadenaAux      = "";
LET cComparaAux     = "";  
LET cCadenaFin      = "";  
LET i               = 0;
let cComparacion    = "";
let cCaracter       = ""; 
LET iTotal          = 0;
LET cBan            = 'F';

BEGIN 
--SET DEBUG FILE TO '/tmp/sp_obtenerposicion.out';
--TRACE ON;
    IF  NVL(pCadena,'') = '' THEN 
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2;
    END IF;

    IF  NVL(pCaracter,'') = '' THEN 
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2;
    END IF;

    LET cCadenaAux = pCadena;
    LET cComparaAux = pCaracter;  
    LET cCadenaFin = REPLACE(cCadenaAux,cComparaAux,'º');
    LET cComparacion = LENGTH(cCadenaFin);
    LET iTotal = LENGTH(cComparaAux);

    WHILE i < cComparacion
       LET i = i + 1;
       LET cCaracter = SUBSTR(cCadenaFin,i,1);
            IF cCaracter = 'º' THEN 
               LET iSalida = i;
               LET iSalida2 = (i + iTotal) - 1;
               LET cBan = 'T';
                  RETURN iSalida, iSalida2  WITH RESUME;
            END IF;
    END WHILE;

    IF cBan = 'F' THEN
    LET iSalida = -1;
    LET iSalida2 = -1;
    RETURN iSalida, iSalida2  WITH RESUME;
    END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que te devuelve las posiciones de un caracter',
                'Devuelve:',
                    'iSalida  - La posición inicial del carácter',
                    'iSalida2  - La posición final del carácter',
'AUTOR: Paul Quintero ',
'VERSION: 20101019.1041';

CREATE PROCEDURE "informix".sp_cat_arch_cartbase(pSeparador CHAR(1), ptipo_cobranza CHAR(1))
       RETURNING  CHAR(6), CHAR(150);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE cMensaje         CHAR(150);
DEFINE cCadena          CHAR (500);
DEFINE vFechaArch       DATE;
DEFINE vNomArch         CHAR(40);
DEFINE vPathOri         CHAR(50);
DEFINE vPath            CHAR(50);
DEFINE vfecha_insert    DATE;
DEFINE vnumcte          CHAR(20);
DEFINE vciudad_coppel   SMALLINT;
DEFINE vstatus          SMALLINT;
DEFINE vtipo_logica     SMALLINT;
DEFINE vempresa         CHAR(3);
DEFINE cProceso         CHAR(30);
--DEFINE pcampania        CHAR(15);
------------------------------------------------------------

    LET cCod_ret      = '000000';
    LET sql_err       = 0;
    LET cMensaje      = '';
    LET cCadena       = '';
    --LET vNomArch      = 'cartera_clientes_';
    LET vPathOri      = '';
    LET vPath         = '';
    LET vempresa      = '001';
    LET cProceso      = '0002';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02');
            drop table cb_tabla_temporal;
        RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

            CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01');
                
    --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_cat_arch_cartbase.out";
    --TRACE ON;

    --drop table cb_tabla_temporal;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas;

    SELECT valor_alfabetico
    INTO vNomArch
    FROM cb_param_campania 
    WHERE tipo_campania= 1
    AND grupo_parametro= 'ARCHIVOS'
    AND num_parametro= 1;

    /*IF ptipo_cobranza = 'A' THEN
        LET pcampania = '_admin';
    ELSE
        LET pcampania = '_prev';
    END IF;*/

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

    -- ARMAR NOMBRE DEL ARCHIVO TXT
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

    -- EXTRAER LA RUTA DEPOSITO DE ARCHIVO
    SELECT valor_alfabetico
    INTO vPathOri
    FROM cb_param_campania 
    WHERE tipo_campania= 1
    AND grupo_parametro= 'ARCHIVOS'
    AND num_parametro= 9;

    LET vPath = TRIM(vPathOri);

            CREATE TABLE informix.cb_tabla_temporal (
                tipo_cobranza     	CHAR(1),
                fecha_insert        DATE,
                numcte              CHAR(20),
                ciudad_coppel       SMALLINT,
                status              SMALLINT,
                tipo_logica         SMALLINT,
                flag                SMALLINT
                );

                FOREACH


                    SELECT  a.fecha_insert , a.numcte, b.ciudad_coppel, a.tipo_logica, (select  valor_numerico
                                                                                FROM cb_param_campania
                                                                                WHERE  tipo_campania = 1
                                                                                AND grupo_parametro ='STATUSCTE'
                                                                                AND TRIM(valor_alfabetico)=status_cliente) status
                    INTO vfecha_insert, vnumcte, vciudad_coppel, vtipo_logica, vstatus
                    FROM bdicobranza:cb_cat_directorio_cte a, bdinteg:si_ciudades b, bdinteg:si_direcciones c
                    WHERE a.numcte = c.numcte
                    AND a.numcte = c.numcte
                    AND c.pais = b.pais
                    AND c.estado = b.estado
                    AND c.ciudad = b.ciudad
                    AND c.tipo_dir = '1'
                    AND c.secuencia = ( SELECT max(secuencia) FROM bdinteg:si_direcciones h
                                        WHERE tipo_dir = '1'
                                        AND a.numcte = h.numcte)
                    AND a.tipo_cobranza = ptipo_cobranza

                    INSERT INTO "informix".cb_tabla_temporal(tipo_cobranza, fecha_insert, numcte, ciudad_coppel, status, tipo_logica, flag)
                    VALUES(ptipo_cobranza, vfecha_insert, vnumcte, vciudad_coppel, vstatus, vtipo_logica, 0);

                END FOREACH;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

            LET cCadena = 'echo "unload to ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || ' DELIMITER ''' || pSeparador || ''' SELECT * FROM cb_tabla_temporal'
                   || '" > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;
            let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;
            let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'cartera_base.sql';
            System cCadena;

            drop table cb_tabla_temporal;

LET cMensaje = TRIM(vNomArch);

CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03');
            
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;