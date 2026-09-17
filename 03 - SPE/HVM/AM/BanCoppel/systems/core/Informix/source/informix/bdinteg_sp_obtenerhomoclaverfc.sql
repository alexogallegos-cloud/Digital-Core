CREATE PROCEDURE "informix".sp_obtenerhomoclaverfc(pEmpresa CHAR(3),pNombre VARCHAR(104))
RETURNING CHAR(6)       AS retorno,
          VARCHAR(100)  AS mensaje,
          CHAR(2)       AS homoclave;

-- Variables de proceso
DEFINE cHomoclave       CHAR(2);
DEFINE cNom_numerico    VARCHAR(208);
DEFINE I                INTEGER;
DEFINE iSuma            INTEGER;
DEFINE iTotal_1         INTEGER;
DEFINE iTotal_2         INTEGER;
DEFINE cDigito1         CHAR(1);
DEFINE cDigito2         CHAR(1);
DEFINE cCaracter        CHAR(1);
DEFINE cValor           CHAR(2);
DEFINE iValor1          INTEGER;
DEFINE iValor2          INTEGER;
DEFINE iTotal           INTEGER;
DEFINE cNombre          VARCHAR(104);

-- Control de errores
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vErrorInfo   VARCHAR(100);
DEFINE vCodRet      CHAR(6);
DEFINE cMensaje     VARCHAR(100);

-- Variables de proceso
LET cHomoclave      = "";
LET cNom_numerico   = "0";
LET I               = 0;
LET iSuma           = 0;
LET iTotal_1        = 0;
LET iTotal_2        = 0;
LET cDigito1        = "";
LET cDigito2        = "";
LET cCaracter       = "";
LET cValor          = "";
LET iValor1         = 0;
LET iValor2         = 0;
LET iTotal          = 0;
LET cNombre         = "";

-- Control de errores
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET vErrorInfo      = "";
LET vCodRet         = "000000";
LET cMensaje        = "El proceso se realizó con éxito.";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET cMensaje= vErrorInfo;
      RETURN vCodRet, cMensaje,cHomoclave;
   END IF;
END EXCEPTION;

  --SET DEBUG FILE TO "/home/sysifx/viridiana/sp_obtenerhomoclaverfc.out";
  --TRACE ON;

   IF NVL(pEmpresa,"") = "" OR NVL(pNombre,"") = "" THEN
       LET vCodRet = "000001";
       LET cMensaje = "Los datos no se proporcionaron correctamente.";
       RETURN vCodRet, cMensaje,cHomoclave;
   END IF;

LET cNombre = TRIM(UPPER(pNombre));

    FOR I = 1 TO LENGTH(cNombre)
       LET cCaracter = SUBSTR(cNombre,I,1);
       
       SELECT homoclave
         INTO cValor
         FROM bdinteg:si_digito_valor_rfc
        WHERE letra = cCaracter
          AND empresa = pEmpresa;
          
       IF NVL(cValor,"") <> "" THEN
           LET cNom_numerico = TRIM(cNom_numerico) || TRIM(cValor);
       ELSE
           IF cCaracter IN ("Ñ","ñ","&") THEN
               LET cNom_numerico = cNom_numerico || "10";
           ELIF cCaracter = " " THEN
               LET cNom_numerico = cNom_numerico || "00";
           ELIF (cCaracter BETWEEN "0" AND "9") THEN
               LET cNom_numerico = cNom_numerico || "0" || cCaracter;
           END IF;
       END IF;
       
    END FOR;
   
   FOR I = 1 TO LENGTH(cNom_numerico)-1
       LET iValor1 = CAST(SUBSTR(cNom_numerico,I,2) AS INTEGER);
       LET iValor2 = CAST(SUBSTR(cNom_numerico,(I+1),1) AS INTEGER);
       LET iTotal = iTotal + (iValor1 * iValor2);
   END FOR;

   LET iTotal_1 = MOD(iTotal,1000);
   LET iTotal_2 = MOD(iTotal_1,34);
   LET iTotal_1 = (iTotal_1 - iTotal_2) / 34 ;

       SELECT homoclave
         INTO cDigito1
         FROM si_homoclave_rfc
        WHERE id_valor = (iTotal_1)
          AND empresa = pEmpresa;

       SELECT homoclave
         INTO cDigito2
         FROM si_homoclave_rfc
        WHERE id_valor = (iTotal_2)
          AND empresa = pEmpresa; 

       IF NVL(cDigito1,"") = "" OR  NVL(cDigito2,"") = "" THEN
           LET vCodRet = "000002";
           LET cMensaje = "Error al obtener el dígito de homoclave.";
           RETURN vCodRet, cMensaje,cHomoclave;
       END IF;

       LET cHomoclave = TRIM(cHomoclave) || TRIM(cDigito1) || TRIM(cDigito2);


