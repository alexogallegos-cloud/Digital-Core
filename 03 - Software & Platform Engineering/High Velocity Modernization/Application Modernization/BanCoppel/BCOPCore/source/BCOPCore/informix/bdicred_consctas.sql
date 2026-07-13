CREATE PROCEDURE "informix".consctas(p_num_credito CHAR(20),
                          p_band INTEGER,
                          p_empresa    CHAR(3))
                          RETURNING CHAR(5),
                                    CHAR(20),
                                    CHAR(20),
                                    CHAR(60),
                                    CHAR(1),
                                    CHAR(1),
                                    CHAR(1),
                                    CHAR(20);

--Define Variables de Trabajo

DEFINE v_codret        LIKE bdinteg:si_codret.codigo_retorno;
DEFINE v_numcte        LIKE sd_maecred.numcte;
DEFINE mc_numero       LIKE sd_ctascarg.numero;
DEFINE mc_con_cap_inte LIKE sd_ctascarg.con_cap_inte;
DEFINE mc_naturaleza   LIKE sd_ctascarg.naturaleza;
DEFINE mc_num_credito  LIKE sd_ctascarg.num_credito;
DEFINE mc_tipo_cta     LIKE sd_ctascarg.tipo_cta;
DEFINE mc_num_cta      LIKE sd_ctascarg.num_cta;
DEFINE mc_num_nomina   LIKE sd_ctascarg.num_nomina;
DEFINE v_numero_pagares INTEGER;
DEFINE v_ciclo,
       v_conta         SMALLINT;
DEFINE v_razon         CHAR(60);
DEFINE i_es_fisica     LIKE bdinteg:si_tipper.es_fisica;
DEFINE i_tpo_per       LIKE bdinteg:si_cliente.tpo_persona;
DEFINE i_apell_paterno LIKE bdinteg:si_cliente.apell_paterno;
DEFINE i_apell_materno LIKE bdinteg:si_cliente.apell_materno;
DEFINE i_nombre1       LIKE bdinteg:si_cliente.nombre1;
DEFINE i_nombre2       LIKE bdinteg:si_cliente.nombre2;
DEFINE i_razon_social  LIKE bdinteg:si_cliente.razon_social;


LET v_codret           = "000";
LET v_numcte          = " ";
LET mc_numero          = 0;
LET mc_con_cap_inte    = " ";
LET mc_naturaleza      = " ";
LET mc_num_credito     = " ";
LET mc_tipo_cta        = " ";
LET mc_num_cta         = " ";
LET mc_num_nomina      = " ";
LET v_numero_pagares   = 0;
LET v_ciclo            = 0;
LET v_conta            = 0;
LET v_razon            = " ";
LET i_es_fisica        = " ";
LET i_tpo_per          = " ";
LET i_apell_paterno    = "  ";
LET i_apell_materno    = "  ";
LET i_nombre1          = "  ";
LET i_nombre2          = "  ";
LET i_razon_social     = "  ";

   --Validacion para ver si se Asigno Cuenta de Cheques y/o Ahorros

   SELECT numcte INTO v_numcte FROM sd_maecred
   WHERE num_credito = p_num_credito
   AND empresa = p_empresa;

   IF v_numcte IS NULL THEN
      LET v_codret = "100";
      RETURN v_codret,p_num_credito,v_numcte,v_razon,mc_con_cap_inte,mc_naturaleza,
             mc_tipo_cta,mc_num_cta;
   END IF;

   --Valida informiacion del Cliente
   SELECT tpo_persona,apell_paterno,apell_materno,
          nombre1,nombre2,razon_social
   INTO   i_tpo_per,i_apell_paterno,i_apell_materno,
          i_nombre1,i_nombre2,i_razon_social
   FROM bdinteg:si_cliente
   WHERE bdinteg:si_cliente.numcte = v_numcte
   AND bdinteg:si_cliente.empresa = p_empresa;

   SELECT es_fisica INTO i_es_fisica
   FROM bdinteg:si_tipper
   WHERE bdinteg:si_tipper.tpo_persona = i_tpo_per;

    IF i_es_fisica = "S" THEN
        LET v_razon = i_nombre1 || i_nombre2 || i_apell_paterno || i_apell_materno;
    ELSE
       LET v_razon = i_razon_social;
    END IF;

   SELECT COUNT(*) INTO v_numero_pagares
   FROM sd_ctascarg
   WHERE num_credito = p_num_credito
   AND empresa = p_empresa;

   IF v_numero_pagares > 0 THEN

       --Inicio de la generacion de Pagares
       FOREACH
              SELECT *
              INTO mc_numero, mc_con_cap_inte, mc_naturaleza,
                   mc_num_credito, mc_tipo_cta, mc_num_cta,
                   mc_num_nomina
              FROM sd_ctascarg
              WHERE num_credito = p_num_credito
              AND empresa = p_empresa

              ORDER BY numero

              LET v_ciclo= v_ciclo+1;
              IF v_ciclo <= p_band THEN
                 continue foreach;
              END IF

              RETURN v_codret,p_num_credito,v_numcte,v_razon,mc_con_cap_inte,mc_naturaleza,
                     mc_tipo_cta,mc_num_cta


              WITH RESUME;

              LET v_conta = v_conta + 1;
        END FOREACH;
    ELSE

              RETURN v_codret,p_num_credito,v_numcte,v_razon,mc_con_cap_inte,mc_naturaleza,
                     mc_tipo_cta,mc_num_cta;
    END IF;
END PROCEDURE;