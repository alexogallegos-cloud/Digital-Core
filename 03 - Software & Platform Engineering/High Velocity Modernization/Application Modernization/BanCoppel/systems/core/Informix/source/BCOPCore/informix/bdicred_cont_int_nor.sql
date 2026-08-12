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