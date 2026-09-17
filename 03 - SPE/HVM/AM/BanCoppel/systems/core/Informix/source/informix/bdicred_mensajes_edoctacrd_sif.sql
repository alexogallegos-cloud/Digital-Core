CREATE PROCEDURE "informix".mensajes_edoctacrd_sif(
					   pEmpresa CHAR(3),
			           pCredito CHAR(20),
			           pEmision CHAR(8),
			           pNumRegistros CHAR(1))
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,DECIMAL(14,2),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);

DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			DECIMAL(14,2);
DEFINE v_mensajes 			CHAR(255);
DEFINE v_Registros          SMALLINT;
DEFINE v_edocta             SMALLINT;
DEFINE v_numProducto        CHAR(4);


LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = 0;
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;
LET v_edocta         = 0;
LET v_numProducto    = "";

--SET DEBUG FILE TO "/pisa/leo/mensajes_edocta.out";
--TRACE ON;



BEGIN

    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
    END EXCEPTION ;


    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));


        SELECT num_producto INTO v_numProducto
          FROM bdicred:sd_maecredcrd
         WHERE empresa = pEmpresa
           AND num_credito = pCredito;



            IF EXISTS (SELECT * FROM bdicred:sd_mensajes_edoctacrd where fecha_emision = v_fecha_emision and num_credito = pCredito) THEN

                    FOREACH

                        SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
                        FROM sd_mensajes_edoctacrd a
                        left outer join bdicred:sd_mensajes_mensual_edoctacrd b on a.fecha_emision = b.fecha_emision
                        WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 1 and a.nlinea = 1 and a.num_credito = pCredito AND a.num_producto = v_numProducto
                          and a.num_producto = b.num_producto  
                        UNION ALL
                        select fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
                        INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
                        FROM sd_mensajes_edoctacrd a
                        WHERE a.fecha_emision = v_fecha_emision AND num_credito = pCredito AND a.num_producto = v_numProducto
                        order by 2,3,4

                        LET v_Registros = v_Registros + 1;

                        IF v_Registros <= pNumRegistros THEN
                                CONTINUE FOREACH;
                        END IF

                        IF v_num_credito IS NULL THEN
                            LET sCodRet = "185";

                            RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
                        END IF

                        RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
                        WITH RESUME;

                    END FOREACH
            ELSE

                    FOREACH

                        SELECT a.fecha_emision, '',  a.secuencia, a.nlinea, '', a.mensaje
                          INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
                        FROM sd_mensajes_mensual_edoctacrd a
                        WHERE a.fecha_emision = v_fecha_emision AND a.num_producto = v_numProducto
                        order by 3,4

                        LET v_Registros = v_Registros + 1;

                        IF v_Registros <= pNumRegistros THEN
                                CONTINUE FOREACH;
                        END IF

                        IF v_num_credito IS NULL THEN
                            LET sCodRet = "185";

                            RETURN sCodRet, v_fecha_emision, pCredito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
                        END IF

                        RETURN sCodRet, v_fecha_emision, NVL(pCredito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
                        WITH RESUME;

                    END FOREACH

            END IF;

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".obtenperiodos_edocuentacrd(pnum_credito CHAR(20))

RETURNING CHAR(6)  AS codigo_error,
          CHAR(80) AS mensaje_error,
          DATE     AS periodo;

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE v_fecha_emision	DATE;
DEFINE iRegistros       INTEGER;

--INICIALIZO VARIABLES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "";
LET cMensajeRet     = "Periodo obtenido";
LET v_fecha_emision = DATE(1);
LET iRegistros      = 0;

 --SET DEBUG FILE TO "obtenperiodos_edocuentacrd.out";
 --TRACE ON;

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
          RETURN cCodRet, cMensajeRet, v_fecha_emision;
       END IF;
  END EXCEPTION; 

   LET cCodRet = "000000";

    FOREACH  
           SELECT DISTINCT fecha_emision 
             INTO v_fecha_emision
    		 FROM "informix".sd_encabezado_edoctacrd
    		WHERE num_credito = pnum_credito
			ORDER BY fecha_emision DESC

			RETURN cCodRet, cMensajeRet, v_fecha_emision WITH RESUME;

    END FOREACH;

LET iRegistros = DBINFO("sqlca.sqlerrd2");
IF iRegistros  = 0 THEN
    LET cCodRet     = '000002';
    LET cMensajeRet = 'No se obtuvieron periodos para el crédito';
    RETURN cCodRet, cMensajeRet, v_fecha_emision;
END IF;

END;
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'los diferentes periodos de los estados de cuenta reestructurados',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 21/JULIO/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".pie_edoctacrd(cEmpresa CHAR(3), cNumCredito CHAR(20), dFechaEmision DATE)

    RETURNING CHAR(5), DATE, CHAR(20), DECIMAL(8,2), DECIMAL(8,2), DECIMAL(8,2), DECIMAL(8,2),
              DECIMAL(8,2), DECIMAL(14,2);

    -- DECLARACION DE VARIABLES --
    DEFINE sSqlEr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE dFechaDeEmision DATE ;
    DEFINE cNumeroCredito CHAR(20);
    DEFINE cTasaAnual DECIMAL(8,2);
    DEFINE cTasaMensual DECIMAL(8,2);
    DEFINE dcTasaMoraAnual DECIMAL(8,2);
    DEFINE dcTasaMoraMensual DECIMAL(8,2);
    DEFINE cCat DECIMAL(8,2);
    DEFINE cSaldoInsoluto DECIMAL(14,2);

    -- INICIALIZACION DE VARIABLES --
    LET sSqlEr = 0;
    LET cCodRet = '000';
    LET dFechaDeEmision = '';
    LET cNumeroCredito = '';
    LET cTasaAnual = 0;
    LET cTasaMensual = 0;
    LET dcTasaMoraAnual = 0;
    LET dcTasaMoraMensual = 0;
    LET cCat = 0;
    LET cSaldoInsoluto = 0;

    --SET DEBUG FILE TO "/tmp/pie_edoctacrd.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET sSqlEr
            LET cCodRet = sSqlEr;
            RETURN cCodRet, dFechaDeEmision, cNumeroCredito, cTasaAnual, cTasaMensual, dcTasaMoraAnual,
                   dcTasaMoraMensual, cCat, cSaldoInsoluto;
        END EXCEPTION;

        --Generacion de Pie del Estado de Cuenta
        SELECT fecha_emision, num_credito, tasa_anual, tasa_mensual, tasa_mora_anual, tasa_mora_mensual,
               cat, saldo_insoluto
        INTO dFechaDeEmision, cNumeroCredito, cTasaAnual, cTasaMensual, dcTasaMoraAnual, dcTasaMoraMensual,
             cCat, cSaldoInsoluto
        FROM sd_pie_edoctacrd
        WHERE fecha_emision = dFechaEmision AND num_credito = cNumCredito;

        IF cNumeroCredito IS NULL THEN
            LET cCodRet = '185';
            RETURN cCodRet, dFechaDeEmision, cNumeroCredito, cTasaAnual, cTasaMensual, dcTasaMoraAnual,
                   dcTasaMoraMensual, cCat, cSaldoInsoluto;
        END IF

        RETURN cCodRet, dFechaDeEmision, NVL(cNumeroCredito, ""), NVL(cTasaAnual, 0), NVL(cTasaMensual, 0),
               NVL(dcTasaMoraAnual, 0), NVL(dcTasaMoraMensual, 0), NVL(cCat, 0), NVL(cSaldoInsoluto, 0);
    END;
END PROCEDURE
DOCUMENT
"Genera el Pie del Estado de Cuenta de Crédito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_consulta_datos_general_crd(pEmpresa      CHAR(3), 
                                                      pNumCte       CHAR(20),
                                                      pNumCredito   CHAR(20),
                                                      pNombre1      CHAR(26),
                                                      pNombre2      CHAR(26),
                                                      pApellidosPat CHAR(26),
                                                      pApellidosMat CHAR(26))
