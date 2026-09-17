CREATE PROCEDURE "informix".sp_cat_consulta_generales(pEmpresa      CHAR(3),
                                                      pTpoCobranza  CHAR(1),
                                                      pCliente      CHAR(20))

RETURNING CHAR(6)                      AS codigo_respuesta,
          CHAR(20)                     AS num_cliente,
          CHAR(53)                     AS nombre,
          CHAR(26)                     AS apellido_paterno,
          CHAR(26)                     AS apellido_materno,
          CHAR(1)                      AS sexo,
          DATE                         AS fecha_nacimiento,
          CHAR(2)                      AS estado_civil,
          CHAR(300)                    AS domicilio_casa,
          CHAR(300)                    AS domicilio_trabajo,
          CHAR(1)                      AS sit_especial,
          SMALLINT                     AS causa,
          CHAR(1)                      AS puntualidad,
          SMALLINT                     AS eficiencia,
          SMALLINT                     AS calificacion,
          INTEGER                      AS ingreso_mensual_cte,
          CHAR(53)                     AS nombre_referencia,
          CHAR(26)                     AS apellido_paterno_referencia1,
          CHAR(26)                     AS apellido_materno_referencia1,
          CHAR(1)                      AS sexo_referencia,
          CHAR(2)                      AS estado_civil_referencia,          
          DATE                         AS fecha_alta_cte,          
          SMALLINT                     AS llamada_programada,
          DATETIME YEAR TO FRACTION    AS fecha_hora_programada,
          SMALLINT                     AS tpo_cte,
          SMALLINT                     AS tpo_logica, 
          CHAR(1)                      AS tpo_cobranza,
          CHAR(8)                      AS empleado_trabajo_ult_vez,
          DATETIME YEAR TO FRACTION    AS fecha_ult_contacto,
          CHAR(1)                      AS status_cte_en_cob_tel,
          DATE                         AS fecha_insercion,
          DATE                         AS fecha_generacion,
          SMALLINT                     AS num_cd_coppel_cte,
          SMALLINT                     AS num_edo_copel_cte,
          SMALLINT                     AS prioridad,          
          INTEGER                      AS keys;

DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 

DEFINE cEmpresa           CHAR(3);
DEFINE cNumCte            CHAR(20);
DEFINE cEjecutivo         CHAR(8);
DEFINE cNombre1           CHAR(26);
DEFINE cNombre2           CHAR(26);
DEFINE cNombre            CHAR(53);
DEFINE cApellPat          CHAR(26);
DEFINE cApellMat          CHAR(26);
DEFINE cSexo              CHAR(1);
DEFINE dtFechaNac         DATE;
DEFINE cEdoCivil          CHAR(2);
DEFINE cHabitaEn          CHAR(2);
DEFINE cDomicilioCasa     CHAR(300);
DEFINE cDomicilioTrabajo  CHAR(300);
DEFINE dtFechaAlta        DATE;
DEFINE sTpoCte            SMALLINT;
DEFINE cPuntualidad       CHAR(1);
DEFINE sEficiencia        SMALLINT;
DEFINE sCalif             SMALLINT;
DEFINE cNumProducto       CHAR(4);
DEFINE cNumCred           CHAR(20);
DEFINE mIngresoMens       MONEY(14,2);
DEFINE mParamIngMens      MONEY(14,2);
DEFINE sIngresoMens       SMALLINT;
DEFINE cNumCteRef         CHAR(20);
DEFINE cNombreRef         CHAR(53);
DEFINE cNombreAux         CHAR(104);
DEFINE cNumCteRefCoppel   CHAR(20);
DEFINE cNombre1Ref        CHAR(26);
DEFINE cNombre2Ref        CHAR(26);
DEFINE cApellPatRef       CHAR(26);
DEFINE cApellMatRef       CHAR(26);
DEFINE cSexoRef           CHAR(1);
DEFINE cEdoCivilRef       CHAR(2);
DEFINE iBanBusqueda       INTEGER;
DEFINE sCodResultado      SMALLINT;
DEFINE dtFechaLlamar      DATETIME YEAR TO DAY;
DEFINE dtHoraLlamar       DATETIME HOUR TO FRACTION;
DEFINE dtFechaHoraLlamar  DATETIME YEAR TO FRACTION;
DEFINE sTpoLogica         SMALLINT;
DEFINE cTpoCob            CHAR(1);
DEFINE dtFechaLlamada     DATETIME YEAR TO FRACTION;
DEFINE cStatusCteCobTel   CHAR(1);
DEFINE dtFechaInsert      DATE;
DEFINE dtFechaGeneracion  DATE;
DEFINE sNumCdCoppel       SMALLINT;
DEFINE sNumEdoCoppel      SMALLINT;
DEFINE sPrioridad         SMALLINT;
DEFINE cStatusCte         CHAR(2);
DEFINE iKeys              INTEGER;
DEFINE cFechaHora         CHAR(50);
DEFINE Vcreditoexterno    CHAR(20);
DEFINE vnumproducto       CHAR(4);