RETURN vCodRet, cMensaje,cHomoclave;

END;
END PROCEDURE
DOCUMENT
"Descripción: Se crea procedimiento para generar los dígitos de homoclave para el RFC de un cliente",
"BD: bdinteg",
"Fecha: 07-Abril-2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_validaabreviaturasrfc(pEmpresa CHAR(3),pPalabra VARCHAR(100,1))
RETURNING  VARCHAR(6,1)  AS cod_ret,
           VARCHAR(80,1) AS mensaje_ret;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE vErrorInfo    VARCHAR(80,1);
DEFINE vCodRet       VARCHAR(6,1); 
DEFINE vMensajeRet   VARCHAR(80,1);

DEFINE cPalabra      VARCHAR(100,1);
DEFINE sExiste       SMALLINT;

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET vErrorInfo       = "";
LET vCodRet          = "000000";
LET vMensajeRet      = "Se ejecutó el proceso correctamente";

LET cPalabra         = "";
LET sExiste          = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET vMensajeRet= vErrorInfo;
      RETURN vCodRet, vMensajeRet;
   END IF;
END EXCEPTION;

  --SET DEBUG FILE TO "/home/sysifx/viridiana/sp_valida_abreviaturas.out";
  --TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pPalabra,"") = "" THEN
  LET vCodRet     = "000001";
  LET vMensajeRet = "Los datos no se proporcionaron correctamente.";
  RETURN vCodRet, vMensajeRet;
END IF;

LET cPalabra = UPPER(TRIM(pPalabra));

SELECT COUNT(abreviatura)
  INTO sExiste
  FROM bdinteg:si_palabras_invalidas_rfc
 WHERE empresa = pEmpresa
   AND abreviatura = cPalabra
   AND id_tipo = "03";

IF sExiste > 0 THEN
   LET vCodRet     = "000002";
   LET vMensajeRet = "La palabra corresponde a una abreviatura";
   RETURN vCodRet, vMensajeRet;
END IF;

   RETURN vCodRet, vMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para validar',
'si la palabra contiene abreviaturas',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 07/Abril/2009',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_validaapellidorfc(pEmpresa CHAR(3),pApellido VARCHAR(26))
RETURNING  VARCHAR(6,1)  AS cod_ret,
           VARCHAR(80,1) AS mensaje_ret;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE vErrorInfo    VARCHAR(80,1);
DEFINE vCodRet       VARCHAR(6,1); 
DEFINE vMensajeRet   VARCHAR(80,1);

DEFINE cApellido     VARCHAR(26);
DEFINE sExiste       SMALLINT;

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET vErrorInfo       = "";
LET vCodRet          = "000000";
LET vMensajeRet      = "Se ejecutó el proceso correctamente";

LET sExiste          = 0;
LET cApellido        = UPPER(TRIM(pApellido));

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET vMensajeRet= vErrorInfo;
      RETURN vCodRet, vMensajeRet;
   END IF;
END EXCEPTION;

  --SET DEBUG FILE TO "/home/sysifx/viridiana/sp_valida_abreviaturas.out";
  --TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pApellido,"") = "" THEN
  LET vCodRet     = "000001";
  LET vMensajeRet = "Los datos no se proporcionaron correctamente.";
  RETURN vCodRet, vMensajeRet;
END IF;

SELECT COUNT(abreviatura)
  INTO sExiste
  FROM bdinteg:si_palabras_invalidas_rfc
 WHERE empresa = pEmpresa
   AND abreviatura = cApellido
   AND id_tipo = "02";

IF sExiste > 0 THEN
   LET vCodRet     = "000002";
   LET vMensajeRet = "El apellido proporcionado no es válido";
   RETURN vCodRet, vMensajeRet;
END IF;

   RETURN vCodRet, vMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Descripción: Se realiza procedimiento para validar',