RETURNING CHAR(6)   AS codigo_retorno,
          CHAR(80)  AS mensaje_retorno,
          CHAR(20)  AS numero_credito,
          CHAR(20)  AS numero_cliente,
          CHAR(40)  AS nombre_producto,
          CHAR(26)  AS nombre1,
          CHAR(26)  AS nombre2,
          CHAR(26)  AS apellido_paterno,
          CHAR(26)  AS apellido_materno;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE cNumCredito   CHAR(20);
DEFINE cNumCte       CHAR(20);
DEFINE cNomProducto  CHAR(40);
DEFINE cNombre1      CHAR(26);
DEFINE cNombre2      CHAR(26);
DEFINE cApellidosPat CHAR(26);
DEFINE cApellidosMat CHAR(26);
DEFINE cRazonSocial  CHAR(60);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '';
LET cMensajeRet   = '';

LET cNumCredito   = '';
LET cNumCte       = '';
LET cNomProducto  = '';

LET cNombre1      = '';
LET cNombre2      = '';
LET cApellidosPat = '';
LET cApellidosMat = '';
LET cRazonSocial  = '';


BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidosPat,''), NVL(cApellidosMat,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consulta_datos_general_crd.out';
--TRACE ON;

LET cCodRet= '000000';
LET cMensajeRet= 'Se realizó la consulta correctamente.';

IF NVL(pNumCte,'') = '' THEN
  LET pNumCte = NULL; 
END IF;

IF NVL(pNumCredito,'') = '' THEN
  LET pNumCredito = NULL;
END IF;

IF NVL(pNombre1,'')= '' THEN
   LET pNombre1= NULL;
ELSE
   LET pNombre1= '%' || TRIM(UPPER(pNombre1)) || '%';
END IF

IF NVL(pNombre2,'')= '' THEN
   LET pNombre2= NULL;
ELSE
   LET pNombre2= '%' || TRIM(UPPER(pNombre2)) || '%';
END IF

IF NVL(pApellidosPat,'') = '' THEN
  LET pApellidosPat = NULL;
ELSE
   LET pApellidosPat= '%' || TRIM(UPPER(pApellidosPat)) || '%';
END IF;

IF NVL(pApellidosMat,'') = '' THEN
  LET pApellidosMat = NULL;
ELSE
   LET pApellidosMat= '%' || TRIM(UPPER(pApellidosMat)) || '%';
END IF;

IF pNumCte IS NULL AND pNumCredito IS NULL AND pNombre1 IS NULL AND pNombre2 IS NULL AND pApellidosPat IS NULL AND pApellidosMat IS NULL THEN
   LET cCodRet= '000001';
   LET cMensajeRet= 'No hay información para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidosPat,''), NVL(cApellidosMat,'');
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;

    IF pNumCredito IS NOT NULL  OR pNumCte IS NOT NULL THEN
    
       FOREACH
           SELECT a.num_credito,
                   a.numcte,
                   c.nombre_prod,
                   TRIM(NVL(nombre1,' ')),  
                   TRIM(NVL(nombre2,' ')), 
                   TRIM(NVL(apell_paterno,' ')), 
                   TRIM(NVL(apell_materno,' ')),
                   TRIM(NVL(razon_social,' '))                   
              INTO cNumCredito,
                   cNumCte,
                   cNomProducto, 
                   cNombre1,
                   cNombre2,
                   cApellidosPat,
                   cApellidosMat,
                   cRazonSocial
              FROM "informix".sd_maecredcrd a,
                   bdinteg:"informix".si_cliente b, 
                   "informix".sd_definicion c
             WHERE c.num_producto = a.num_producto
               AND c.empresa = a.empresa
               AND b.numcte = a.numcte
               AND b.apell_paterno=  b.apell_paterno 
               AND b.apell_materno=  b.apell_materno 
               AND a.empresa = pEmpresa
               AND a.num_credito= (CASE WHEN pNumCredito IS NULL THEN a.num_credito ELSE pNumCredito END)
               AND a.numcte = (CASE WHEN pNumCte IS NULL THEN a.numcte ELSE pNumCte END)
               
               IF cNumCredito IS NOT NULL THEN
    	           LET nrows = nrows+1;
                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidosPat,''), NVL(cApellidosMat,'') WITH RESUME;
               END IF;
       END FOREACH;          
       
    ELIF pApellidosPat IS NOT NULL OR pApellidosMat IS NOT NULL  OR pNombre1 IS NOT NULL OR pNombre2 IS NOT NULL THEN 
         
      FOREACH 
         SELECT b.num_credito,
                a.numcte,
                c.nombre_prod,
                TRIM(NVL(nombre1,' ')),  
                TRIM(NVL(nombre2,' ')), 
                TRIM(NVL(apell_paterno,' ')), 
                TRIM(NVL(apell_materno,' ')),
                TRIM(NVL(razon_social,' '))      
           INTO cNumCredito,
                cNumCte,
                cNomProducto,
                cNombre1,
                cNombre2,
                cApellidosPat,
                cApellidosMat,
                cRazonSocial
           FROM bdinteg:"informix".si_cliente a, 
                "informix".sd_maecredcrd b,
                "informix".sd_definicion c
          WHERE UPPER(a.apell_paterno) LIKE (CASE WHEN pApellidosPat IS NULL THEN UPPER(a.apell_paterno) ELSE pApellidosPat END)
            AND UPPER(a.apell_materno) LIKE (CASE WHEN pApellidosMat IS NULL THEN UPPER(a.apell_materno) ELSE pApellidosMat END)
            AND UPPER(a.nombre1) LIKE (CASE WHEN pNombre1 IS NULL THEN UPPER(a.nombre1) ELSE pNombre1 END)
            AND UPPER(a.nombre2) LIKE (CASE WHEN pNombre2 IS NULL THEN UPPER(a.nombre2) ELSE pNombre2 END)
            AND b.numcte = a.numcte
            AND c.num_producto= b.num_producto
            AND a.empresa= pEmpresa
        
           IF cNumCredito IS NOT NULL THEN
               LET nrows=nrows+1;
               RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidosPat,''), NVL(cApellidosMat,'') WITH RESUME;
           END IF;
           
       END FOREACH;           
    END IF
  