DEFINE cSitCte         CHAR(1);
DEFINE sCausaCte       SMALLINT; 
DEFINE cMensaje_ret    CHAR(80);
DEFINE cNumCredito     CHAR(20);
DEFINE cCodTipCred     CHAR(2);
DEFINE dtFecha         DATE;
DEFINE dMonto          DECIMAL(18,2);
DEFINE iPlazo          INTEGER;
DEFINE dTasa           DECIMAL(9,6);
DEFINE dMonto_sbc      DECIMAL(14,2);  
DEFINE cDescEstatus    CHAR(60);
DEFINE cCausaBloqCred  CHAR(3);
DEFINE cCausaBloqCta   CHAR(50);
DEFINE cIdSitEsp       CHAR(1);
DEFINE cSisEspCte      CHAR(75);
DEFINE dtFechaHoraAux  DATETIME YEAR TO FRACTION;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";

LET cEmpresa           = "";
LET cNumCte            = "";
LET cEjecutivo         = "";
LET cNombre1           = "";
LET cNombre2           = "";
LET cNombre            = "";
LET cApellPat          = "";
LET cApellMat          = "";
LET cSexo              = "";
LET dtFechaNac         = DATE(1);
LET cEdoCivil          = "";
LET cHabitaEn          = "";
LET cDomicilioCasa     = "";
LET cDomicilioTrabajo  = "";
LET dtFechaAlta        = DATE(1);
LET sTpoCte            = 0;
LET cPuntualidad       = "";
LET sEficiencia        = 0;
LET sCalif             = 0;
LET cNumProducto       = "6001";
LET cNumCred           = "";
LET mIngresoMens       = 0;
LET mParamIngMens      = 0;
LET sIngresoMens       = 0;
LET cNumCteRef         = "";
LET cNombreRef         = "";
LET cNombreAux         = "";
LET cNumCteRefCoppel   = "";
LET cNombre1Ref        = "";
LET cNombre2Ref        = "";
LET cApellPatRef       = "";
LET cApellMatRef       = "";
LET cSexoRef           = "";
LET cEdoCivilRef       = "";
LET iBanBusqueda       = 0;
LET sCodResultado      = 0;
LET dtFechaLlamar      = DATE(1);
LET dtHoraLlamar       = DATE(1);
LET dtFechaHoraLlamar  = DATE(1);
LET sTpoLogica         = 0;
LET cTpoCob            = "";
LET dtFechaLlamada     = DATE(1);
LET cStatusCteCobTel   = "0";
LET dtFechaInsert      = DATE(1);
LET dtFechaGeneracion  = DATE(1);
LET sNumCdCoppel       = 0;
LET sNumEdoCoppel      = 0;
LET sPrioridad         = 0;
LET cStatusCte         = "";
LET iKeys              = 0;
LET cFechaHora         = "";


LET cSitCte             = "";
LET sCausaCte           = 0;
LET cMensaje_ret        = "";
LET cNumCredito         = "";
LET cCodTipCred         = "";
LET dtFecha             = DATE(1);
LET dMonto              = 0;
LET iPlazo              = 0;
LET dTasa               = 0;
LET dMonto_sbc          = 0;
LET cDescEstatus        = "";
LET cCausaBloqCred      = "";
LET cCausaBloqCta       = "";
LET cIdSitEsp           = "";
LET cSisEspCte          = "";
LET dtFechaHoraAux      = DATE(1);

BEGIN
 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/Elizabeth/r.out";
 --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se validan los parámetros de ejecución
 SELECT empresa
   INTO cEmpresa
   FROM bdinteg:"informix".si_empresas
  WHERE empresa= pEmpresa;

 IF cEmpresa IS NULL THEN
    LET cCodRet = "101001";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
 END IF;

SELECT {+INDEX(bdisolic:ss_param idx_ss_param)} NVL(valor,0) * 1
  INTO mParamIngMens
  FROM bdisolic:ss_param
 WHERE secuencia = 303 
   AND empresa   = cEmpresa;

IF NVL(mParamIngMens,0) = 0 THEN
    LET cCodRet = "101002";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
END IF;

SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno, fecha_insert --fecha_alta
  INTO cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, dtFechaAlta
  FROM bdinteg:"informix".si_cliente
 WHERE numcte  = pCliente;
   ---AND empresa = cEmpresa;

 IF cNumCte IS NULL THEN
   LET cCodRet = "101003";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
 END IF;

 LET cNombre = TRIM(TRIM(NVL(cNombre1,""))||" "||TRIM(NVL(cNombre2,"")));

SELECT sexo, fecha_nac, estado_civil, habita_en
  INTO cSexo, dtFechaNac, cEdoCivil, cHabitaEn
  FROM bdinteg:"informix".si_ctepf 
 WHERE numcte = cNumCte;

   SELECT {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} REPLACE(TRIM(NVL(edo.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(ciu.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.nombrezonacoppel," ")),',',';')||","||
          REPLACE(TRIM(NVL(cal.nombrecalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numeroextcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numerointcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.rumbozona,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.observaciones,"")),',',';')||","||
          REPLACE(TRIM(NVL(cHabitaEn,"")),',',';'),
          ciu.ciudad_coppel,
          cdc.numeroestado
 INTO cDomicilioCasa, sNumCdCoppel, sNumEdoCoppel
     FROM bdinteg:si_direcciones_actual dir
LEFT JOIN bdinteg:si_estados     edo ON(edo.pais = "001" AND edo.estado = dir.estado)
LEFT JOIN bdinteg:si_ciudades    ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
LEFT JOIN bdinteg:si_catzonas    zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
LEFT JOIN bdinteg:si_catcalles   cal ON(cal.numerocalle  = dir.numerocalle)
LEFT JOIN bdinteg:si_catciudades cdc ON(cdc.numerociudad = dir.numerociudad)
    WHERE dir.numcte    = cNumCte
      AND dir.tipo_dir  = '1';
      /*AND dir.secuencia = (SELECT {+INDEX(bdinteg:si_direccion_actual idx_diract_ctepo)} b.secuencia
                             FROM bdinteg:"informix".si_direcciones_actual b
                            WHERE b.numcte   = dir.numcte
                              AND b.tipo_dir = dir.tipo_dir);*/

   SELECT {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} ""||","||
          REPLACE(TRIM(NVL(edo.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(ciu.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.nombrezonacoppel,"")),',',';')||","||
          REPLACE(TRIM(NVL(cal.nombrecalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numeroextcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numerointcalle,"")),',',';')
     INTO cDomicilioTrabajo
     FROM bdinteg:si_direcciones_actual dir
LEFT JOIN bdinteg:si_estados   edo ON(edo.estado = dir.estado AND edo.pais = "001")
LEFT JOIN bdinteg:si_ciudades  ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
LEFT JOIN bdinteg:si_catzonas  zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
LEFT JOIN bdinteg:si_catcalles cal ON(cal.numerocalle = dir.numerocalle)
    WHERE dir.numcte    = cNumCte
      AND dir.tipo_dir  = '2';
      /*AND dir.secuencia = (SELECT {+INDEX(bdinteg:si_direccion_actual idx_diract_ctepo)} b.secuencia
                             FROM bdinteg:"informix".si_direcciones_actual b
                            WHERE b.numcte   = dir.numcte
                              AND b.tipo_dir = dir.tipo_dir);*/

SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} a.num_credito, a.puntualidad, a.eficiencia, a.calificacion,
       a.tipo_logica, fecha_insert,
       prioridad, status_cliente, keys 
  INTO cNumCred, cPuntualidad, sEficiencia, sCalif,
       sTpoLogica, dtFechaInsert,
       sPrioridad, cStatusCte, iKeys
  FROM "informix".cb_cat_directorio_cte a
 WHERE a.numcte        = cNumCte
   AND a.tipo_cobranza = pTpoCobranza
   AND a.fecha_insert  = (SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} MAX(fecha_insert)
                            FROM "informix".cb_cat_directorio_cte b
                           WHERE b.numcte        = a.numcte
                             AND b.tipo_cobranza = a.tipo_cobranza
                             AND b.fecha_insert  = b.fecha_insert
                             AND b.empresa       = a.empresa)
   AND a.empresa       = cEmpresa;

LET cTpoCob = pTpoCobranza;
LET dtFechaGeneracion = dtFechaInsert;

SELECT ingreso_mensual 
  INTO mIngresoMens
  FROM bdisolic:ss_resum_scor_fin
 WHERE empresa       = cEmpresa
   AND num_solicitud = cNumCred;

   LET sIngresoMens = NVL(mIngresoMens,0) / mParamIngMens;
   
   --seleciona el tipo de producto
   
	select num_producto into vnumproducto
	from bdicred:sd_maecredcrd
	where empresa = cEmpresa and num_credito = cNumCred;

	--si producto es  60011
	if (vnumproducto = 6011) then
	SELECT credito_externo into vcreditoexterno 
	from bdicred:sd_maecredcrd
	where num_credito = cNumCred;
	let cNumCred = Vcreditoexterno;
	end if;
	
