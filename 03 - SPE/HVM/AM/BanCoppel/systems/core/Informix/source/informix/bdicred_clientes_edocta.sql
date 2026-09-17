CREATE PROCEDURE "informix".clientes_edocta (pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE)

RETURNING
CHAR(5),        -- Retorno
DATE,           -- Fecha Emision
CHAR(20),       -- Numero de Credito
CHAR(20),       -- Numero de Cliente
CHAR(20),       -- Numero de Tarjeta
CHAR(150),      -- Nombre de Cliente
CHAR(200),      -- Direccion Cliente
CHAR(120),      -- Direccion Colonia
CHAR(120),      -- Direccion
CHAR(120),      -- Estado Ciudad
CHAR(120),      -- Sucursal Nombre
CHAR(150),      -- Sucursal Gerente
CHAR(20),       -- Sucursal Tel
DATE,           -- Fecha Corte
CHAR(5),        -- Codigo Postal
CHAR(60),       -- Clave Cobranza
CHAR(13),       -- RFC
CHAR(47),       -- Clave Ruta
CHAR(40),       -- Entre Calles
CHAR(80),       -- Observaciones
DECIMAL (16,2); -- Saldo

--------------------------------------------------------
--      VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE cod_ret                          CHAR(5);
DEFINE sql_err                          INTEGER;
DEFINE v_cod_ret_otro                   CHAR(5);
DEFINE v_corta_linea_detalle            INTEGER;
DEFINE v_corta_linea_mensaje            INTEGER;
DEFINE v_periodo_anterior               DATE;                   --Fecha Periodo Anterior
DEFINE v_dias_periodo_tc                INTEGER;                --dias_periodo_tc
DEFINE v_periodo_tc_ini                 DATE;                   --periodo_tc_ini
DEFINE v_periodo_tc_fin                 DATE;                   --periodo_tc_fin

--------------------------------------------------------
--      VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_sucursal          CHAR(4);         --Sucursal Cliente
DEFINE v_ult_dir_clie      INTEGER;         --Secuencia Ultima Direccion Cliente
--------------------------------------------------------
--      VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
DEFINE v_numcte            CHAR(20);        --Numero de Credito
DEFINE v_num_tarjeta       CHAR(20);        --Numero de Tarjeta
DEFINE v_nombre_cte        CHAR(150);       --Nombre del Cliente
DEFINE v_direccion_cn      CHAR(456);       --Direccion
DEFINE v_direccion_col     CHAR(376);       --Colonia
DEFINE v_direccion_del     CHAR(376);       --Delegacion O Municipio
DEFINE v_edo_cd            CHAR(376);       --Estado
DEFINE v_sucursal_nombre   CHAR(40);        --Nombre de la Sucursal
DEFINE v_sucursal_gerente  CHAR(40);        --Nombre del Gerente del Sucursal
DEFINE v_sucursal_tel      CHAR(14);        --Telefono de la Sucursal
DEFINE v_cod_postal        CHAR(5);         --Codigo Postal Direccion Cliente
DEFINE v_cl_cobra          CHAR(60);        --Clave de Cobranza
DEFINE v_rfc               CHAR(13);        --RFC del Cliente
DEFINE v_ruta              CHAR(47);        --Ruta
DEFINE v_entre_calles      CHAR(40);        --Entre Calles
DEFINE v_observaciones     CHAR(80);        --Datos Complementarios
DEFINE v_saldoactual       DECIMAL (16,2);  --Saldo disponible
DEFINE v_numerociudad      SMALLINT;        --Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia     INT;             --Numero Colonia Direccion Cliente
DEFINE v_numerocalle       INT;             --Numero Calle Direccion Cliente
DEFINE v_numeroextcalle    CHAR(10);        --Numero Exterior Calle Direccion Cliente
DEFINE v_estado            CHAR(2);         --Numero Estado
DEFINE v_nombrecalle       CHAR(30);        --Nombre Calle Catalogo Calles
DEFINE v_centro            INT;             --Centro Catalogo de Zonas
DEFINE v_jefegrupozona     INT;             --Clave Jefe Grupo Zona
DEFINE v_supervisorzona    INT;             --Clave Supervisor Zona
DEFINE v_status_cred       CHAR(2);         --Estado de Credito

--*******************************************************
--*******************************************************
--*******************************************************

--------------------------------------------------------
--      VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "000";
LET v_cod_ret_otro = "000";

LET sql_err = "";
LET v_corta_linea_detalle       = 30;
LET v_corta_linea_mensaje       = 100;

LET v_periodo_anterior          = " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc           = 0;    --dias_periodo_tc

LET v_periodo_tc_ini            = " ";  --periodo_tc_ini
LET v_periodo_tc_fin            = " ";  --periodo_tc_fin

