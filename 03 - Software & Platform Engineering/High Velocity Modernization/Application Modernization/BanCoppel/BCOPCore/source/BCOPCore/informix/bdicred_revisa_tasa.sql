CREATE PROCEDURE "informix".revisa_tasa(p_fecha_proceso DATE)
       RETURNING CHAR(5), CHAR(20);

   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_sucursal           char(4)        DEFAULT " ";
   DEFINE GLOBAL g_fecha_apertu       date           DEFAULT " ";
   DEFINE GLOBAL g_fecha_vencim       date           DEFAULT " ";
   DEFINE GLOBAL g_tasa_interes       decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_tasa_morato        decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_tasa_f_o_v         char(1)        DEFAULT " ";
   DEFINE GLOBAL g_cod_tasa_base      char(8)        DEFAULT " ";
   DEFINE GLOBAL g_sobretasa          decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_factor_sobretasa   char(1)        DEFAULT " ";
   DEFINE GLOBAL g_tasa_mora_adic     char(1)        DEFAULT " ";
   DEFINE GLOBAL g_cod_tasa_mora      char(8)        DEFAULT " ";
   DEFINE GLOBAL g_sobretasa_mora     decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_fact_sobret_mora   char(1)        DEFAULT " ";
   DEFINE GLOBAL g_factor_moratorio   decimal(9,6)   DEFAULT 0;
   DEFINE GLOBAL g_rev_tasa_var_per   char(1)        DEFAULT " ";
   DEFINE GLOBAL g_dia_para_revisar   smallint       DEFAULT 0;
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";


   DEFINE vrt_num_credito          char(20);
   DEFINE vrt_fecha_ult_rev        date;
   DEFINE vrt_per_rev_tvp          char(1);
   DEFINE vrt_que_mes              smallint;
   DEFINE vrt_cada_cuanto          smallint;
   DEFINE vrt_fecha_prox_rev       date;
   DEFINE vrt_ajusta_rev           char(1);
   DEFINE vrt_dias_retro           smallint;
   DEFINE vrt_empresa              CHAR(3);


   -- DEFINICION DE VARIABLES DE TRABAJO
   DEFINE v_codret               CHAR(5);
   DEFINE v_tasa_mor             LIKE sd_maecred.tasa_moratorios;
   DEFINE v_tasa_int             LIKE sd_maecred.tasa_interes;
   DEFINE v_proceso              CHAR(10);
   DEFINE v_fecha_progra         DATE;
   DEFINE v_fecha_retro          DATE;
   DEFINE i                      SMALLINT;
   DEFINE sql_err                SMALLINT;
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR(40);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "revisa_tasa.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, g_num_credito;
   END EXCEPTION;





   -- ######################################################################
   -- ####  Inicializacion de Variables
   -- ######################################################################
   LET v_tasa_int         = 0;
   LET v_tasa_mor         = 0;
   LET v_codret           = "000" ;
   LET v_proceso          = "100";
   LET v_fecha_progra     = NULL;
   LET v_fecha_retro      = NULL;
   LET i                  = 0;

   LET vrt_num_credito      = NULL;
   LET vrt_fecha_ult_rev    = "";
   LET vrt_per_rev_tvp      = "";
   LET vrt_que_mes          = 0;
   LET vrt_cada_cuanto      = 0;
   LET vrt_fecha_prox_rev   = NULL ;
   LET vrt_ajusta_rev       = "";
   LET vrt_dias_retro       = 0;
   LET vrt_empresa          = "";

   -- #########################################################################
   -- ####                SELECT DE LA TABLA DE REVISION                   ####
   -- #########################################################################
   IF g_tasa_f_o_v = "3" OR g_tasa_f_o_v = "4" THEN
      SELECT
         *
      INTO
         vrt_empresa, vrt_num_credito, vrt_fecha_prox_rev
      FROM sd_revtasa
      WHERE num_credito       = g_num_credito
        AND empresa           = g_empresa
        AND fecha_prox_rev    = p_fecha_proceso;


      IF vrt_num_credito IS NULL THEN
         LET v_codret  = "300" ;
         RETURN v_codret, g_num_credito;
      END IF;
   END IF;

      --#####################################################################
      --#####    TASA VARIABLE = 2, TASA VARIABLE PERIODICA = 3          ####
      --#####    TASA VARIABLE RETROACTIVA = 4                           ####
      --#####################################################################
      IF g_tasa_f_o_v = "2" THEN
         --#### ARMADO DE LA TASA DE INTERES ORDINARIO CON REVISION
         CALL armatasa (p_fecha_proceso,
                        g_cod_tasa_base,
                        g_factor_sobretasa,
                        g_sobretasa)
         RETURNING v_codret, v_tasa_int;

         IF v_codret <> "000" THEN
            RETURN v_codret, g_num_credito;
         END IF;

         --#### ARMADO DE LA TASA DE INTERES MORATORIO CON REVISION
         IF g_tasa_mora_adic = "1" THEN
            LET v_tasa_mor = v_tasa_int * g_factor_moratorio;
         ELIF g_tasa_mora_adic = "2" THEN
            CALL armatasa (p_fecha_proceso,
                           g_cod_tasa_mora,
                           g_fact_sobret_mora,
                           g_sobretasa_mora)
            RETURNING v_codret, v_tasa_mor;
            IF v_codret <> "000" THEN
               RETURN v_codret, g_num_credito;
            END IF;
         ELIF g_tasa_mora_adic = "3" THEN
            IF g_fact_sobret_mora = "+" THEN
               LET v_tasa_mor = v_tasa_int + g_sobretasa_mora;
            ELIF g_fact_sobret_mora = "-" THEN
               LET v_tasa_mor = v_tasa_int - g_sobretasa_mora;
            ELIF g_fact_sobret_mora = "/" THEN
               LET v_tasa_mor = v_tasa_int / g_sobretasa_mora;
            END IF
         END IF

         --####  inserta registro en la tabla de historicos de tasas
         INSERT INTO sd_historico
         VALUES (g_empresa,g_num_credito,p_fecha_proceso,v_proceso,
                 g_tasa_interes,
                 g_tasa_morato, 0,0,0,0,0,0,0,"");

         LET vrt_fecha_ult_rev  = NULL;
         LET vrt_per_rev_tvp    = g_rev_tasa_var_per;
         LET vrt_que_mes        = 0;
         LET vrt_cada_cuanto    = g_dia_para_revisar;
         LET vrt_fecha_prox_rev = NULL;

      END IF


      IF g_tasa_f_o_v = "3" OR g_tasa_f_o_v = "4" THEN
         IF vrt_fecha_prox_rev IS NOT NULL THEN

            --###############################################
            -- Se Calcula la fecha proxima de revision
            --###############################################

            LET v_fecha_progra = vrt_fecha_prox_rev;

            {CALL  cal_prox_rev(p_fecha_proceso,        g_fecha_apertu,
                               g_fecha_vencim,     g_num_credito,
                               vrt_fecha_ult_rev,  vrt_per_rev_tvp,
                               vrt_que_mes,        vrt_cada_cuanto,
                               vrt_fecha_prox_rev)
            RETURNING v_codret,
                      g_num_credito,
                      vrt_fecha_ult_rev,
                      vrt_per_rev_tvp,
                      vrt_que_mes,
                      vrt_cada_cuanto,
                      vrt_fecha_prox_rev;}

            LET vrt_fecha_ult_rev = v_fecha_progra;

            IF v_codret <> "000" THEN
               RETURN v_codret, g_num_credito;
            END IF;

            -- ####################################################
            -- #### validar si el credito ya esta dispuesto
            -- ### para la revision con fecha de hoy
            -- ####################################################

            IF g_tasa_f_o_v = "4" THEN
               -- recorrer fecha para los dias retroactivos
               IF vrt_dias_retro > 0 THEN
                  LET v_fecha_retro = v_fecha_progra;
                  --LET i = 1;
                  FOR i = 1 to vrt_dias_retro

                     CALL dia_habil(v_fecha_retro,
                                    "P",
                                    g_sucursal)
                     RETURNING v_codret, v_fecha_retro;
                     LET v_fecha_retro = v_fecha_retro - 1 UNITS DAY;

                  END FOR;
                  LET v_fecha_progra = v_fecha_retro;

               END IF;
            END IF;

            --#### ARMADO DE LA TASA DE INTERES ORDINARIA CON REVISION
            CALL armatasa(v_fecha_progra,
                          g_cod_tasa_base,
                          g_factor_sobretasa,
                          g_sobretasa)
            RETURNING v_codret, v_tasa_int;
            IF v_codret <> "000" THEN
               RETURN v_codret, g_num_credito;
            END IF;

            --#### ARMADO DE LA TASA DE INTERES MORATORIO CON REVISION
            IF g_tasa_mora_adic = "1" THEN
               LET v_tasa_mor = v_tasa_int * g_factor_moratorio;
            ELIF g_tasa_mora_adic = "2" THEN
               CALL armatasa (p_fecha_proceso,
                              g_cod_tasa_mora,
                              g_fact_sobret_mora,
                              g_sobretasa_mora)
               RETURNING v_codret, v_tasa_mor;
               IF v_codret <> "000" THEN
                  RETURN v_codret, g_num_credito;
               END IF;
            ELIF g_tasa_mora_adic = "3" THEN
               IF g_fact_sobret_mora = "+" THEN
                  LET v_tasa_mor = v_tasa_int + g_sobretasa_mora;
               ELIF g_fact_sobret_mora = "-" THEN
                  LET v_tasa_mor = v_tasa_int - g_sobretasa_mora;
               ELIF g_fact_sobret_mora = "/" THEN
                  LET v_tasa_mor = v_tasa_int / g_sobretasa_mora;
               END IF
            END IF

            CALL dia_habil(vrt_fecha_prox_rev,
                                        vrt_ajusta_rev,
                                        g_sucursal)
            RETURNING v_codret, vrt_fecha_prox_rev;
            IF v_codret <> "000" THEN
               RETURN v_codret, g_num_credito;
            END IF;


            --####  inserta registro en la tabla de historicos de tasas
            INSERT INTO sd_historico
            VALUES (g_empresa,g_num_credito,v_fecha_progra,v_proceso,
                    g_tasa_interes,
                    g_tasa_morato, 0,0,0,0,0,0,0,"");

         ELSE
            LET v_codret = "314"; --fecha de proxima revision nula
            RETURN v_codret, g_num_credito;
         END IF;
      END IF;

      IF v_codret = "000" THEN
         -- #############################################################
         -- ### Actualizacion del Registro del maecred con los nuevos ###
         -- ### Valores de las tasas ordinaria y moratoria            ###
         -- #############################################################

         UPDATE sd_revtasa SET
                 (fecha_prox_rev) =
                 (vrt_fecha_prox_rev)
         WHERE num_credito = g_num_credito
         AND empresa = g_empresa;

         UPDATE sd_maecred SET (rev_tasa_var_per,
                                dia_para_revisar,
                                tasa_interes,
                                tasa_moratorios) =
                               (vrt_per_rev_tvp,
                                vrt_cada_cuanto,
                                v_tasa_int,
                                v_tasa_mor)
         WHERE num_credito = g_num_credito
         AND empresa       = g_empresa;

         LET g_tasa_interes  =   v_tasa_int;
         LET g_tasa_morato   =   v_tasa_mor;


      ELSE
         RETURN v_codret, g_num_credito;
      END IF


   RETURN v_codret, g_num_credito;