IF EXISTS (SELECT {+INDEX(cb_telefonos idx_cons_telefono)} numcte 
             FROM "informix".cb_telefonos
            WHERE numcte         = cNumCte
              AND telefono       = telefono
              AND empresa        = cEmpresa
              AND tipo_telefono  = 4) THEN

    SELECT LIMIT 1 nombre_ref
      INTO cNombreAux
      FROM bdisolic:ss_refpersonales
     WHERE empresa       = cEmpresa
       AND num_solicitud = cNumCred  
       AND numcte        = cNumCte
       AND numcte_ref    = 'R1';

      LET cNombreRef   = SUBSTR(cNombreAux,1,20);
      LET cApellPatRef = SUBSTR(cNombreAux,21,40);
      LET cApellMatRef = SUBSTR(cNombreAux,41,60);
      LET cSexoRef     = "D";
      LET cEdoCivilRef = "D";
END IF;

-- Se obtiene la situación y causa del cliente
SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx5)} a.situacion, a.causa
  INTO cSitCte, sCausaCte
  FROM bdisitesp:"informix".se_ctessitespcte a
 WHERE a.idmovto=(SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx5)} MAX(aux.idmovto)
                   FROM bdisitesp:"informix".se_ctessitespcte aux
		  WHERE aux.idmovto = aux.idmovto
		    AND a.empresa   = aux.empresa
		    AND a.numcte    = aux.numcte)
  AND a.empresa   = cEmpresa
  AND a.numcte    = cNumCte;

/*
SELECT {+INDEX(cb_cat_resultado_llamada idx_cb_cat_resultado_llamada), +INDEX(cb_cat_tipo_resultado idx_cat_tipo_resultado)} DECODE(r.genera_llamada,"S",1,0),a.fecha_llamar_despues, a.hora_llamar_despues, a.ejecutivo,
       DECODE(r.tipo_llamada,"C",a.fh_movimiento,dtFechaHoraAux)
  INTO sCodResultado, dtFechaLlamar, dtHoraLlamar, cEjecutivo,
       dtFechaLlamada
  FROM bdicobranza:"informix".cb_cat_resultado_llamada a,
       bdicobranza:"informix".cb_cat_tipo_resultado r
 WHERE a.empresa          = cEmpresa
   AND a.tipo_campania    = pTpoCobranza
   AND a.numcte           = cNumCte
   AND a.id_llamada  = (SELECT  {+INDEX(cb_cat_resultado_llamada idx_cb_cat_resultado_llamada)} MAX(id_llamada)
                             FROM bdicobranza:"informix".cb_cat_resultado_llamada b
                            WHERE b.empresa          = a.empresa
                              AND b.tipo_campania    = a.tipo_campania
                              AND b.numcte           = a.numcte
                              ) ---fmj Nov 16 AND b.codigo_resultado = a.codigo_resultado 
   AND r.codigo_resultado = a.codigo_resultado;
*/

    LET sCodResultado = 1;
    IF NVL(sCodResultado,0) = 1 THEN
        LET dtFechaHoraLlamar = NVL(dtFechaLlamar,DATE(1))||" "||NVL(dtHoraLlamar,DATE(1)); 
    END IF;
       


      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 

END
END PROCEDURE
DOCUMENT
'Función para consultar los datos generales del cte',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 29/SEPT/2010',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_carga_resultado_cat( pNomArch CHAR(30))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE cMensaje                     CHAR(80);

DEFINE cCadena                      CHAR(500);
DEFINE vPath                        CHAR(50);

------------------------------------------------------------
-- Creado: Maria Elizabeth anzures
-- Fecha: 01 agosto 2011
-- Crear en BDICOBRANZA

LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
          LET cMensaje = error_info;
			    RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

  --SET DEBUG FILE TO "/home/informix/Elizabeth/importa.out";
  --TRACE ON;
	
            select valor_alfabetico into vPath 
            from bdicobranza:cb_param_campania
            where empresa = '001'
            and tipo_campania = 1
            and grupo_parametro = 'ARCHIVOS'
            and num_parametro = 29;

          LET cCadena = 'echo "load from ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,
		  LENGTH(pNomArch))  || ' insert into bdicobranza:cb_registro_llamadas" >' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
		  
		
  


RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;