IF nrows = 0 THEN
   LET cCodRet = '000002';
   LET cMensajeRet = 'No hay datos con la información indicada';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), NVL(cNombre1,''), NVL(cNombre2,''), NVL(cApellidosPat,''), NVL(cApellidosMat,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para realizar una consulta general',
'de créditos reestructurados',
'para obtener la información basica del cliente',
'AUTOR : Roque Enrique Solis C.',
'FECHA : 22/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".consctesfircaja(pEmpresa char(3), pNumeroCuenta char(20), pNumeroCliente char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),    -- Codigo de retorno
	char(20),   -- # Cliente
	char(26),   -- Apellido paterno
	char(26),   -- Apellido materno
	char(26),   -- Nombre 1
	char(26),   -- Nombre 2
	char(13),   -- RFC
	char(16),   -- # Tarjeta
	date,    --	Expiracion
	char(4),    -- Producto tarjeta
	money(14,2), -- Limite de retiro maximo por mes
	char(1),    -- Status tarjeta
	char(8),    -- Tipo de cliente
	char(10),   --Fecha de Nacimiento
	char(4),    --Producto de la cuenta
	char(2);    --Parentesco

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	Define vSecuencia char(1);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE Vexpiracion date;
	DEFINE Vprodtarjeta char(4);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vFechaNac char(10);
	DEFINE vProductoCuenta char(4);
	DEFINE vCantReg smallint;
	DEFINE vParentesco char(2);

--set debug file to "/respaldosbd/consctesfircaja.out";
--trace on;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;


	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;
	LET vTipCte = "";
	LET vNumCte = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	LET vNumTarj = "";
	LET Vexpiracion = "";
	LET Vprodtarjeta = "";
	LET vLimTar = "";
	LET vTipoCte = "";
	LET vStatTjt = "";
	LET vFechaNac = "";
	LET vProductoCuenta = "";
	LET vParentesco = "";
	LET vSecuencia = "";



		-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --

	FOREACH
		SELECT DISTINCT
			sc_fir.secuencia,si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Firmante' AS tipo_cliente,si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
		INTO
			vSecuencia, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
		FROM
			bdicheq:"informix".sc_maechq sc_mcq,
			bdicheq:"informix".sc_firmantes AS sc_fir,
			bdinteg:"informix".si_cliente AS si_cte,
			bdinteg:"informix".si_ctepf AS si_pf
		WHERE
			--sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte != pNumeroCliente AND
			--sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa AND sc_fir.numcte = si_pf.numcte  AND
			--sc_mcq.empresa = pEmpresa AND sc_mcq.cuenta = pNumeroCuenta
			sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte = si_cte.numcte 
			AND si_cte.empresa = pEmpresa AND sc_fir.numcte = si_pf.numcte  AND
			sc_mcq.empresa = pEmpresa AND sc_mcq.cuenta = pNumeroCuenta
			Order By sc_fir.secuencia


		-- OBTENER LA TARJETA DEL FIRMANTE --

		SELECT DISTINCT
			sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.cuenta = pNumeroCuenta AND
			sc_tjt.numcte = vNumCte AND
			--sc_tjt.status_tar != 'C' AND
			sc_tjt.tipo_tarjeta = 'A';


		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco  WITH RESUME;
	END FOREACH;

	IF vCantReg = 0 THEN
		LET vCodRet  = "000";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET Vexpiracion = "";
		LET Vprodtarjeta = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";
		LET vFechaNac = "";
		LET vParentesco  = "";

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
	END IF
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para que consulte todos los status de tarjetas',
'             incluyendo las tarjetas canceladas',
'EJECUTADO O LLAMADO POR: AsigAdic.exe',
'AUTOR : Martin Eduardo Miranda Miranda',
'FECHA : 14/Septiembre/2010',
'BD    : BDICHEQ',
'DESCRIPCION: Se modifica para que muestre el titular y los firmantes ademas de que se ordene por secuencia',
'AUTOR : Martin Eduardo Miranda Miranda',
'FECHA : 07/abril/2011',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".consnomtitcredcaja(pEmpresa char(3), pTarjeta char(20))

--DATOS A REGRESAR---

RETURNING

char(5), --Codigo de Retorno
char(20), --Numero Cliente
char(20);
--DEFINICION DE VARIABLES--

DEFINE Vcod_Ret         char(5);
DEFINE Vnumcte          char(20);
DEFINE Vnumcta          char(20);
DEFINE vNumProd 		char(4);
DEFINE vCantReg 		INTEGER;

--INICIALIZACION DE VARIABLES--

LET Vcod_Ret ="000";
LET Vnumcte= "";
LET Vnumcta= "";
LET vNumProd = "";
LET vCantReg = "0";

--SET DEBUG FILE TO "/tmp/consnomtitcredcaja.out"; 
--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

  
		SELECT
                num_producto, numcte, num_credito
        INTO
                vNumProd,Vnumcte, Vnumcta
        FROM
               bdicred:"informix".sd_maecred
        WHERE
                empresa = pEmpresa AND num_credito = pTarjeta;


        if vNumProd = "6600" then
            LET Vcod_Ret = "135";
            LET Vnumcte = "";
            LET Vnumcta = "";
            RETURN Vcod_Ret, Vnumcte, Vnumcta;
        end if;


        if Vnumcte <> "" and Vnumcta <> "" then
                let vCantReg = vCantReg +1;
                RETURN Vcod_Ret, Vnumcte, Vnumcta;

        end if


        IF vCantReg = 0 THEN
                LET Vcod_Ret = "224";
                LET Vnumcte = "";
                LET Vnumcta = "";
                RETURN Vcod_Ret, Vnumcte, Vnumcta;
        end if

END PROCEDURE
DOCUMENT
'Creado: Martin Miranda',
'Fecha: 04/05/2011',
'Descripcion: Se crea para obtener consultar el titular de crédito.';

CREATE PROCEDURE "informix".sp_productoscred_reser (pEmpresa CHAR(3), p_num_producto VARCHAR(4) )
RETURNING 	CHAR(6) AS Codigo,       --Codigo de Retorno
			CHAR(4) AS NumProducto,  --Número de Producto
			CHAR(40) AS Descripcion, --Descripción del Producto
			CHAR(4) AS AnioMin; -- Año minimo de la Fecha de cierre
						
--Declaracion de variables
------------------------------------------------------------
DEFINE cCodRet      CHAR(6); 
DEFINE iSqlErr 		INTEGER;
DEFINE cNumProducto CHAR(4);
DEFINE cNomProducto CHAR(40);
DEFINE cActivaCalif CHAR(1);
DEFINE nRows 		INTEGER;
DEFINE cAnioMin     CHAR(4);

--Incialización de variables
------------------------------------------------------------

LET cCodRet='000000';
LET iSqlErr=0;
LET cNumProducto =0;
LET cNomProducto ='';
LET cActivaCalif=0;
LET nRows=0;
LET cAnioMin='';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cNomProducto='Error de Informix';
			RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO "/respaldosbd/Malena/sp_productoscred_reser.out";
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet='000001';
			LET cNomProducto='Debe proporcionar una empresa';
		ELSE	
			SELECT LPAD(YEAR(MIN(fecha_cierre)),4,0)
			INTO cAnioMin
			FROM bdicred:"informix".sd_reporte_calificacion;			
				FOREACH
						SELECT NVL(num_producto,''), NVL(nombre_prod,''), NVL(activa_calif,'') 
						INTO cNumProducto, cNomProducto, cActivaCalif
						FROM bdicred:"informix".sd_definicion 
						WHERE empresa=pEmpresa					
						AND num_producto = (CASE WHEN p_num_producto ='' THEN num_producto ELSE p_num_producto END)
						ORDER BY num_producto
							IF cActivaCalif<>1 AND p_num_producto <> "" THEN 
								LET cCodRet='000002';
								LET cNomProducto='Este producto no esta disponible';
							ELSE 
								RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin WITH RESUME;
							END IF													
				END FOREACH;	
			LET nRows = DBINFO("sqlca.sqlerrd2");
			IF nRows=0 THEN
				LET cCodRet='000003';
				LET cNomProducto='No se obtuvo información de productos';							
			END IF;	
		END IF;
		IF cCodRet <> '000000' THEN 
			RETURN cCodRet,cNumProducto,cNomProducto,cAnioMin;
		END IF;
END;
END PROCEDURE

DOCUMENT
'AUTOR: MARIA ELENA ANGULO AISPURO',
'DESCRIPCION: Se realiza procedimiento para obtener los productos de crédito ordenados que se mostrarán en la pantalla de histórico de reservas, además de  validar si un producto', 
'recibido se encuentre disponible para consultarle su histórico de reservas, ademas se anexa un retorno para obtener el año minimo de la fecha de cierre.',
'BD: BDICRED',
'VERSION: 20110406.0950';

CREATE PROCEDURE "informix".sp_consulta_reporte_calificacion(pEmpresa  	CHAR(3),
																   pProducto   	CHAR(4),
																   pMes         INTEGER,
																   pAnio        INTEGER)

RETURNING   CHAR(6)			 AS cod_ret,
			CHAR(100)      	 AS mensaje_ret,
			CHAR(20)       	 AS grado_riesgo ,
			CHAR(20)       	 AS total_creditos_grado,
			DECIMAL(18,2)   AS saldo_cierre,
			DECIMAL(18,2)   AS reserva_calificacion,
			DECIMAL(18,2)   AS reserva_calif_gradual,
			DECIMAL(18,2)   AS reserva_buro,
			DECIMAL(18,2)   AS reserva_interes,
			DECIMAL(18,2)   AS total_reserva,
			DECIMAL(18,2)   AS sdo_interes_cred_vdos,
			CHAR(20)       	 AS total_ctes_sdo_favor,
			DECIMAL(18,2)  	 AS sdo_cierre_ctes_saldo_favor,
			DECIMAL(18,2)   AS reserva_ctes_sdo_favor,
			CHAR(20)        AS total_ctes_inactivos,
			DECIMAL(18,2)   AS saldo_cierre_ctes_inactivos,
			DECIMAL(18,2)   AS reserva_ctes_inactivos,
			CHAR(20)        AS total_ctes_totaleros,
			DECIMAL(18,2)   AS saldo_cierre_ctes_totaleros


DEFINE iSqlErr      	     		INTEGER;
DEFINE iIsamErr            			INTEGER;
DEFINE cErrorInfo          			CHAR(80);
DEFINE cCodRet            			CHAR(6);
DEFINE cMensajeRet    				CHAR(80);

DEFINE cGradoRiesgo                 CHAR(20);
DEFINE dPorcReserMin                DECIMAL(5,2);
DEFINE dPorcReserMax                DECIMAL(5,2);
DEFINE cNumCreditos                 CHAR(20);
DEFINE dSaldoCierre                 DECIMAL(18,2);

DEFINE dReserCalif                  DECIMAL(18,2);
DEFINE dReserCalifGrad              DECIMAL(18,2);
DEFINE dReserBuro                   DECIMAL(18,2);
DEFINE dReserInt                    DECIMAL(18,2);
DEFINE dTotalReser                  DECIMAL(18,2);

DEFINE dSdoIntsCredVdos             DECIMAL(18,2);
DEFINE cTotalCtesSdoFavor           CHAR(20);
DEFINE dSdoCierreCtesSdoFavor     	DECIMAL(18,2);
DEFINE dReserCtesSdoFavor           DECIMAL(18,2);
DEFINE cCtesInactivos               CHAR(20);

DEFINE dSdoCierreCtesInactivos      DECIMAL(18,2);
DEFINE dReserCtesInactivos          DECIMAL(18,2);
DEFINE cCtesTotaleros               CHAR(20);
DEFINE dSdoCierreCtesTotaleros      DECIMAL(18,2);
DEFINE cMesPeriodo                  CHAR(2);

DEFINE cAnioPeriodo                 CHAR(4);
DEFINE cRiesgoAux                   CHAR(2);
DEFINE sBandTemp                    SMALLINT;
DEFINE sBand_totales				SMALLINT;


LET iSqlErr                 = 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= "";
LET cCodRet              	= "000000";
LET cMensajeRet      		= "Proceso realizado correctamente.";

LET cGradoRiesgo            = "";
LET dPorcReserMin           = 0;
LET dPorcReserMax           = 0;
LET cNumCreditos            = "";
LET dSaldoCierre            = 0;

LET dReserCalif             = 0;
LET dReserCalifGrad         = 0;
LET dReserBuro              = 0;
LET dReserInt               = 0;
LET dTotalReser             = 0;

LET dSdoIntsCredVdos        = 0;
LET cTotalCtesSdoFavor      = 0;
LET dSdoCierreCtesSdoFavor  = 0;
LET dReserCtesSdoFavor      = 0;
LET cCtesInactivos          = 0;

LET dSdoCierreCtesInactivos = 0;
LET dReserCtesInactivos     = 0;
LET cCtesTotaleros          = 0;
LET dSdoCierreCtesTotaleros = 0;
LET cMesPeriodo             = "";

LET cAnioPeriodo            = "";
LET cRiesgoAux              = "";
LET sBandTemp               = 0;
LET sBand_totales			= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      IF sBandTemp = 1 THEN
            DROP TABLE tmp_sdo_ret_totales;
      END IF;
      RETURN cCodRet, cMensajeRet, cGradoRiesgo, cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                        dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                        dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros;
END EXCEPTION;

            --SET DEBUG FILE TO "/respaldosbd/viridiana/sp_consulta_reporte_calificacion.out";
            --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pempresa,"") = "" OR NVL(pMes,0) = 0  OR NVL(pAnio,0) = 0 THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "No se han proporcionado correctamente los datos de entrada.";
	RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
					NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
					NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
					NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
					NVL(dSdoCierreCtesTotaleros,0);
