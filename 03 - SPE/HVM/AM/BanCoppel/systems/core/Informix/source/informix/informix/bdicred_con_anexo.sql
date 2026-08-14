CREATE PROCEDURE "informix".con_anexo(cNumCliente CHAR(20))

   RETURNING CHAR(5),         -- codigo de retorno
             CHAR(20),        -- numero de cliente
             CHAR(60),        -- nombre o razon social
             CHAR(45),        -- ejecutivo
             CHAR(30),        -- divisa
             CHAR(18),        -- curp
             CHAR(25),        -- calificacion del cliente
             CHAR(40),        -- sector tenencia
             CHAR(50),        -- figura juridica
             CHAR(40),        -- productor1
             CHAR(40),        -- productor2
             DECIMAL(9,3),    -- superficie
             CHAR(1),         -- nivel de ingreso
             CHAR(5),         -- reciprocidad
             CHAR(30),        -- desarrollo rural
             CHAR(30),        -- centro de apoyo
             CHAR(30),        -- nombre del predio
             CHAR(30),        -- nombre del presidente
             CHAR(30),        -- nombre del secretario
             CHAR(30),        -- nombre del tesorero
             SMALLINT;        -- total de integrantes


   DEFINE cCodRet             CHAR(3);
   DEFINE cNombre             CHAR(60);
   DEFINE cNomEjecutivo       LIKE bdinteg:si_ejecut.nombre;
   DEFINE cNomDivisa          LIKE bdinteg:si_divisas.descripcion;
   DEFINE cNomProducto        LIKE bdicred:sd_definicion.nombre_prod;
   DEFINE cCURP               CHAR(18);
   DEFINE cCalificacion       CHAR(25);
   DEFINE cTenencia           CHAR(40);
   DEFINE cFiguraJuridica     CHAR(50);
   DEFINE cProductor1         CHAR(40);
   DEFINE cProductor2         CHAR(40);
   DEFINE nSuperficie         DECIMAL(9,3);
   DEFINE cNivelIngreso       CHAR(1);
   DEFINE cReciprocidad       CHAR(5);
   DEFINE cDesarrolloRural    CHAR(30);
   DEFINE cCentroApoyo        CHAR(30);
   DEFINE cPredio             CHAR(30);
   DEFINE cPresidente         CHAR(30);
   DEFINE cSecretario         CHAR(30);
   DEFINE cTesorero           CHAR(30);
   DEFINE nIntegrantes        SMALLINT;

   DEFINE cPaterno            CHAR(15);
   DEFINE cMaterno            CHAR(15);
   DEFINE cNombre1            CHAR(15);
   DEFINE cNombre2            CHAR(15);
   DEFINE cRazonSocial        CHAR(40);

   DEFINE cCodCalifica        CHAR(2);
   DEFINE nCodTenencia        SMALLINT;
   DEFINE nCodSujFJ           SMALLINT;
   DEFINE cCodProd1           CHAR(2);
   DEFINE cCodProd2           CHAR(2);
   DEFINE cCodNivelIngreso    CHAR(1);
   DEFINE cCodReciprocidad    CHAR(1);
   DEFINE cCveEjecutivo       LIKE bdicred:sd_maecred.ejecutivo;
   DEFINE cCveDivisa          LIKE bdicred:sd_maecred.divisa;
   DEFINE cNumCredito         LIKE bdicred:sd_maecred.num_credito;

   DEFINE nCodDDR             SMALLINT;
   DEFINE cCodCentroApoyo     CHAR(3);

   DEFINE nContador           SMALLINT;