'si un nombre proporcionado es correcto.',
'Autor : Viridiana Osobampo Aguilar',
'Fecha : 25/MARZO/2009',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_validacaracteresespecialesrfc(pEmpresa CHAR(3),pPalabra VARCHAR(100,1))
RETURNING  VARCHAR(6,1)  AS cod_ret,
           VARCHAR(80,1) AS mensaje_ret;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE vErrorInfo    VARCHAR(80,1);
DEFINE vCodRet       VARCHAR(6,1); 
DEFINE vMensajeRet   VARCHAR(80,1);

DEFINE cPalabra      VARCHAR(100,1);
DEFINE cLetra        CHAR(1);
DEFINE iLongitud     INTEGER;

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET vErrorInfo       = "";
LET vCodRet          = "000000";
LET vMensajeRet      = "Se ejecutó el proceso correctamente";

LET cPalabra         = "";
LET cLetra           = "";
LET iLongitud        = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET vMensajeRet= vErrorInfo;
      RETURN vCodRet, vMensajeRet;
   END IF;
END EXCEPTION;

 -- SET DEBUG FILE TO "/tmp/validacaracteresespecialesrfc.out";
 -- TRACE ON;

IF pPalabra IS NULL THEN
  LET vCodRet     = "000001";
  LET vMensajeRet = "Es necesario indicar una palabra";
  RETURN vCodRet, vMensajeRet;
END IF;

LET cPalabra = TRIM(pPalabra);

WHILE iLongitud <= LENGTH(cPalabra) + 1

    LET cLetra = SUBSTR(cPalabra,iLongitud,1);

    IF cLetra <> "" THEN
        IF NOT ((cLETRA BETWEEN "A" AND "Z") OR (cLETRA BETWEEN "a" AND "z") OR (cLETRA IN ("Ñ","ñ"," ")) OR (cLETRA BETWEEN "0" AND "9")) THEN
            LET vCodRet     = "000002";
            LET vMensajeRet = "La palabra contiene un caracter que no es letra";
            RETURN vCodRet, vMensajeRet;
        END IF;
    END IF;

    LET iLongitud = iLongitud + 1;

END WHILE;

    RETURN vCodRet, vMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Descripción: Se realiza procedimiento para validar',
'que la palabra solo contenga letras',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 25/MARZO/2009',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_validaexistepalabraaltisonanterfc(pEmpresa CHAR(3),pPalabra VARCHAR(100))
RETURNING CHAR(6)      AS retorno,
          VARCHAR(100) AS mensaje;

-- Variables de proceso
DEFINE cPalabara     VARCHAR(100);
DEFINE vMensajeRet  VARCHAR(100);
DEFINE iExiste      SMALLINT;

-- Control de errores
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vErrorInfo   VARCHAR(80);
DEFINE vCodRet      CHAR(6);

-- Variables de proceso
LET cPalabara    = "";
LET vMensajeRet = "La palabra no es altisonante";
LET iExiste     = 0;

-- Control de errores
LET iSqlErr     = 0;
LET iIsamErr    = 0;
LET vErrorInfo  = "";
LET vCodRet     = "000000";


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet = iSqlErr;
      LET vMensajeRet = vErrorInfo;
      RETURN vCodRet, vMensajeRet;
   END IF;
END EXCEPTION;

 -- SET DEBUG FILE TO "/home/sysifx/viridiana/sp_validaexistepalabraaltisonanterfc.out";
 -- TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pPalabra,"") = "" THEN
   LET vCodRet = "000001";
   LET vMensajeRet = "Los datos proporcionados son incorrectos";
   RETURN vCodRet, vMensajeRet;
END IF;

LET cPalabara = UPPER(TRIM(pPalabra));

SELECT COUNT(abreviatura)
  INTO iExiste
  FROM bdinteg:si_palabras_invalidas_rfc
 WHERE empresa = pEmpresa
   AND abreviatura = cPalabara
   AND id_tipo = "04";

IF iExiste > 0 THEN
   LET vCodRet = "000002";
   LET vMensajeRet = "La palabra indicada es altisonante";
END IF;

RETURN vCodRet, vMensajeRet;