--------------------------------------------------------
--      VARIABLES GENERALES
--------------------------------------------------------
LET v_sucursal      = "";
LET v_ult_dir_clie      = 0;
--------------------------------------------------------
--      VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET v_numcte            = "";
LET v_num_tarjeta       = "";
LET v_nombre_cte        = "";
LET v_direccion_cn      = "";
LET v_direccion_col     = "";
LET v_direccion_del     = "";
LET v_edo_cd            = "";
LET v_sucursal_nombre   = "";
LET v_sucursal_gerente  = "";
LET v_sucursal_tel      = "";
LET v_cod_postal        = "";
LET v_cl_cobra          = "";
LET v_rfc               = "";
LET v_ruta              = "";
LET v_entre_calles      = "";
LET v_observaciones     = "";
LET v_saldoactual       = 0;
LET v_numerociudad      = 0;
LET v_numerocolonia     = 0;
LET v_numerocalle       = 0;
LET v_numeroextcalle    = "";
LET v_estado            = "";
LET v_nombrecalle       = "";
LET v_centro            = 0;
LET v_jefegrupozona     = 0;
LET v_supervisorzona    = 0;

LET v_status_cred = "";

BEGIN

        ON EXCEPTION SET sql_err
        LET cod_ret = sql_err;

                RETURN cod_ret, pfechahoy, NVL(pnum_credito,""), NVL(v_numcte,""),
                NVL(v_num_tarjeta,""), NVL(v_nombre_cte,""), NVL(v_direccion_cn,""),
                NVL(v_direccion_col,""), NVL(v_direccion_del,""), NVL(v_edo_cd,""),
                NVL(v_sucursal_nombre,""), NVL(v_sucursal_gerente,""), NVL(v_sucursal_tel,""),
                pfechahoy, NVL(v_cod_postal,""), NVL(v_cl_cobra,""),
                NVL(v_rfc,""), NVL(v_ruta,""), NVL(v_entre_calles,""),
                NVL(v_observaciones,""), v_saldoactual;
        END EXCEPTION ;

 --##############################################################
          --##    GENERACION ENCABEZADO EDO CUENTA  ##
 --##############################################################
    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
        SELECT a.numcte, a.sucursal
        INTO v_numcte, v_sucursal
        FROM sd_maecred a
        WHERE a.empresa = pempresa
        AND a.num_credito = pnum_credito;
    -------------------------------------------------------------
    --SD_TARJETA
    -------------------------------------------------------------
        SELECT b.num_tarjeta INTO v_num_tarjeta
        FROM sd_tarjeta b
        WHERE b.empresa = pempresa
                AND b.num_credito = pnum_credito
                AND b.tipo_tarjeta = "T" AND b.status_tar = "A";

        IF v_num_tarjeta IS NULL THEN
            -------------------------------------------------------------
                --SD_TARJETA
            -------------------------------------------------------------
                SELECT MAX(secuencia)
                        INTO v_ult_dir_clie
                FROM sd_tarjeta
                WHERE empresa = pempresa
                        AND num_credito = pnum_credito
                        AND tipo_tarjeta="T";

            -------------------------------------------------------------
                --SD_TARJETA
            -------------------------------------------------------------
                SELECT b.num_tarjeta INTO v_num_tarjeta
                FROM sd_tarjeta b
                WHERE b.empresa = pempresa
                    AND b.num_credito = pnum_credito
                    AND b.secuencia = v_ult_dir_clie;

        END IF
    -------------------------------------------------------------
        --SI_DIRECCIONES
    -------------------------------------------------------------
        SELECT MAX(secuencia) INTO v_ult_dir_clie
        FROM bdinteg:si_direcciones
                WHERE numcte = v_numcte
                AND tipo_dir="1";
    -------------------------------------------------------------
        --SI_CLIENTE
    -------------------------------------------------------------
        SELECT Trim(a.nombre1) || " " ||Trim(a.nombre2) || " " ||
                   Trim(a.apell_paterno) || " " ||Trim(a.apell_materno),
               a.rfc
        INTO    v_nombre_cte,
                        v_rfc
        FROM bdinteg:si_cliente a
        WHERE a.numcte = v_numcte;
    -------------------------------------------------------------
        --SI_DIRECCIONES
    -------------------------------------------------------------
        SELECT Trim(b.numeroextcalle) || " " || Trim(b.numerointcalle),
               b.cod_postal,                    b.entre_calles,
               b.observaciones,                 b.numerociudad,
               b.numerocolonia,                 b.numerocalle,
               b.numeroextcalle,                b.estado
        INTO v_direccion_cn,
                   v_cod_postal,                v_entre_calles,
                   v_observaciones,             v_numerociudad,
                   v_numerocolonia,             v_numerocalle,
                   v_numeroextcalle,            v_estado
        FROM bdinteg:si_direcciones b
        WHERE b.numcte  = v_numcte AND secuencia = v_ult_dir_clie;
    -------------------------------------------------------------
        --SI_CATCALLES
    -------------------------------------------------------------
        SELECT Trim(c.nombrecalle)
        INTO v_nombrecalle
        FROM bdinteg:si_catcalles c
        WHERE c.numerocalle = v_numerocalle;
    -------------------------------------------------------------
        --SI_CATZONAS
    -------------------------------------------------------------
        SELECT  d.nombrezona,                    d.centro,
                d.jefegrupozona,                 d.supervisorzona
        INTO    v_direccion_col,                 v_centro,
                v_jefegrupozona,                 v_supervisorzona
        FROM bdinteg:si_catzonas d
        WHERE  d.numerociudad = v_numerociudad
        AND  d.numerocolonia=v_numerocolonia;
    -------------------------------------------------------------
        --SI_CATCIUDADES
    -------------------------------------------------------------
        SELECT e.nombreciudad
        INTO v_direccion_del
        FROM bdinteg:si_catciudades e
        WHERE e.numerociudad = v_numerociudad;
    -------------------------------------------------------------
        --SI_ESTADOS
    -------------------------------------------------------------
        SELECT f.nombre
        INTO v_edo_cd
        FROM bdinteg:si_estados f
        WHERE  f.estado = v_estado;
    -------------------------------------------------------------
        --SI_SUCURSALES
    -------------------------------------------------------------
        SELECT d.nombre, d.gerente, d.telefono1
        INTO v_sucursal_nombre, v_sucursal_gerente, v_sucursal_tel
        FROM bdinteg:si_sucursales d
        WHERE d.empresa = pempresa
        AND   d.sucursal    = v_sucursal;
        --------------------------------------------------------
             --SD_MAESDOS
        --------------------------------------------------------
        SELECT sdo_cap_insoluto
        INTO v_saldoactual
        FROM bdicred:sd_maesdos
        WHERE num_credito = pnum_credito;
        --------------------------------------------------------
        LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
        LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
                             LPAD(v_centro,6,'0')||"/"||
                             LPAD(v_jefegrupozona,8,'0')||"/"||
                             LPAD(v_supervisorzona,8,'0')||"/"||
                             LPAD(v_numerocolonia,4,'0')||"/"||
                             LPAD(v_numerocalle,6,'0')||"/"||
                             LPAD(TRIM(v_numeroextcalle),5,'0');
        --------------------------------------------------------
        --------------------------------------------------------
        --------------------------------------------------------

          RETURN cod_ret, pfechahoy, NVL(pnum_credito,""), NVL(v_numcte,""),
                NVL(v_num_tarjeta,""), NVL(v_nombre_cte,""), NVL(v_direccion_cn,""),
                NVL(v_direccion_col,""), NVL(v_direccion_del,""), NVL(v_edo_cd,""),
                NVL(v_sucursal_nombre,""), NVL(v_sucursal_gerente,""), NVL(v_sucursal_tel,""),
                pfechahoy, NVL(v_cod_postal,""), NVL(v_cl_cobra,""),
                NVL(v_rfc,""), NVL(v_ruta,""), NVL(v_entre_calles,""),
                NVL(v_observaciones,""), v_saldoactual;