END PROCEDURE

DOCUMENT
"Procedimiento para la  revision de tasa,",
"spl que obtine el valor de la tasa y proyecta su fecha de",
"proxima revision",
"base de datos : bdicred" ,
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 19/abril/2001",
"Ver.  : 1.0",
"Mod   : Por Raul Mendoza",
"      : Los creditos con tasa fija no deben de ser revizados",
"      : 11/julio/2001";

CREATE PROCEDURE "informix".cont_int_nor(vbandprovi       SMALLINT,
                              vbandprorr       SMALLINT,
                              provision        DECIMAL(14,2),
                              interes_proreno  DECIMAL(14,2),
                              provi_venc_nor   DECIMAL(14,2),
                              provi_venc_ant   DECIMAL(14,2),
                              vistatus_cuota   CHAR(1),
                              p_fecha_proceso  DATE)
       RETURNING CHAR(5);


   DEFINE GLOBAL g_num_credito        CHAR(20)       DEFAULT " ";
   DEFINE GLOBAL g_divisa             CHAR(2)        DEFAULT " ";
   DEFINE GLOBAL g_num_producto       char(4)        DEFAULT " ";
   DEFINE GLOBAL g_sucursal           char(4)        DEFAULT " ";
   DEFINE GLOBAL g_campo_trab3        CHAR(10)       DEFAULT " ";
   DEFINE GLOBAL g_es_fisica          CHAR(1)        DEFAULT " ";
   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";
   DEFINE GLOBAL g_mensaje            CHAR(3)       DEFAULT " ";

   DEFINE GLOBAL g_fecha_hoy          date           DEFAULT " ";
   DEFINE GLOBAL g_codigo_fun         CHAR(3)        DEFAULT "034";

   DEFINE v_monto           DECIMAL(14,2);
   DEFINE wcodigo_ref       SMALLINT;
   DEFINE v_num_cuota       SMALLINT;
   DEFINE v_folio_suc       CHAR(16);
   DEFINE v_codret          CHAR(5);
   DEFINE v_usuario         CHAR(8);
   DEFINE v_hora            DATETIME HOUR TO FRACTION(3);
   DEFINE v_hora_c1         CHAR(12);
   DEFINE v_hora_c2         CHAR(8);


   LET v_monto        = 0;
   LET wcodigo_ref    = 0;
   LET v_num_cuota    = 0;
   LET v_folio_suc    = "               ";
   LET v_codret       = "000";
   LET v_usuario      = USER;
   LET v_hora         = CURRENT HOUR TO FRACTION;
   LET v_hora_c1      = v_hora;
   LET v_hora_c2      = v_hora_c1;
   LET v_folio_suc    = TRIM(v_usuario) || TRIM(v_hora_c2);

   -- #########################################################
   -- ###      Provision Diaria  o Provision Mensual       ####
   -- #########################################################

   IF vbandprovi = 1 THEN         -- Provison de interes

      -- IF g_campo_trab3 = "E" AND provi_venc_nor = 0 THEN
      IF g_campo_trab3 = "E" THEN

         IF g_es_fisica = "S" THEN
            LET wcodigo_ref = 91;     -- provision de intereses sobre 6617
                                      -- cap vig. cartera asociada Tran 
         ELSE
            LET wcodigo_ref = 94;     -- provision de intereses sobre 6618
                                      -- cap vig. cartera asociada Tran 
         END IF;

      ELSE
         LET wcodigo_ref = 11;     -- provision de intereses sobre
                                   -- cap vig  6673
      END IF;

      LET v_monto     = 0;
      LET v_monto     = provision;

      IF v_monto > 0 THEN
         CALL genmov(g_empresa,g_num_credito, g_num_producto,
                     wcodigo_ref,   g_codigo_fun, g_fecha_hoy,
                     v_monto,       v_folio_suc,  g_sucursal,
                     g_divisa,      "0000")
         RETURNING v_codret,g_mensaje;

      END IF;

      IF g_campo_trab3 = "E" AND provi_venc_nor <> 0 THEN

            LET wcodigo_ref = 11;     -- provision de intereses sobre
                                      -- cap vig  6673
   
            LET v_monto     = 0;
            LET v_monto     = provi_venc_nor;
   
            IF v_monto != 0 THEN
               CALL genmov(g_empresa,g_num_credito, g_num_producto,
                           wcodigo_ref,   g_codigo_fun, g_fecha_hoy,
                           v_monto,       v_folio_suc,  g_sucursal,
                           g_divisa,      "0000")
               RETURNING v_codret,g_mensaje;
      
            END IF;

      END IF;

      IF interes_proreno > 0 THEN -- Si prorrogada Renovada
         LET v_monto      = 0;
         LET wcodigo_ref  = 22;      -- Provision de interes sobre
                                     -- cap vig pro/reno 6673

         LET v_monto      = interes_proreno;

         IF v_monto > 0 THEN
            CALL genmov(g_empresa,g_num_credito, g_num_producto,
                        wcodigo_ref,   g_codigo_fun, g_fecha_hoy,
                        v_monto,       v_folio_suc,  g_sucursal,
                        g_divisa,      "0000")
            RETURNING v_codret,g_mensaje;
         END IF;

      END IF;

   END IF;


   IF vbandprorr = 1 THEN        -- Prorrateo de interes
                                 -- Int cob por ant.a resultados
                                 -- 6612
         LET v_monto     = 0;
         LET wcodigo_ref = 13;

         LET v_monto     = provision ;

         IF v_monto > 0 THEN
         CALL genmov(g_empresa,g_num_credito, g_num_producto,
                     wcodigo_ref,   g_codigo_fun, g_fecha_hoy,
                     v_monto,       v_folio_suc,  g_sucursal,
                     g_divisa,      "0000")
         RETURNING v_codret,g_mensaje;
         END IF;

   END IF;

   RETURN v_codret;