END
END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que valida si una palabra es altisonante",
"BD: bdinteg",
"Fecha: 06-Abril-2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_validanombrerfc(pEmpresa CHAR(3),pNombre VARCHAR(26))
RETURNING  VARCHAR(6,1)  AS cod_ret,
           VARCHAR(80,1) AS mensaje_ret;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE vErrorInfo    VARCHAR(80,1);
DEFINE vCodRet       VARCHAR(6,1); 
DEFINE vMensajeRet   VARCHAR(80,1);

DEFINE cNombre      VARCHAR(53,1);
DEFINE sExiste       SMALLINT;

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET vErrorInfo       = "";
LET vCodRet          = "000000";
LET vMensajeRet      = "Se ejecutó el proceso correctamente";

LET sExiste          = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET vMensajeRet= vErrorInfo;
      RETURN vCodRet, vMensajeRet;
   END IF;
END EXCEPTION;

  --SET DEBUG FILE TO "/home/sysifx/viridiana/sp_valida_abreviaturas.out";
  --TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pNombre,"") = "" THEN
  LET vCodRet     = "000001";
  LET vMensajeRet = "Los datos no se proporcionaron correctamente.";
  RETURN vCodRet, vMensajeRet;
END IF;

LET cNombre = UPPER(TRIM(pNombre));

SELECT COUNT(abreviatura)
  INTO sExiste
  FROM bdinteg:si_palabras_invalidas_rfc
 WHERE empresa = pEmpresa
   AND abreviatura = cNombre
   AND id_tipo = "01";

IF sExiste > 0 THEN
   LET vCodRet     = "000002";
   LET vMensajeRet = "El nombre no es válido";
   RETURN vCodRet, vMensajeRet;
END IF;

   RETURN vCodRet, vMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Descripción: Se realiza procedimiento para validar',
'si un nombre proporcionado es correcto.',
'Autor : Viridiana Osobampo Aguilar',
'Fecha : 07-Abril-2010',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_validavocalrfc(pEmpresa CHAR(3),pCaracter CHAR(1))
RETURNING CHAR(6),VARCHAR(100);

--Variables de proceso
DEFINE cMensaje   VARCHAR(100);

-- Control de errores
DEFINE vsqlerr  INTEGER;
DEFINE visamerr INTEGER;
DEFINE cCodret  CHAR(6);


--Variables de proceso
LET cMensaje      = "El caracter corresponde a una vocal";

--Control de errores
LET vsqlerr     = 0;
LET visamerr    = 0;
LET cCodret     = "000000";


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET cCodret=vsqlerr;
      RETURN cCodret,cMensaje;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_validavocalrfc";
--TRACE ON;

IF NVL(pEmpresa,"") = "" OR NVL(pCaracter,"") = "" THEN
    LET cCodret  = "000001";
    LET cMensaje = "Los datos no se proporcionaron correctamente.";
    RETURN cCodret,cMensaje;
END IF;

IF UPPER(pCaracter) NOT IN ("A","E","I","O","U") THEN
   LET cCodret = '000002';
   LET cMensaje = "El caracter no es una vocal";
END IF;

RETURN cCodret,cMensaje;
END
END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que recibe un caracter y valida si es una vocal.",
"BD: bdinteg",
"Fecha: 06-Abril-2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_valfecha_banca(pCodPais 	  CHAR(3),
			    		pPriDiaNaturalMes DATE,
					pDiasBloque       integer)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

-- ***************************************************************************
-- splvalfecha          
-- Version              1.0.0
-- Obejtivo:            Calcula la fecha del mes actual FechaIniMes + DiasBloque - 1
--                      donde Días bloque son número de días hábiles del mes
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
--SE modifico para que se tomen los dias feriados programados por banco no solamente por la banca.
--Modificado por: Alejandro Osuna IZa
--15 de sep de 2009
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;

	--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_valfecha_banca.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque

    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
		LET dFechaActual = pPriDiaNaturalMes + j;
		LET siFeriado = 0;

		IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
	           SELECT COUNT(*) 
		     INTO siFeriado       
		    FROM bdinteg:si_feriado_banca
		    WHERE fecha = dFechaActual
		     AND pais = pCodPais and laborable = "N";
		   IF siFeriado IS NULL OR siFeriado = 0 THEN
		     LET i = i + 1;
		   END IF;
		END IF;
		LET j = j + 1;
    END WHILE

   RETURN '000',dFechaActual;
END
END PROCEDURE
                                                                          
;