-- ############################################################################
-- Inicializa variables
-- ############################################################################
   LET cCodRet          = "000";
   LET cNombre          = "";
   LET cNomEjecutivo    = "";
   LET cNomDivisa       = "";
   LET cNomProducto     = "";
   LET cCURP            = "";
   LET cCalificacion    = "";
   LET cTenencia        = "";
   LET cFiguraJuridica  = "";
   LET cProductor1      = "";
   LET cProductor2      = "";
   LET nSuperficie      = 0;
   LET cNivelIngreso    = "";
   LET cReciprocidad    = "";
   LET cDesarrolloRural = "";
   LET cCentroApoyo     = "";
   LET cPredio          = "";
   LET cPresidente      = "";
   LET cSecretario      = "";
   LET cTesorero        = "";
   LET nIntegrantes     = 0;

   LET cPaterno         = "";
   LET cMaterno         = "";
   LET cNombre1         = "";
   LET cNombre2         = "";
   LET cRazonSocial     = "";

   LET cCodCalifica     = "";
   LET nCodTenencia     = "";
   LET nCodSujFJ        = 0;
   LET cCodProd1        = 0;
   LET cCodProd2        = "";
   LET cCodNivelIngreso = "";
   LET cCodReciprocidad = "";
   LET cCveEjecutivo    = "";
   LET cCveDivisa       = "";
   LET cNumCredito      = "";

   LET nCodDDR          = 0;
   LET cCodCentroApoyo  = "";

   LET nContador        = 0;