END;

END PROCEDURE
DOCUMENT "Version 1.00.000",
"Se agrega consulta de saldo a favor del cliente",
"Responsable : Priscilla Mercado Campaña.",
"Fecha : 29-01-2009",
"Se altera la longitud de la Clave de Cobranza de Max 51 caracteres a Max 60 caracteres",
"Responsable: Raúl Rene Ruiz R.",
"Fecha: 25-02-2009";

CREATE PROCEDURE "informix".determina_udi(pEmpresa CHAR(3),
			       pFecha   DATE)
RETURNING CHAR(5), DECIMAL(14,6);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vValor1	      DECIMAL(14,6);
   DEFINE vValor2      	      DECIMAL(14,6);
   DEFINE vPrecio	      DECIMAL(14,6);
   DEFINE vFechaPaso	      DATE;
   DEFINE vDivUdi	      CHAR(2);
   DEFINE vClaseUdi	      CHAR(1);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio;
   END EXCEPTION;

-- SET DEBUG FILE TO "determina_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vValor1	  = 0;
   LET vValor2	  = 0;
   LET vPrecio	  = 0;
   LET vFechaPaso = "";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
      SELECT TRIM(valor) INTO vDivUdi
	FROM bdinteg:si_param
       WHERE empresa = pEmpresa
	 AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClaseUdi
	FROM sd_param
       WHERE empresa = pEmpresa
	 AND cod_param = "336";


      -- **************
      -- Precio Inicio*
      -- **************
     
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = vDivUdi
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = vDivUdi
                               	  AND fecha_tpcambio = pFecha)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = vDivUdi
                              AND fecha_tpcambio = pFecha)
         AND clase_tpcambio = vClaseUdi;

	IF vValor1 IS NULL THEN
           SELECT precio_compra INTO vValor1
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc <= pFecha)
              AND hora_tc=(SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pEmpresa
                           AND divisa = "09"
                           AND fecha_tc = pFecha)                 
              AND clase_tpcambio = vClaseUdi;

	    IF vValor1 IS NULL THEN
		LET cod_ret = "900";
		RETURN cod_ret, vPrecio;
	    END IF
	END IF

	-- *************
	-- Precio Final*
	-- *************
       IF DAY(pFecha) = 31 AND MONTH(pFecha) IN (5,7,10,12) THEN
	LET pFecha = MONTH(pFecha) || "/30/" || YEAR(pFecha);
       END IF

       IF MONTH(pFecha) = 3 AND DAY(pFecha) > 28 THEN
	LET vFechaPaso = MONTH(pFecha) || "/01/" || YEAR(pFecha);
	LET vFechaPaso = vFechaPaso -1;
	LET pFecha = MONTH(pFecha) || "/" || DAY(vFechaPaso) || "/" ||
		     YEAR(pFecha);
       END IF

       LET pFecha = pFecha ;
       LET pFecha = pFecha -1 UNITS MONTH ;
       SELECT precio_compra INTO vValor2
        FROM bdinteg:si_histdiv
       WHERE empresa = pEmpresa
         AND divisa = "09"
         AND fecha_tc = (SELECT MAX(fecha_tc)
                           FROM bdinteg:si_histdiv
                          WHERE empresa = pEmpresa
                            AND divisa = "09"
          	 	    AND fecha_tc <= pFecha)
          AND hora_tc=(SELECT MAX(hora_tc)
                       FROM bdinteg:si_histdiv
                       WHERE empresa = pEmpresa
                       AND divisa = "09"
                       AND fecha_tc = pFecha)  
         AND clase_tpcambio = vClaseUdi;

	IF vValor2 IS NULL THEN
		LET cod_ret = "901";
		RETURN cod_ret, vPrecio;
	END IF


      -- IF vValor2 < vValor1 THEN
       --  let vPrecio = 0;
      -- ELSE
	   LET vPrecio = (vValor1 / vValor2);
           IF vPrecio > 1 THEN
              LET vPrecio =  vPrecio -1;
           ELSE
              LET vPrecio = 0;
           END IF
     -- END IF;

