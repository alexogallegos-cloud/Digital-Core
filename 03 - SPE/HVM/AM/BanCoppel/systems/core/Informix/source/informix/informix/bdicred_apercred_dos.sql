CREATE PROCEDURE "informix".apercred_dos( P_EMPRESA     VARCHAR(3)
                              , P_SOLICITUD     VARCHAR(20)
                              , P_TP_SOL      VARCHAR(2)
                              , P_CAP_CANCEL  DECIMAL(18,2)
                              , P_INT_CANCEL  DECIMAL(18,2)
			      , P_MORA_CANCEL DECIMAL(18,2)
			      , P_COM_CANCEL  DECIMAL(18,2)
                              )
RETURNING VARCHAR(8), VARCHAR(80);

--*****************************
--DECLARACION DE VARIABLES
--*****************************
DEFINE  V_SECUENCIA_MAX  INTEGER;
DEFINE  V_EQ_DIAS        INTEGER;
DEFINE  V_FECHA_PRORR    DATE;
DEFINE  P_ERROR          VARCHAR(8);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  V_FECHA_PROG_MAX DATE;
DEFINE  V_NVA_CIFRA      DECIMAL(18,2);
define vnum_credito      char(20);
define vdigverif         char(1);

DEFINE VVEMPRESA           LIKE BDISOLIC:SS_UNIDADPROD.EMPRESA;
DEFINE VVNUMCTE            LIKE BDISOLIC:SS_UNIDADPROD.NUMCTE;
DEFINE VVSUP_TOTAL         LIKE BDISOLIC:SS_UNIDADPROD.SUP_TOTAL;
DEFINE VVDIRECCION         LIKE BDISOLIC:SS_UNIDADPROD.DIRECCION;
DEFINE VVCIUDAD            LIKE BDISOLIC:SS_UNIDADPROD.CIUDAD;
DEFINE VVASENTAMIENTO      LIKE BDISOLIC:SS_UNIDADPROD.ASENTAMIENTO;
DEFINE VVGRAL_OESTE        LIKE BDISOLIC:SS_UNIDADPROD.GRAL_OESTE;
DEFINE VVPART_OESTE        LIKE BDISOLIC:SS_UNIDADPROD.PART_OESTE;
DEFINE VVLATITUD_OESTE     LIKE BDISOLIC:SS_UNIDADPROD.LATITUD_OESTE;
DEFINE VVCLAS_TENENCIA     LIKE BDISOLIC:SS_UNIDADPROD.CLAS_TENENCIA;
DEFINE VVTENEN_FECHA_INS   LIKE BDISOLIC:SS_UNIDADPROD.TENEN_FECHA_INS;
DEFINE VVNOMBRE_UNIDAD     LIKE BDISOLIC:SS_UNIDADPROD.NOMBRE_UNIDAD;
DEFINE VVSUP_APROVECHABLE  LIKE BDISOLIC:SS_UNIDADPROD.SUP_APROVECHABLE;
DEFINE VVPUNTO_REF         LIKE BDISOLIC:SS_UNIDADPROD.PUNTO_REF;
DEFINE VVMUNICIPIO         LIKE BDISOLIC:SS_UNIDADPROD.MUNICIPIO;
DEFINE VVGRAL_NORTE        LIKE BDISOLIC:SS_UNIDADPROD.GRAL_NORTE;
DEFINE VVPART_NORTE        LIKE BDISOLIC:SS_UNIDADPROD.PART_NORTE;
DEFINE VVLATITUD_NORTE     LIKE BDISOLIC:SS_UNIDADPROD.LATITUD_NORTE;
DEFINE VVTENEN_OFICINA     LIKE BDISOLIC:SS_UNIDADPROD.TENEN_OFICINA;
DEFINE VVTENEN_TOMO        LIKE BDISOLIC:SS_UNIDADPROD.TENEN_TOMO;
DEFINE VVREGISTRADO        LIKE BDISOLIC:SS_UNIDADPROD.REGISTRADO;
DEFINE VVSUP_CULTIVADA     LIKE BDISOLIC:SS_UNIDADPROD.SUP_CULTIVADA;
DEFINE VVPAIS              LIKE BDISOLIC:SS_UNIDADPROD.PAIS;
DEFINE VVPARCELA           LIKE BDISOLIC:SS_UNIDADPROD.PARCELA;
DEFINE VVGRAL_SUR          LIKE BDISOLIC:SS_UNIDADPROD.GRAL_SUR;
DEFINE VVPART_SUR          LIKE BDISOLIC:SS_UNIDADPROD.PART_SUR;
DEFINE VVLATITUD_SUR       LIKE BDISOLIC:SS_UNIDADPROD.LATITUD_SUR;
DEFINE VVSECTOR_TENENCIA   LIKE BDISOLIC:SS_UNIDADPROD.SECTOR_TENENCIA;
DEFINE VVTENEN_PROTOCOLO   LIKE BDISOLIC:SS_UNIDADPROD.TENEN_PROTOCOLO;
DEFINE VVFECHA_INICIO      LIKE BDISOLIC:SS_UNIDADPROD.FECHA_INICIO;
DEFINE VVSUP_SOLICITADA    LIKE BDISOLIC:SS_UNIDADPROD.SUP_SOLICITADA;
DEFINE VVESTADO            LIKE BDISOLIC:SS_UNIDADPROD.ESTADO;
DEFINE VVCASERIO           LIKE BDISOLIC:SS_UNIDADPROD.CASERIO;
DEFINE VVGRAL_ESTE         LIKE BDISOLIC:SS_UNIDADPROD.GRAL_ESTE;
DEFINE VVPART_ESTE         LIKE BDISOLIC:SS_UNIDADPROD.PART_ESTE;
DEFINE VVLATITUD_ESTE      LIKE BDISOLIC:SS_UNIDADPROD.LATITUD_ESTE;
DEFINE VVTENEN_NUMERO      LIKE BDISOLIC:SS_UNIDADPROD.TENEN_NUMERO;
DEFINE VVTENEN_TRIMESTRE   LIKE BDISOLIC:SS_UNIDADPROD.TENEN_TRIMESTRE;
DEFINE VVFECHA_CULMINACION LIKE BDISOLIC:SS_UNIDADPROD.FECHA_CULMINACION;