END PROCEDURE
DOCUMENT
"Funcion que contabiliza los intereses normales en el cierre de credito",
"AUTOR : Jose Cruz Narvaez",
"FECHA : 2/Mayo/2001",
"Ver.  : 1.0",
"BD.   : bdicred",
"Mod.  : ";

create procedure "informix".cargainstacash()
       returning char(5);

   define vcodret char(20);
   define vrowid, vsqlerr integer;
   define vsucursal char(4);    
   define vusuario char(8);  
   define vtransacc char(4);       
   define vtransuc char(4);
   define vfoliosuc char(16);
   define vnum_credito char(20);
   define vmonto money(16,2);
   define vdivisa char(02);      
   define vreferencia char(49);
   define vfecha_hoy date; 
   define vsaldo money(16,2);    


   let vcodret  = "000";

begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   select fecha_hoy into vfecha_hoy
      from sd_fechas
      where empresa = "001";

	begin work;
   foreach
      select rowid,sucursal,usuario,transacc,transuc,foliosuc,num_credito,
             monto,divisa,referencia
         into vrowid,vsucursal,vusuario,vtransacc,vtransuc,vfoliosuc,
              vnum_credito,vmonto,vdivisa,vreferencia
         from sd_instacash
         where aplicado <> "S"	

      call cargoref_td(vsucursal,vusuario,vtransacc,vtransuc,vfoliosuc,
                       vnum_credito,vmonto,vdivisa,vreferencia)
           returning vcodret,vtransacc,vfecha_hoy,vsaldo,vmonto;

      if vcodret = "00000" then
         update sd_instacash
            set codret = vcodret,
                aplicado = "S"
            where rowid = vrowid;
      else
         update sd_instacash
            set codret = vcodret,
                aplicado = "N"
            where rowid = vrowid;
      end if
   end foreach
	commit work;
   let vcodret = "000";
   return vcodret;
end
end procedure;