END
	RETURN cod_ret, vPrecio;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_corrige_insertos(pEmpresa CHAR(3))
RETURNING 
          CHAR(5) AS resultado,
          CHAR(80) AS mensaje;

    DEFINE iSqlErr      	     INTEGER;
    DEFINE iIsamErr              INTEGER;
    DEFINE cErrorInfo            CHAR(80);
    DEFINE cCodRet               CHAR(5); 
    DEFINE cMensajeRet           CHAR(80);
    DEFINE cNumCredito           CHAR(20);
    DEFINE cInsertoNuevo         CHAR(15);
    DEFINE cFechaEmision         DATE;
    DEFINE cPosicion             CHAR(2);

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
        RETURN cCodRet,cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_corrige_insertos";
    --TRACE ON;
    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '00000';
    LET cMensajeRet= 'Se realizó la consulta correctamente';
    LET cNumCredito="";
    LET cInsertoNuevo='000000000000000';
    LET cFechaEmision=MDY('05','20','2009');
    LET cPosicion="";

    FOREACH
        SELECT num_credito,posicion
          INTO cNumCredito,cPosicion
          FROM bdicred:sd_marcaje 
         WHERE empresa=pEmpresa
           AND fecha_emision=date(0)

        IF cPosicion = '10' THEN
            LET cInsertoNuevo = '100000000000000';
        ELIF cPosicion = '00' THEN 
            LET cInsertoNuevo = '000100000000000';
        END IF;

        UPDATE bdicred:sd_marcaje
        SET fecha_emision=cFechaEmision,
            posicion=0,
            insertos=cInsertoNuevo
        WHERE empresa=pEmpresa
          AND num_credito=cNumCredito
          AND fecha_emision=date(0);

        UPDATE bdicred:sd_encabezado_edocta
        SET insertos=cInsertoNuevo
        WHERE num_credito=cNumCredito
          AND fecha_emision=cFechaEmision;
    END FOREACH;
  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;