DEFINE V_FECHA_MINMIN      DATE;
DEFINE V_NUMREG            INTEGER;
DEFINE V_FECHA_HOY         DATE;

DEFINE V_COM_CAP           VARCHAR(4);
DEFINE V_COM_INT           VARCHAR(4);
DEFINE V_COM_MORA          VARCHAR(4);
DEFINE V_COM_COM           VARCHAR(4);

BEGIN
     ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_ERROR  = SQL_ERR;
        LET P_MENSAJE  = ERROR_INFO;
        RETURN P_ERROR, P_MENSAJE;
     END EXCEPTION;



     --*****************************
     --INICIALILZA VARIABLES
     --*****************************
      LET P_ERROR   = '00000';
      LET P_MENSAJE = 'PROCESO EXITOSO';
      LET V_EQ_DIAS = 0;
      LET V_NUMREG  = 0;
      LET V_COM_CAP = '0023';
      IF P_INT_CANCEL > 0 THEN
      	LET V_COM_INT = '0022';
      ELSE
      	LET V_COM_INT = '0025';
	LET P_INT_CANCEL = P_INT_CANCEL * -1;
      END IF
      LET V_COM_MORA = "0026";
      LET V_COM_COM  = "0027";
      SELECT FECHA_HOY INTO V_FECHA_HOY
      FROM SD_FECHAS WHERE EMPRESA = P_EMPRESA;

      call digvermod10(P_SOLICITUD)
           returning P_ERROR,vdigverif;
      let vnum_credito = trim(P_SOLICITUD)||vdigverif;

      --***** ACTUALIZA SD_DETMINIS
      BEGIN
         INSERT INTO SD_DETMINIS (EMPRESA                ,NUM_CREDITO
                                 ,FECHA_PROGRAMADA       ,FECHA_OTORGA
                                 ,MONTO_OTORGADO         ,STATUS_MINISTRA
                                 ,OBSER1                 ,CAMPO1
                                 ,CAMPO2
                                 )
                           SELECT EMPRESA                ,vnum_credito
                                 ,FECHA_PROGRAMADA       ,FECHA_OTORGA
                                 ,MONTO_OTORGADO         ,STATUS_MINISTRA
                                 ,OBSER1                 ,CAMPO1
                                 ,CAMPO2
                           FROM   BDISOLIC:SS_DETMINIS
                           WHERE  NUM_SOLICITUD = P_SOLICITUD
                           AND    EMPRESA       = P_EMPRESA;

         SELECT MIN(FECHA_PROGRAMADA)
         INTO V_FECHA_MINMIN
         FROM  SD_DETMINIS
         WHERE NUM_CREDITO = vnum_credito
         AND   EMPRESA     = P_EMPRESA;

         LET V_NUMREG = DBINFO("SQLCA.SQLERRD2");

         IF V_NUMREG > 0 THEN
           UPDATE SD_DETMINIS
           SET    STATUS_MINISTRA  = 'A'
                 ,FECHA_PROGRAMADA = V_FECHA_HOY
           WHERE FECHA_PROGRAMADA  = V_FECHA_MINMIN
           AND   NUM_CREDITO = vnum_credito
           AND   EMPRESA     = P_EMPRESA;

           UPDATE SD_DETMINIS SET STATUS_MINISTRA = 'P'
           WHERE NVL(STATUS_MINISTRA,'') <> 'A'
           AND   NUM_CREDITO = vnum_credito
           AND   EMPRESA     = P_EMPRESA;

         END IF;
      END;

      --ACTUALIZA LA ULTIMA CUOTA DE MINISTRACION, PARA CUADRAR EL MONTO.
      BEGIN
         SELECT MAX(D.FECHA_PROGRAMADA)
         INTO   V_FECHA_PROG_MAX
         FROM   SD_DETMINIS AS D
         WHERE  D.EMPRESA     = P_EMPRESA
         AND    D.NUM_CREDITO = vnum_credito;

         SELECT (MAX(B.MONTO_AUTO_CONT)-SUM(A.MONTO_OTORGADO))
         INTO   V_NVA_CIFRA
         FROM   SD_DETMINIS AS A
               ,BDISOLIC:SS_MAECONTRATO AS B
         WHERE  B.EMPRESA          = A.EMPRESA
         AND    B.NUM_CONTRATO     = A.NUM_CREDITO
         AND    A.EMPRESA          = P_EMPRESA
         AND    A.NUM_CREDITO      = vnum_credito;

         UPDATE SD_DETMINIS
         SET    MONTO_OTORGADO   = NVL(MONTO_OTORGADO,0) + NVL(V_NVA_CIFRA,0)
         WHERE  EMPRESA          = P_EMPRESA
         AND    NUM_CREDITO      = vnum_credito
         AND    FECHA_PROGRAMADA = V_FECHA_PROG_MAX;
      END;

      --***** ACTUALIZA SD_CONCEPFINA
      BEGIN
         INSERT INTO SD_CONCEPFINA (EMPRESA                ,NUM_CREDITO
                                   ,FECHA_PROGRAMADA       ,COD_INVERSION
                                   ,COD_CONAGRE            ,MONTO_CONCEPTO
                                   ,CANTIDAD
                                   )
                             SELECT EMPRESA                ,vnum_credito
                                   ,FECHA_PROGRAMADA       ,COD_INVERSION
                                   ,COD_CONAGRE            ,MONTO_CONCEPTO
                                   ,CANTIDAD
                             FROM   BDISOLIC:SS_CONCEPFINA
                             WHERE  NUM_SOLICITUD = P_SOLICITUD
                             AND    EMPRESA       = P_EMPRESA;
      END;

      --***** ACTUALIZA SD_UNIDADPROD
      BEGIN
         LET V_SECUENCIA_MAX = 0;
         SELECT NVL(MAX(SECUENCIA),0)+1
         INTO   V_SECUENCIA_MAX
         FROM   SD_UNIDADPROD   UNP
               ,BDISOLIC:SS_SOLICITUDES  SOL
         WHERE  UNP.NUMCTE        = SOL.NUMCTE
         AND    UNP.EMPRESA       = SOL.EMPRESA
         AND    SOL.NUM_SOLICITUD = P_SOLICITUD
         AND    SOL.EMPRESA       = P_EMPRESA;

         FOREACH UNIDADPROD FOR SELECT EMPRESA          ,NUMCTE                              ,NOMBRE_UNIDAD
                                      ,SUP_TOTAL        ,SUP_APROVECHABLE  ,SUP_CULTIVADA    ,SUP_SOLICITADA
                                      ,DIRECCION        ,PUNTO_REF         ,PAIS             ,ESTADO
                                      ,CIUDAD           ,MUNICIPIO         ,PARCELA          ,CASERIO
                                      ,ASENTAMIENTO     ,GRAL_NORTE        ,GRAL_SUR         ,GRAL_ESTE
                                      ,GRAL_OESTE       ,PART_NORTE        ,PART_SUR         ,PART_ESTE
                                      ,PART_OESTE       ,LATITUD_NORTE     ,LATITUD_SUR      ,LATITUD_ESTE
                                      ,LATITUD_OESTE    ,TENEN_OFICINA     ,SECTOR_TENENCIA  ,TENEN_NUMERO
                                      ,CLAS_TENENCIA    ,TENEN_TOMO        ,TENEN_PROTOCOLO  ,TENEN_TRIMESTRE
                                      ,TENEN_FECHA_INS  ,REGISTRADO        ,FECHA_INICIO     ,FECHA_CULMINACION
                                INTO   VVEMPRESA          ,VVNUMCTE                                ,VVNOMBRE_UNIDAD
                                      ,VVSUP_TOTAL        ,VVSUP_APROVECHABLE  ,VVSUP_CULTIVADA    ,VVSUP_SOLICITADA
                                      ,VVDIRECCION        ,VVPUNTO_REF         ,VVPAIS             ,VVESTADO
                                      ,VVCIUDAD           ,VVMUNICIPIO         ,VVPARCELA          ,VVCASERIO
                                      ,VVASENTAMIENTO     ,VVGRAL_NORTE        ,VVGRAL_SUR         ,VVGRAL_ESTE
                                      ,VVGRAL_OESTE       ,VVPART_NORTE        ,VVPART_SUR         ,VVPART_ESTE
                                      ,VVPART_OESTE       ,VVLATITUD_NORTE     ,VVLATITUD_SUR      ,VVLATITUD_ESTE
                                      ,VVLATITUD_OESTE    ,VVTENEN_OFICINA     ,VVSECTOR_TENENCIA  ,VVTENEN_NUMERO
                                      ,VVCLAS_TENENCIA    ,VVTENEN_TOMO        ,VVTENEN_PROTOCOLO  ,VVTENEN_TRIMESTRE
                                      ,VVTENEN_FECHA_INS  ,VVREGISTRADO        ,VVFECHA_INICIO     ,VVFECHA_CULMINACION
                                FROM   BDISOLIC:SS_UNIDADPROD
                                WHERE  NUM_SOLICITUD = P_SOLICITUD
                                AND    EMPRESA       = P_EMPRESA

            INSERT INTO SD_UNIDADPROD (EMPRESA                ,NUMCTE
                                   ,SECUENCIA              ,NOMBRE_UNIDAD
                                   ,SUP_TOTAL              ,SUP_APROVECHABLE
                                   ,SUP_CULTIVADA          ,SUP_SOLICITADA
                                   ,DIRECCION              ,PUNTO_REF
                                   ,PAIS                   ,ESTADO
                                   ,CIUDAD                 ,MUNICIPIO
                                   ,PARCELA                ,CASERIO
                                   ,ASENTAMIENTO           ,GRAL_NORTE
                                   ,GRAL_SUR               ,GRAL_ESTE
                                   ,GRAL_OESTE             ,PART_NORTE
                                   ,PART_SUR               ,PART_ESTE
                                   ,PART_OESTE             ,LATITUD_NORTE
                                   ,LATITUD_SUR            ,LATITUD_ESTE
                                   ,LATITUD_OESTE          ,TENEN_OFICINA
                                   ,SECTOR_TENENCIA        ,TENEN_NUMERO
                                   ,CLAS_TENENCIA          ,TENEN_TOMO
                                   ,TENEN_PROTOCOLO        ,TENEN_TRIMESTRE
                                   ,TENEN_FECHA_INS        ,REGISTRADO
                                   ,FECHA_INICIO           ,FECHA_CULMINACION
                                   )
                            VALUES( VVEMPRESA                ,VVNUMCTE
                                   ,V_SECUENCIA_MAX          ,VVNOMBRE_UNIDAD
                                   ,VVSUP_TOTAL              ,VVSUP_APROVECHABLE
                                   ,VVSUP_CULTIVADA          ,VVSUP_SOLICITADA
                                   ,VVDIRECCION              ,VVPUNTO_REF
                                   ,VVPAIS                   ,VVESTADO
                                   ,VVCIUDAD                 ,VVMUNICIPIO
                                   ,VVPARCELA                ,VVCASERIO
                                   ,VVASENTAMIENTO           ,VVGRAL_NORTE
                                   ,VVGRAL_SUR               ,VVGRAL_ESTE
                                   ,VVGRAL_OESTE             ,VVPART_NORTE
                                   ,VVPART_SUR               ,VVPART_ESTE
                                   ,VVPART_OESTE             ,VVLATITUD_NORTE
                                   ,VVLATITUD_SUR            ,VVLATITUD_ESTE
                                   ,VVLATITUD_OESTE          ,VVTENEN_OFICINA
                                   ,VVSECTOR_TENENCIA        ,VVTENEN_NUMERO
                                   ,VVCLAS_TENENCIA          ,VVTENEN_TOMO
                                   ,VVTENEN_PROTOCOLO        ,VVTENEN_TRIMESTRE
                                   ,VVTENEN_FECHA_INS        ,VVREGISTRADO
                                   ,VVFECHA_INICIO           ,VVFECHA_CULMINACION
                                  );

            LET V_SECUENCIA_MAX = V_SECUENCIA_MAX + 1;
         END FOREACH;

         SELECT NVL(MAX(SECUENCIA),0)
         INTO   V_SECUENCIA_MAX
         FROM   SD_UNIDADPROD   UNP
               ,BDISOLIC:SS_SOLICITUDES  SOL
         WHERE  UNP.NUMCTE        = SOL.NUMCTE
         AND    UNP.EMPRESA       = SOL.EMPRESA
         AND    SOL.NUM_SOLICITUD = P_SOLICITUD
         AND    SOL.EMPRESA       = P_EMPRESA;

         UPDATE SD_MAECRED
         SET    ID_UNIDAD_PROD = V_SECUENCIA_MAX
         WHERE  NUM_CREDITO = vnum_credito
         AND    EMPRESA     = P_EMPRESA;
      END;

      --***** ACTUALIZA SD_FUENTRES_X_CRED
      BEGIN
         INSERT INTO SD_FUENTES_X_CRED (EMPRESA                ,NUM_CREDITO
                                       ,CODIGO_INS             ,PORCENT_PART
                                       ,INDIC_PROPIO           ,COD_TASA_FONDO
                                       ,FACTOR_FONDO           ,SOBRETASA_FONDO
                                       ,TASA_FONDO             ,PARTICIPACION_CAPITAL
                                       ,INTERESES_CALCULADOS
                                       )
                                 SELECT EMPRESA                ,vnum_credito
                                       ,CODIGO_INS             ,PORCENT_PART
                                       ,INDIC_PROPIO           ,COD_TASA_FONDO
                                       ,FACTOR_FONDO           ,SOBRETASA_FONDO
                                       ,TASA_FONDO             ,PARTICIPACION_CAPITAL
                                       ,INTERESES_CALCULADOS
                                 FROM   BDISOLIC:SS_FUENTES_X_SOL
                                 WHERE  NUM_SOLICITUD = P_SOLICITUD
                                 AND    EMPRESA       = P_EMPRESA;
      END;

      --***** ACTUALIZA SD_DETCOMI
      BEGIN
         INSERT INTO SD_DETCOMI (EMPRESA,
                                 COD_COMIS,
                                 NUM_CREDITO,
                                 FECHA_ALTA,
                                 MONTO_COM,
                                 APLI_FACTOR,
                                 ESTADO_COM
                                )
                          SELECT  EMPRESA
                                , COD_COMIS
                                , vnum_credito
                                , FECHA_ALTA
                                , MONTO_COM
                                , APLI_FACTOR
                                , ESTADO_COM
                          FROM    BDISOLIC:SS_DETCOMI
                          WHERE   NUM_SOLICITUD = P_SOLICITUD
                          AND     EMPRESA       = P_EMPRESA;

         IF P_TP_SOL = 'R' OR P_TP_SOL = "F" THEN

            INSERT INTO SD_DETCOMI (EMPRESA,
                                    COD_COMIS,
                                    NUM_CREDITO,
                                    FECHA_ALTA,
                                    MONTO_COM,
                                    APLI_FACTOR,
                                    ESTADO_COM
                                   )
                            VALUES (P_EMPRESA
                                   ,V_COM_CAP
                                   ,vnum_credito
                                   ,V_FECHA_HOY
                                   ,P_CAP_CANCEL
                                   ,0
                                   ,'1'
                                   );
	   IF P_INT_CANCEL > 0 THEN
            INSERT INTO SD_DETCOMI (EMPRESA,
                                    COD_COMIS,
                                    NUM_CREDITO,
                                    FECHA_ALTA,
                                    MONTO_COM,
                                    APLI_FACTOR,
                                    ESTADO_COM
                                   )
                            VALUES (P_EMPRESA
                                   ,V_COM_INT
                                   ,vnum_credito
                                   ,V_FECHA_HOY
                                   ,P_INT_CANCEL
                                   ,0
                                   ,'1'
                                   );
	   END IF
	   IF P_MORA_CANCEL > 0 THEN
            INSERT INTO SD_DETCOMI (EMPRESA,
                                    COD_COMIS,
                                    NUM_CREDITO,
                                    FECHA_ALTA,
                                    MONTO_COM,
                                    APLI_FACTOR,
                                    ESTADO_COM
                                   )
                            VALUES (P_EMPRESA
                                   ,V_COM_MORA
                                   ,vnum_credito
                                   ,V_FECHA_HOY
                                   ,P_MORA_CANCEL
                                   ,0
                                   ,'1'
                                   );


	   END IF
           IF P_COM_CANCEL > 0 THEN
            INSERT INTO SD_DETCOMI (EMPRESA,
                                    COD_COMIS,
                                    NUM_CREDITO,
                                    FECHA_ALTA,
                                    MONTO_COM,
                                    APLI_FACTOR,
                                    ESTADO_COM
                                   )
                            VALUES (P_EMPRESA
                                   ,V_COM_COM
                                   ,vnum_credito
                                   ,V_FECHA_HOY
                                   ,P_COM_CANCEL
                                   ,0
                                   ,'1'
                                   );


           END IF

         END IF;
      END;

      --***** ACTUALIZA SD_DETCOMIHIPOT
      BEGIN
         INSERT INTO SD_DETCOMIHIPOT ( empresa,
				       cod_comis,
			 	       num_credito,
				       fecha_alta,
				       monto_com,
				       apli_factor,
				       estado_com,
				       descripcion)
                               SELECT empresa,
				      cod_comis,
				      num_solicitud,
				      fecha_alta,
				      monto_com,
				      apli_factor,
				      estado_com,
				      descripcion
                               FROM   BDISOLIC:SS_DETCOMIHIPOT
                               WHERE  NUM_SOLICITUD = P_SOLICITUD
                               AND    EMPRESA     = P_EMPRESA;
      END;
      EXECUTE PROCEDURE GENERA_MOV_DIA( P_EMPRESA
                                      , vnum_credito
                                      ) INTO P_ERROR, P_MENSAJE;

      IF P_ERROR <> '00000' THEN
         IF P_MENSAJE IS NULL THEN
            LET P_MENSAJE = 'IMPOSIBLE GENERAR MOVIMIENTO CONTABLE';
         END IF;
      END IF;
      RETURN P_ERROR, P_MENSAJE;