END IF;

IF NOT EXISTS(SELECT empresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa) THEN
        LET cCodRet = "000002";
        LET cMensajeRet = "La empresa proporcionada no existe.";
        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0);
END IF;

LET cMesPeriodo    = LPAD(pMes, 2, 0);
LET cAnioPeriodo   = LPAD(pAnio, 4,0);

IF EXISTS(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmpConsMonitor') THEN
        DROP TABLE tmp_sdo_ret_totales;
END IF;

                CREATE temp table tmp_sdo_ret_totales
                (
					grado_riesgo					CHAR(20),
					num_creditos                    INTEGER,
					saldo_cierre                    DECIMAL(18,2),
					reserva_calif                   DECIMAL(18,2),
					reserva_calif_gradual           DECIMAL(18,2),
					reserva_buro                    DECIMAL(18,2),
					reserva_interes                 DECIMAL(18,2),
					total_reserva                   DECIMAL(18,2),
					saldo_ints_cred_vdos            DECIMAL(18,2),
					num_clientes_saldo_favor        INTEGER,
					saldo_cierre_ctes_saldo_favor   DECIMAL(18,2),
					reserva_ctes_sdo_favor          DECIMAL(18,2),
					num_clientes_inactivos          INTEGER,
					saldo_cierre_ctes_inactivos     DECIMAL(18,2),
					reserva_ctes_inactivos          DECIMAL(18,2),
					numero_clientes_totaleros       INTEGER,
					saldo_cierre_ctes_totaleros     DECIMAL(18,2),
					bandera_totales					SMALLINT
                );

LET sBandTemp = 1;

            FOREACH
					SELECT grado_riesgo,
							porcentaje_reserva_min,
							porcentaje_reserva_max,
							num_creditos,
							saldo_cierre,
							reserva_calif,
							reserva_calif_gradual,
							reserva_buro,
							reserva_interes,
							total_reserva,
							saldo_ints_cred_vdos,
							num_clientes_saldo_favor,
							saldo_cierre_ctes_saldo_favor,
							reserva_ctes_sdo_favor,
							num_clientes_inactivos,
							saldo_cierre_ctes_inactivos,
							reserva_ctes_inactivos,
							numero_clientes_totaleros,
							saldo_cierre_ctes_totaleros
					  INTO cGradoRiesgo,
							dPorcReserMin,
							dPorcReserMax,
							cNumCreditos,
							dSaldoCierre,
							dReserCalif,
							dReserCalifGrad,
							dReserBuro,
							dReserInt,
							dTotalReser,
							dSdoIntsCredVdos,
							cTotalCtesSdoFavor,
							dSdoCierreCtesSdoFavor,
							dReserCtesSdoFavor,
							cCtesInactivos,
							dSdoCierreCtesInactivos,
							dReserCtesInactivos,
							cCtesTotaleros,
							dSdoCierreCtesTotaleros
					 FROM bdicred:sd_reporte_calificacion
				   WHERE producto = pProducto
					  AND month(fecha_cierre) = cMesPeriodo
					  AND year(fecha_cierre)   = cAnioPeriodo
				ORDER BY grado_riesgo, porcentaje_reserva_min

                   IF cRiesgoAux <> cGradoRiesgo THEN
                       LET cRiesgoAux = cGradoRiesgo;
					   LET sBand_totales=1;
					   
						 INSERT INTO tmp_sdo_ret_totales
							   SELECT grado_riesgo, sum(num_creditos::int), sum(saldo_cierre), sum(reserva_calif), sum(reserva_calif_gradual), sum(reserva_buro),
										sum(reserva_interes), sum(total_reserva), sum(saldo_ints_cred_vdos), sum(num_clientes_saldo_favor::int),sum(saldo_cierre_ctes_saldo_favor),
										sum(reserva_ctes_sdo_favor), sum(num_clientes_inactivos::int), sum(saldo_cierre_ctes_inactivos),sum(reserva_ctes_inactivos),
										sum(numero_clientes_totaleros::int), sum(saldo_cierre_ctes_totaleros),sBand_totales
								FROM bdicred:sd_reporte_calificacion 
							  WHERE grado_riesgo=cGradoRiesgo 
								 AND month(fecha_cierre) = cMesPeriodo
								 AND year(fecha_cierre)  = cAnioPeriodo
							   GROUP BY grado_riesgo;
								
							LET sBand_totales=0;
                   END IF;
				   
				   IF cGradoRiesgo='B1' AND dPorcReserMin='2.68' AND dPorcReserMax='2.68' THEN
						LET cGradoRiesgo = "INACT-B1";
				   ELSE
						LET cGradoRiesgo = "De" ||" "|| dPorcReserMin ||" "|| "A" ||" "||dPorcReserMax;
				   END IF;
				   
                   INSERT INTO tmp_sdo_ret_totales
                        VALUES (cGradoRiesgo,cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                                 dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                                 dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros,sBand_totales);
            END FOREACH;

IF dbinfo("sqlca.sqlerrd2") = 0 THEN

        LET cCodRet = "000003";
        LET cMensajeRet = "No existe información de calificación para el período indicado.";

        DROP TABLE tmp_sdo_ret_totales;

        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0);
