CREATE PROCEDURE "informix".sp_cat_cargacartera(pIdCampania CHAR(1))
		RETURNING   
					CHAR(6) AS Codigo;	--codret
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE iTotalTrab		INTEGER;
	DEFINE iTotalNoTrab		INTEGER;


	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET iTotalTrab=0;
	LET iTotalNoTrab=0;
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_cargacartera.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			RETURN cCodRet WITH RESUME;
		END EXCEPTION;		
		
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	-- Se obtiene el total de clientes trabajados
		SELECT COUNT(numcte) 
		INTO iTotalTrab
		FROM cb_cat_directorio_cte
		WHERE status_cliente in ('PR','EX') 
		AND tipo_cobranza=pIdCampania;
		
	--Se obtiene el total de clientes no trabajados
		SELECT COUNT(numcte) 
		INTO iTotalNoTrab
		FROM cb_cat_directorio_cte
		WHERE status_cliente in ('AC','IN','LD','EP')
		AND tipo_cobranza=pIdCampania;
							
		--Se insertan los datos en la tabla  cb_cat_compctes
		DELETE FROM cb_cat_compctes;
				INSERT INTO bdicobranza:cb_cat_compctes(IdCampania,IdConcepto,Descripcion,Cantidad) VALUES (pIdCampania,1,'Trabajados',iTotalTrab);
				INSERT INTO bdicobranza:cb_cat_compctes(IdCampania,IdConcepto,Descripcion,Cantidad) VALUES (pIdCampania,2,'No Trabajados',iTotalNoTrab);
		RETURN cCodRet;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se almacena en registros los clientes trabajados y clientes no trabajados en la tabla cb_cat_compctes',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1043',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_consulta_pagos_tc(pEmpresa      CHAR(3),
                                                     pNumCredito   CHAR(20),
                                                     pNumReg       INTEGER)

RETURNING   CHAR(6)          AS cod_ret,
            CHAR(16)         AS folio_suc,
            DATE             AS fecha_pago,
            CHAR(20)         AS num_credito,
            DECIMAL(18,2)    AS importe;
            
-- Declaración de variables
DEFINE cCodRet          CHAR(6);
DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;

DEFINE cMensajeRet      CHAR(80);
DEFINE cNumCredito      CHAR(20);
DEFINE dtFechaPago      DATE;
DEFINE dCapital_vig     DECIMAL(18,2);
DEFINE dCapital_venc    DECIMAL(18,2);
DEFINE dInteres_vig     DECIMAL(18,2);
DEFINE dIva_int_vig     DECIMAL(18,2);
DEFINE dInt_orden_abono DECIMAL(18,2);
DEFINE dIva_orden_abono DECIMAL(18,2);
DEFINE dInteres_mora    DECIMAL(18,2);
DEFINE dIva_mora        DECIMAL(18,2);
DEFINE dImporte         DECIMAL(18,2);
DEFINE cFolioSuc        CHAR(16);
DEFINE iRegistros       INTEGER;
DEFINE iExiste          SMALLINT;
DEFINE iTotal_pagos     INTEGER;

-- Inicializacíón de variables
LET cCodRet             = "000000";
LET iSqlErr             = 0;
LET iIsamErr            = 0;

LET cMensajeRet         = "";
LET cNumCredito         = "";
LET dtFechaPago         = DATE(1);
LET dCapital_vig        = 0;
LET dCapital_venc       = 0;
LET dInteres_vig        = 0;
LET dIva_int_vig        = 0;
LET dInt_orden_abono    = 0;
LET dIva_orden_abono    = 0;
LET dInteres_mora       = 0;
LET dIva_mora           = 0;
LET dImporte            = 0;
LET cFolioSuc           = "";
LET iRegistros          = 0;
LET iExiste             = 0;
LET iTotal_pagos        = 0;


--SET DEBUG FILE TO "/home/sysifx/sp_cat _consulta_pagos_tc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
          LET cCodRet = iSqlErr;
          RETURN  cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
    END EXCEPTION;
    
    SELECT COUNT(empresa)
      INTO iExiste
      FROM bdinteg:"informix".si_empresas
     WHERE empresa = pEmpresa;

     IF iExiste = 0 THEN
        LET cCodRet = "101001";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
     END IF;

     SELECT COUNT(num_credito)
       INTO iExiste
       FROM bdicred:"informix".sd_maecred
      WHERE empresa = pEmpresa
        AND num_credito = pNumCredito;

     IF iExiste = 0 THEN
        LET cCodRet = "101009";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
     END IF;

     -- Se obtiene el valor del parámetro del número de pagos a tomar en cuenta en
     -- la consulta     
     SELECT valor_numerico
       INTO iTotal_pagos
       FROM bdicobranza:"informix".cb_param_campania
      WHERE empresa = pEmpresa
        AND tipo_campania = "1"
        AND grupo_parametro = "PAGOS"
        AND num_parametro = 1;

      IF NVL(iTotal_pagos,0) = 0 THEN
        LET cCodRet = "101010";
        RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte;
      END IF;      


     FOREACH
            EXECUTE PROCEDURE bdicred:"informix".sp_consulta_pagos_recibidos_general(pEmpresa, pNumCredito)
                         INTO   cCodRet, 
                                cMensajeRet,
                                cNumCredito,
                                dtFechaPago,
                                dCapital_vig,
                                dCapital_venc,
                                dInteres_vig,
                                dIva_int_vig,
                                dInt_orden_abono,
                                dIva_orden_abono,
                                dInteres_mora,
                                dIva_mora,
                                dImporte,
                                cFolioSuc

            IF cCodRet <> "000000" THEN
                LET cCodRet = "101011"; --Error al consultar los pagos realizados al crédito.
                RETURN cCodRet, cFolioSuc, dtFechaPago, cNumCredito, dImporte;
            END IF;
            
            LET iRegistros = iRegistros  + 1;
            IF iRegistros <= iTotal_pagos THEN
                IF iRegistros  > pNumReg THEN
                    EXIT FOREACH;
                END IF;
            ELSE
                EXIT FOREACH;
            END IF;

            RETURN cCodRet, cFolioSuc,dtFechaPago, cNumCredito, dImporte WITH RESUME;                              
     END FOREACH;

END

END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que obtiene los pagos realizados a un crédito.",
"BD: bdicobranza",
"Autor: Viridiana Osobampo Aguilar",
"Fecha: 29-Sep-2010";

CREATE PROCEDURE "informix".sp_cat_tpsresultado()
		RETURNING CHAR(6), smallint,CHAR(100);

	DEFINE cCodRet				CHAR(6);
	DEFINE iCont				INTEGER;
	DEFINE iSqlErr				INTEGER;
	DEFINE sCod_Result				SMALLINT;
	DEFINE cDescripcion			Char(100); 
	

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont= 0;
	LET sCod_Result = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_tpsresultado.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET sCod_Result = 0;
			LET cDescripcion = '';
			RETURN cCodRet,sCod_Result,cDescripcion;
		END EXCEPTION;

	set isolation to dirty read;

		FOREACH
			SELECT codigo_resultado,descripcion
			INTO sCod_Result,cDescripcion
			FROM Bdicobranza: cb_cat_tipo_resultado  
			LET icont=icont+1;
            RETURN cCodret,sCod_Result,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET sCod_Result = 0;
			LET cDescripcion = 'No hay Información en la tabla cb_cat_tipo_resultado';
            RETURN cCodret,sCod_Result,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de los tipos de resultados del cliente de la tabla cb_cat_tipo_resultado',
'FECHA       : 01 de Octubre de 2010',
'VERSION     : 20101001.1115',
'BD          : BDICOBRANZA';

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