-- ############################################################################
-- Valida la informacion de entrada
-- ############################################################################
   IF cNumCliente = "" THEN
      LET cCodRet = "421";                   -- NO HAY ARGUMENTO

   ELSE
      SELECT bdinteg:si_cliente.apell_paterno, bdinteg:si_cliente.apell_materno,
             bdinteg:si_cliente.nombre1,       bdinteg:si_cliente.nombre2,
             bdinteg:si_cliente.razon_social
         INTO cPaterno, cMaterno, cNombre1, cNombre2, cRazonSocial
         FROM bdinteg:si_cliente
         WHERE bdinteg:si_cliente.numcte = cNumCliente;

      IF cPaterno IS NULL AND cRazonSocial IS NULL THEN
         LET cCodRet = "422";                -- NO EXISTE CLIENTE EN CENTRAL

      ELSE

         IF cRazonSocial IS NULL OR cRazonSocial = "                                        " THEN
            LET cNombre = TRIM(cNombre1) || " " || TRIM(cNombre2);
            LET cNombre = TRIM(cNombre) || " " || TRIM(cPaterno) || " " || TRIM(cMaterno);
         ELSE
            LET cNombre = cRazonSocial;
         END IF

         SELECT bdicred:sd_calctebr.curp,bdicred:sd_calctebr.cod_califica,
                bdicred:sd_calctebr.cod_sujeto_fj,bdicred:sd_calctebr.cod_prod,
                bdicred:sd_calctebr.cod_prod_2,bdicred:sd_calctebr.superficie,
                bdicred:sd_calctebr.nivel_ingreso,bdicred:sd_calctebr.reciprocidad
            INTO cCURP,cCodCalifica,nCodSujFJ,cCodProd1,cCodProd2,
                 nSuperficie,cCodNivelIngreso,cCodReciprocidad
            FROM bdicred:sd_calctebr
            WHERE bdicred:sd_calctebr.numcte = cNumCliente;

         IF cCodCalifica IS NULL THEN
            LET cCodRet = "423";             -- NO EXISTE ANEXO

         ELSE
            SELECT bdicred:sd_estimulobr.descrip_califica
               INTO cCalificacion
               FROM bdicred:sd_estimulobr
               WHERE bdicred:sd_estimulobr.cod_califica = cCodCalifica ;

            SELECT bdicred:sd_figjudbr.descrip_sujeto,bdicred:sd_figjudbr.sector_tenencia
               INTO cFiguraJuridica,nCodTenencia
               FROM bdicred:sd_figjudbr
               WHERE bdicred:sd_figjudbr.cod_sujeto_fj = nCodSujFJ;

            SELECT bdicred:sd_sectenbr.descrip_ten
               INTO cTenencia
               FROM bdicred:sd_sectenbr
               WHERE bdicred:sd_sectenbr.sector_tenencia = nCodTenencia;

            IF cCodProd1 != "  " AND cCodProd1 IS NOT NULL THEN
               SELECT bdicred:sd_tipprodbr.descrip_prod
                  INTO cProductor1
                  FROM bdicred:sd_tipprodbr
                  WHERE bdicred:sd_tipprodbr.cod_prod = cCodProd1;
               LET cProductor1 = cCodProd1 || " " || cProductor1;
            END IF
            IF cCodProd2 != "  " AND cCodProd2 IS NOT NULL THEN
               SELECT bdicred:sd_tipprodbr.descrip_prod
                  INTO cProductor2
                  FROM bdicred:sd_tipprodbr
                  WHERE bdicred:sd_tipprodbr.cod_prod = cCodProd2;
               LET cProductor2 = cCodProd2 || " " || cProductor2;
            END IF

            IF cCodReciprocidad = "A" THEN
               LET cReciprocidad = "ALTA";
            ELSE
               IF cCodReciprocidad = "M" THEN
                  LET cReciprocidad = "MEDIA";
               ELSE
                  IF cCodReciprocidad = "B" THEN
                     LET cReciprocidad = "BAJA";
                  END IF
               END IF
            END IF

            LET cNivelIngreso = cCodNivelIngreso;

            SELECT bdicred:sd_sujecredbr.cod_ddr,bdicred:sd_sujecredbr.cod_ctroapoyo,
                   bdicred:sd_sujecredbr.nombre_predio,bdicred:sd_sujecredbr.presidente,
                   bdicred:sd_sujecredbr.secretario,bdicred:sd_sujecredbr.tesorero,
                   bdicred:sd_sujecredbr.total_integrantes
               INTO nCodDDR,cCodCentroApoyo,cPredio,cPresidente,cSecretario,
                    cTesorero,nIntegrantes
               FROM bdicred:sd_sujecredbr
               WHERE bdicred:sd_sujecredbr.numcte = cNumCliente ;

            IF nCodDDR != 0 AND nCodDDR IS NOT NULL THEN
               SELECT bdicred:sd_ddruralbr.descrip_ddr
                  INTO cDesarrolloRural
                  FROM bdicred:sd_ddruralbr
                  WHERE bdicred:sd_ddruralbr.cod_ddr = nCodDDR;

               SELECT bdicred:sd_centroapbr.descrip_ctroapoyo
                  INTO cCentroApoyo
                  FROM bdicred:sd_centroapbr
                  WHERE bdicred:sd_centroapbr.cod_ddr = nCodDDR AND
                        bdicred:sd_centroapbr.cod_ctroapoyo = cCodCentroApoyo;
            ELSE
               LET cPredio      = "";
               LET cPresidente  = "";
               LET cSecretario  = "";
               LET cTesorero    = "";
               LET nIntegrantes = 0;
            END IF

            SELECT MAX(num_credito)
               INTO cNumCredito
               FROM bdicred:sd_maecred
               WHERE bdicred:sd_maecred.numcte = cNumCliente;

            SELECT bdicred:sd_maecred.ejecutivo, bdicred:sd_maecred.divisa
               INTO cCveEjecutivo, cCveDivisa
               FROM bdicred:sd_maecred
               WHERE bdicred:sd_maecred.num_credito = cNumCredito;


            SELECT bdinteg:si_ejecut.nombre
               INTO cNomEjecutivo
               FROM bdinteg:si_ejecut
               WHERE bdinteg:si_ejecut.ejecutivo = cCveEjecutivo;

            SELECT bdinteg:si_divisas.descripcion
               INTO cNomDivisa
               FROM bdinteg:si_divisas
               WHERE bdinteg:si_divisas.divisa = cCveDivisa;

         END IF
      END IF
   END IF

   RETURN cCodRet,cNumCliente,cNombre,cNomEjecutivo,cNomDivisa,
          cCURP,cCalificacion,cTenencia,cFiguraJuridica,cProductor1,cProductor2,
          nSuperficie,cNivelIngreso,cReciprocidad,cDesarrolloRural,cCentroApoyo,
          cPredio,cPresidente,cSecretario,cTesorero,nIntegrantes;

END PROCEDURE;