END IF;

             INSERT INTO tmp_sdo_ret_totales
                SELECT "Total General", sum(num_creditos), sum(saldo_cierre), sum(reserva_calif), sum(reserva_calif_gradual), sum(reserva_buro),
                                sum(reserva_interes), sum(total_reserva), sum(saldo_ints_cred_vdos), sum(num_clientes_saldo_favor),sum(saldo_cierre_ctes_saldo_favor),
                                sum(reserva_ctes_sdo_favor), sum(num_clientes_inactivos), sum(saldo_cierre_ctes_inactivos),sum(reserva_ctes_inactivos),
                                sum(numero_clientes_totaleros), sum(saldo_cierre_ctes_totaleros),sBand_totales
                  FROM tmp_sdo_ret_totales WHERE bandera_totales=1;

FOREACH

        SELECT grado_riesgo, num_creditos, saldo_cierre, reserva_calif, reserva_calif_gradual, reserva_buro, reserva_interes, total_reserva,
                        saldo_ints_cred_vdos, num_clientes_saldo_favor,saldo_cierre_ctes_saldo_favor, reserva_ctes_sdo_favor,num_clientes_inactivos,
                        saldo_cierre_ctes_inactivos,reserva_ctes_inactivos,numero_clientes_totaleros, saldo_cierre_ctes_totaleros
             INTO cGradoRiesgo, cNumCreditos,dSaldoCierre, dReserCalif, dReserCalifGrad, dReserBuro, dReserInt, dTotalReser,
                       dSdoIntsCredVdos, cTotalCtesSdoFavor, dSdoCierreCtesSdoFavor, dReserCtesSdoFavor, cCtesInactivos, dSdoCierreCtesInactivos,
                       dReserCtesInactivos, cCtesTotaleros, dSdoCierreCtesTotaleros
           FROM tmp_sdo_ret_totales


        RETURN NVL(cCodRet,""), NVL(cMensajeRet,""),NVL( cGradoRiesgo,""), NVL(cNumCreditos,""),NVL(dSaldoCierre,0),
                        NVL(dReserCalif,0), NVL(dReserCalifGrad,0), NVL(dReserBuro,0), NVL(dReserInt,0), NVL(dTotalReser,0),
                        NVL(dSdoIntsCredVdos,0), NVL(cTotalCtesSdoFavor,""), NVL(dSdoCierreCtesSdoFavor,0), NVL(dReserCtesSdoFavor,0),
                        NVL(cCtesInactivos,""), NVL(dSdoCierreCtesInactivos,0), NVL(dReserCtesInactivos,0), NVL(cCtesTotaleros,""),
                        NVL(dSdoCierreCtesTotaleros,0) WITH RESUME;