END;
END PROCEDURE
DOCUMENT
'Segundo procedimiento de contruccion de credito en apertura',
' es llamado por CApertCred.exe (VB)',
'AUTOR : Antonio Ruiz Mtz. ',
'FECHA : 17/Noviembre/2005',
'CTE   : CACSI',
'BD    : BDICRED';

create procedure "informix".digvermod10(pcuenta char(20))
       returning char(5),char(1);

   DEFINE vcodret     CHAR(5);
   DEFINE i,k,n,p,n1,n2 INTEGER;
   DEFINE vdigver     CHAR(1);
   DEFINE vctaaux     CHAR(20);
   define vaux        char(2);




   LET vcodret = "000";
   LET vdigver = "0";
   LET vctaaux = pcuenta;

   LET n = 0;

   for i = 1 to 20
       if i = 1 then let k = vctaaux[1,1]; end if;
       if i = 2 then let k = vctaaux[2,2]; end if;
       if i = 3 then let k = vctaaux[3,3]; end if;
       if i = 4 then let k = vctaaux[4,4]; end if;
       if i = 5 then let k = vctaaux[5,5]; end if;
       if i = 6 then let k = vctaaux[6,6]; end if;
       if i = 7 then let k = vctaaux[7,7]; end if;
       if i = 8 then let k = vctaaux[8,8]; end if;
       if i = 9 then let k = vctaaux[9,9]; end if;
       if i = 10 then let k = vctaaux[10,10]; end if;
       if i = 11 then let k = vctaaux[11,11]; end if;
       if i = 12 then let k = vctaaux[12,12]; end if;
       if i = 13 then let k = vctaaux[13,13]; end if;
       if i = 14 then let k = vctaaux[14,14]; end if;
       if i = 15 then let k = vctaaux[15,15]; end if;
       if i = 16 then let k = vctaaux[16,16]; end if;
       if i = 17 then let k = vctaaux[17,17]; end if;
       if i = 18 then let k = vctaaux[18,18]; end if;
       if i = 19 then let k = vctaaux[19,19]; end if;
       if i = 20 then let k = vctaaux[20,20]; end if;
       IF k IS NOT NULL THEN
          if mod(i,2) = 0 then
             LET p = 1;
          else
             LET p = 2;
          end if
          let vaux = lpad(k*p,2,"0");
          let n1 = vaux[1];
          let n2 = vaux[2];
          LET n = n + n1 + n2;
       END IF;
   end for
   let n = n;
   if mod(n,10) = 0 then
      let k = n;
   else
      let k = n - mod(n,10) + 10;
   end if
   LET vdigver = k - n;
   RETURN vcodret, vdigver;
end procedure;