END FOREACH;


DROP TABLE tmp_sdo_ret_totales;

END

END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que obtiene la información de calificación de reserva procesada al día de cierre, en base a un mes y año proporcionado.",
"Autor: Viridiana Osobampo A.",
"BD: bdicred",
"Fecha: 01-04-2011";

CREATE PROCEDURE "informix".sp_mueve_amortiza_fecha(pEmpresa char(3), pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE cnumcredito  char(20);
    DEFINE ccontador    integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    define pmovtos      integer;
    DEFINE vrowid       integer;
--    DEFINE pfecha	date;    

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      LET cMensaje="Error informix";
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   let vrowid       = 0;
   LET ccontador=0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000';
   let pmovtos = 0;

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdia.out";
-- TRACE ON;

   LET cCodRet='000';
   set isolation to dirty read;
   set lock mode to wait 3;

--set pdqpriority 15;

   FOREACH cursor_borra WITH HOLD FOR
        select rowid
         into vrowid
        from bdicred:Sd_amortiza_credito
        where empresa = pEmpresa
        and capital_status = '5' 
        and (capital_fecha_pago is null or capital_fecha_pago <= pfecha)
        and fecha_cuota <= pfecha

           BEGIN WORK;
              DELETE FROM bdicred:Sd_amortiza_credito WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
        
           let ccontador = ccontador + 1;


   END FOREACH;
   
   let cMensaje = 'Proceso terminado, registros borrados : '|| ccontador;
  END;
 RETURN cCodRet,cMensaje;

END PROCEDURE;