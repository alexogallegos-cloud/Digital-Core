CREATE PROCEDURE "informix".entre_chq(mempresa char(3),
                           msucursal CHAR(4),
                           musuario  CHAR(8),
                           mcuenta   CHAR(20),
                           mnum_ini  INTEGER,
                           mcan_cheq SMALLINT,
                           mtp_cheq  CHAR(2),
                           mnro_cheq SMALLINT)
RETURNING CHAR(5), CHAR(60);

--------------------------------------------------------------------------
--Definicion de Variables
--------------------------------------------------------------------------

DEFINE cod_ret       CHAR(5);
DEFINE v_nombrecte   CHAR(60);
DEFINE v_razon_soc   CHAR(35);
DEFINE estatus       CHAR(1);
DEFINE sucur         CHAR(4);
DEFINE v_producto    CHAR(4);
DEFINE fecha         DATE;
DEFINE v_cal_int_chq,
       v_sin_inv,
       v_con_doctos,
       v_mod_inv     CHAR(1);
DEFINE v_numcte      CHAR(20);
DEFINE v_usuario     CHAR(8);

DEFiNE v_reposicion,
       v_numchqs,
       longitud,
       v_long_cta,
       v_reorden     SMALLINT;

DEFINE v_nombre1,
       v_nombre2,
       v_appat,
       v_apmat       CHAR(12);

DEFINE v_proveedor,
       v_plaza       CHAR(3);

DEFINE v_stock,
       v_ultnva,
       v_row,
       v_row2,
       ultimo_chq,
       ultimo_chq2,
       ultimo_chqsc,
       a, b, c, d, e,
       i, num,
       sql_err,
       alta_ent,
       v_ult_ent,
       v_pagados,
       v_calculo,
       v_chq_prov,
       vinicial,
       alta_stock   INTEGER;

DEFINE cuen,
       cta         CHAR(20);

DEFINE v_moneda,
       v_monedaint,
       vtp_nchequera,
       vtp_chequera CHAR(2);

DEFINE r_sucursal         CHAR(4);
DEFINE r_cuenta           CHAR(20);
DEFINE r_inicial          INTEGER ;
DEFINE r_final            INTEGER;
DEFINE r_fecha_req        DATE  ;
DEFINE r_estado           CHAR(1);
DEFINE r_fecha_rec        DATE  ;
DEFINE r_fecha_ent        DATE  ;
DEFINE r_proveedor        CHAR(3);
DEFINE r_num_pedido       INTEGER;
DEFINE r_usuario          CHAR(8);
DEFINE r_tpo_persona      CHAR(3);
DEFINE v_tran_com         CHAR(4);
DEFINE v_divisa           CHAR(2);
DEFINE v_maxchq           SMALLINT;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--Asignacion de Variables
--------------------------------------------------------------------------
LET cod_ret = "000";
LET a = mnum_ini;
LET b = mcan_cheq;
LET ultimo_chq = 0;
LET ultimo_chq2 = 0;
LET v_nombrecte = "SIN NOMBRE";

--COMMIT WORK;
--BEGIN WORK;
BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         --ROLLBACK WORK;
         RETURN cod_ret, v_nombrecte;
      END IF;
   END EXCEPTION;

   -------------------------------------------------------------------------
   --Validacion de que la sucursal no venga en blancos
   -------------------------------------------------------------------------
   IF msucursal = ""  OR msucursal=" " THEN
      LET cod_ret = "110";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   SELECT ejecutivo INTO v_usuario FROM bdinteg:si_ejecut
    WHERE ejecutivo = musuario;
   IF v_usuario <> musuario or v_usuario IS NULL THEN
      LET cod_ret = "106";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;
   -------------------------------------------------------------------------
   --Validacion de que el usuario no venga en blancos
   -------------------------------------------------------------------------
   IF musuario = "" or musuario = " " THEN
      LET cod_ret = "110";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;


   -------------------------------------------------------------------------
   --Validacion de que la cantidad de cheques no venga en ceros
   -------------------------------------------------------------------------
   IF mcan_cheq = 0 THEN
      LET cod_ret = "110";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   -------------------------------------------------------------------------
   --Validacion de que el numero inicial de cheques no venga en ceros
   -------------------------------------------------------------------------
   IF mnum_ini = 0 THEN
      LET cod_ret = "110";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   -------------------------------------------------------------------------
   --Validacion de la cuenta
   -------------------------------------------------------------------------
   IF mcuenta = "" or mcuenta=" "  THEN
      LET cod_ret = "110";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   SELECT rowid, cuenta, status_cta, ult_chq
   INTO v_row, cta, estatus, ultimo_chq FROM sc_maechq
   WHERE empresa = mempresa and cuenta = mcuenta;

   IF cta is null THEN
      LET cta = "0";
   END IF;
   IF mcuenta != cta THEN
      LET cod_ret = "100";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;
   IF estatus IN("2","6","7","8") THEN
      LET cod_ret = "200";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   -------------------------------------------------------------------------
   --Validacion de la cantidad de cheques no sea mayor de 300
   -------------------------------------------------------------------------
   IF mcan_cheq > 300 THEN
      LET cod_ret = "555";
      --ROLLBACK WORK;
      RETURN cod_ret, v_nombrecte;
   END IF;

   -------------------------------------------------------------------------
   --Validacion del numero del cheque  no haya sido
   --contemplado en otra chequera. Incremeetar el ultimo cheque.
   -------------------------------------------------------------------------

   LET ultimo_chqsc =  ultimo_chq;
   LET ultimo_chq = (mnum_ini + mcan_cheq -1);
   LET ultimo_chq2 = (mnum_ini + mcan_cheq -1);

   -------------------------------------------------------------------------
   --Accesando la fecha del calendario
   -------------------------------------------------------------------------
   SELECT fecha_hoy INTO fecha FROM sc_fechas where empresa = mempresa;

   -- **********************************************************************
   --                Carga Parametros de Chequeras
   -- **********************************************************************
   SELECT chq_sin_inv, chq_con_doctos, mod_inv, proveedor_default, tran_comision
     INTO v_sin_inv, v_con_doctos, v_mod_inv, v_proveedor, v_tran_com
     FROM bdicntchq:sq_paramgen;

   IF v_sin_inv IS NULL OR v_sin_inv = "" THEN
      LET cod_ret = "558";
      RETURN cod_ret, v_nombrecte;
   END IF;
   IF v_con_doctos IS NULL OR v_con_doctos = "" THEN
      LET cod_ret = "558";
      RETURN cod_ret, v_nombrecte;
   END IF;
   IF v_mod_inv IS NULL OR v_mod_inv = "" THEN
      LET cod_ret = "558";
      RETURN cod_ret, v_nombrecte;
   END IF;
   IF v_proveedor IS NULL OR v_proveedor = "" THEN
      LET cod_ret = "558";
      RETURN cod_ret, v_nombrecte;
   END IF;
   -- Las siguientes lineas se comentaron: LAMQ l2/09/2000
   --IF v_tran_com IS NULL OR v_tran_com = "" THEN
   --   LET cod_ret = "558";
   --   RETURN cod_ret, v_nombrecte;
   --END IF;

   ---- Rutinas de control de chequeras ---
   SELECT rowid INTO v_row2 FROM bdicntchq:sq_stocknvas
   WHERE cuenta = mcuenta;

   IF v_row2 IS NOT NULL THEN
         -- *************************************************************
         --     Valida si se entrega la chequera con doctos pagados
         -- *************************************************************
      IF v_mod_inv <> "N" THEN
         IF v_con_doctos = "N" THEN
            SELECT COUNT(*) INTO v_pagados FROM sc_contch
             WHERE empresa = mempresa and cuenta = mcuenta
             AND (numero >= mnum_ini
             AND numero <= mnum_ini + mcan_cheq -1)
             AND estado = "P";
             IF v_pagados <> 0 THEN
                LET cod_ret = "501";
                RETURN cod_ret, v_nombrecte;
             END IF;
          END IF;

          ----------------------------------------------------------------
          -- Valida el Tipo de Chequera y el Nro. de Talonarios ( NUEVAS )
          ----------------------------------------------------------------
          -- Extrae Datos de Chequera Nueva
          SELECT rowid, ult_cheque, divisa
            INTO v_row2, v_ultnva, v_divisa
            FROM bdicntchq:sq_stocknvas
           WHERE cuenta=mcuenta;

          IF v_row2 IS NULL OR v_row2 = "" THEN
             LET cod_ret="560";
             RETURN cod_ret, v_nombrecte;
          END IF;

           SELECT chequera, no_cheques INTO vtp_chequera, v_numchqs
             FROM bdicntchq:sq_chequera
            WHERE divisa = v_divisa
              AND ctas_nvas="1";

          -- Verifica numero de Doctos sea igual al del talonario asignado

          IF MOD(v_numchqs,mcan_cheq)> 0 THEN
             LET cod_ret="561";
             RETURN cod_ret, v_nombrecte;
          END IF;

          IF (mcan_cheq <> v_numchqs) AND mtp_cheq = "00"  THEN
             LET cod_ret = "561";
             RETURN  cod_ret, v_nombrecte;
          END IF

          SELECT estado INTO r_estado FROM bdicntchq:sq_reqnvos
           WHERE cuenta = mcuenta
             AND inicial = mnum_ini;
          IF r_estado <> "E" THEN
            LET cod_ret = "562";
            RETURN  cod_ret, v_nombrecte;
          END IF

          SELECT MIN(inicial) INTO vinicial
             FROM bdicntchq:sq_reqnvos
             WHERE cuenta = mcuenta AND estado = "E";
          IF vinicial <> mnum_ini THEN
            LET cod_ret = "563";
            RETURN  cod_ret, v_nombrecte;
          END IF

          -- Incorporaci¢n del IF para que realice correctamente la
          -- Entrega de Chequeras de Cuentas Nuevas
          IF v_ultnva = "25" THEN
             LET v_ultnva = "1000025";
             UPDATE sc_maechq SET ult_chq = "1000000"
                where empresa = mempresa and cuenta = mcuenta;
          END IF

          IF v_ultnva < ultimo_chq THEN
             LET cod_ret="563";
             RETURN cod_ret, v_nombrecte;
          END IF

          SELECT plaza, producto, nombre1, nombre2, apell_paterno,
                 apell_materno, razon_social
            INTO v_plaza, v_producto, v_nombre1, v_nombre2,
                 v_appat, v_apmat, v_razon_soc
            FROM sc_maechq, bdinteg:si_cliente
           WHERE sc_maechq.num_cte = bdinteg:si_cliente.numcte
             AND sc_maechq.empresa = mempresa and cuenta=mcuenta;

          LET v_nombrecte = trim(trim(v_appat)||" "||trim(v_apmat)||" "||trim(v_nombre1)||" "||trim(v_nombre2)||" "||trim(v_razon_soc));

          IF mtp_cheq <> "00" THEN
                SELECT no_cheques, max_repos INTO v_numchqs, v_maxchq
                  FROM bdicntchq:sq_chequera
                 WHERE chequera = mtp_cheq
                   AND divisa = v_divisa;
          ELSE
                SELECT no_cheques, max_repos INTO v_numchqs, v_maxchq
                  FROM bdicntchq:sq_chequera
                 WHERE ctas_nvas = "1"
                   AND divisa = v_divisa;
          END IF

          IF mnro_cheq <> 0 THEN
                IF mnro_cheq > v_maxchq THEN
                        LET cod_ret = "1203";
                        RETURN cod_ret, v_nombrecte;
                END IF
          END IF

          FOR i = 1 TO mnro_cheq
                LET c=v_ultnva + 1;
                LET d=v_ultnva + v_numchqs;
          --    LET e=v_ultnva - mcan_cheq; --LAMQ 08/03/2000
                INSERT INTO bdicntchq:sq_reqctes
                 VALUES(msucursal, mcuenta, v_divisa, c, d, fecha, fecha,
                        fecha, "X", v_proveedor, 0, musuario);
                LET v_ultnva=d;
          END FOR
--  LET ultimo_chq=d;

          --LAMQ 08/03/2000
          --Se inserta la diferencia entre el ult_cheque (sq_stocknvas) y
          --el parametro mcan_cheq que viene en la variable e.
          --Ademas se cambia la variable d por la variable v_ultnva.
          INSERT INTO bdicntchq:sq_stockctes
             VALUES(msucursal, mcuenta,v_divisa, mtp_cheq,mnro_cheq,v_nombrecte,
                    mcan_cheq, 0, fecha, v_proveedor, 2, d);

          DELETE FROM bdicntchq:sq_stocknvas WHERE cuenta=mcuenta;

          UPDATE bdicntchq:sq_reqnvos SET estado = "L", fecha_ent = fecha,
                                          usuario = musuario
           WHERE cuenta = mcuenta
             AND inicial = mnum_ini;

          -- Pasa Detalle a Clientes
          FOREACH SELECT * INTO r_sucursal, r_cuenta, v_divisa, r_inicial,
                                r_final, r_fecha_req, r_estado, r_fecha_rec,
                                r_fecha_ent, r_proveedor, r_num_pedido,
                                r_usuario, r_tpo_persona
                    FROM bdicntchq:sq_reqnvos
                   WHERE cuenta = mcuenta

                   INSERT INTO bdicntchq:sq_reqctes
                      VALUES (r_sucursal, r_cuenta, v_divisa,r_inicial, r_final,
                              r_fecha_req, r_fecha_rec, r_fecha_ent,
                              r_estado, r_proveedor, r_num_pedido,r_usuario);

                   DELETE FROM bdicntchq:sq_reqnvos
                    WHERE cuenta = r_cuenta
                      AND inicial = r_inicial;

            END FOREACH

            SELECT valor INTO v_monedaint 
               FROM bdinteg:si_param
               where empresa = mempresa and cod_param = "codigo mn";
            IF r_tpo_persona = "005" THEN -- Persona Juridica (Moral)
                UPDATE bdicntchq:sq_paramnvas SET (inventario) =
                                                  (inventario - 1)
                WHERE sucursal = msucursal
                  AND divisa = v_divisa
                  AND tpo_persona = "M";
            ELSE -- Persona Fisica (Natural)
                UPDATE bdicntchq:sq_paramnvas SET (inventario) =
                                                  (inventario - 1)
                WHERE sucursal = msucursal
                  AND divisa = v_divisa
                  AND tpo_persona = "F";
            END IF;
       END IF;
    ELSE
       -----------------------------------------------------------------
       --       Actualiza Parametros de Tipo de Chequera ( REPOSICION )
       -----------------------------------------------------------------
       -- **************************************************************
       --      Valida si se entrega la chequera con ddctos pagados
       -- **************************************************************
       IF v_mod_inv <> "N" THEN
          IF v_con_doctos = "N" THEN
             SELECT COUNT(*) INTO v_pagados FROM sc_contch
             WHERE empresa = mempresa and  cuenta = mcuenta
             AND (numero >= mnum_ini
             AND numero <= mnum_ini + mcan_cheq -1)
             AND estado = "P";
             IF v_pagados <> 0 THEN
                LET cod_ret = "501";
                --ROLLBACK WORK;
                RETURN cod_ret, v_nombrecte;
             END IF;
          END IF;

          SELECT divisa, chequera, nro_chequeras
            INTO v_divisa, vtp_chequera,vtp_nchequera
            FROM bdicntchq:sq_stockctes
           WHERE cuenta=mcuenta;
          IF mtp_cheq <>  "00" THEN
             IF vtp_chequera <> mtp_cheq  THEN
                UPDATE bdicntchq:sq_stockctes SET chequera = mtp_cheq
                WHERE cuenta = mcuenta;
             END IF;
          ELSE
             IF vtp_chequera = "" OR vtp_chequera = "00" THEN
                SELECT chequera INTO vtp_chequera FROM bdicntchq:sq_chequera
                WHERE ctas_nvas="1"
                  AND divisa = v_divisa;
                UPDATE bdicntchq:sq_stockctes SET chequera = vtp_chequera
                WHERE cuenta = mcuenta;
             END IF;
          END IF;

          IF mnro_cheq <> 0  THEN
             IF vtp_nchequera <> mnro_cheq THEN
                UPDATE bdicntchq:sq_stockctes SET reorden = mnro_cheq
                WHERE cuenta = mcuenta;
             END IF;
          ELSE
             IF vtp_nchequera = 0 OR vtp_nchequera IS NULL THEN
                SELECT max_repos INTO vtp_chequera FROM bdicntchq:sq_chequera
                 WHERE ctas_nvas="1"
                   AND divisa = v_divisa;
                UPDATE bdicntchq:sq_stockctes SET nro_chequeras = vtp_chequera
                 WHERE cuenta = mcuenta;
             END IF;
        END IF;

        -- Extrae Datos de Chequera
        SELECT a.rowid,
               a.ultimo_ent,
               a.divisa,
               a.ultimo_stock,
               a.proveedor,
               a.reorden,
               a.nro_chequeras,
               b.no_cheques,
               a.chq_prov
        INTO v_row2, v_ult_ent, v_divisa, v_stock, v_proveedor, v_reorden,
             v_reposicion, v_numchqs, v_chq_prov
        FROM bdicntchq:sq_stockctes a, bdicntchq:sq_chequera b
       WHERE a.cuenta   = mcuenta
         AND a.chequera = b.chequera
         AND a.divisa   = b.divisa;

        IF v_stock is null THEN
           LET cod_ret="560";
           --ROLLBACK WORK;
           RETURN cod_ret, v_nombrecte;
        END IF;

        IF mcan_cheq > v_stock THEN
           IF v_sin_inv <> "S" THEN
              LET cod_ret="561";
              --ROLLBACK WORK;
              RETURN cod_ret, v_nombrecte;
           END IF;
        END IF;

        IF mod(mcan_cheq, v_numchqs)> 0 THEN
           LET cod_ret="1222";
           RETURN cod_ret, v_nombrecte;
        END IF;

        IF mcan_cheq <> v_numchqs THEN
            LET cod_ret = "1223";
            RETURN  cod_ret, v_nombrecte;
        END IF

        SELECT estado INTO r_estado FROM bdicntchq:sq_reqctes
         WHERE cuenta = mcuenta
           AND inicial = mnum_ini;
        IF r_estado <> "E" OR r_estado IS NULL THEN
            LET cod_ret = "561";
            RETURN  cod_ret, v_nombrecte;
        END IF

        SELECT MIN(inicial) INTO vinicial
           FROM bdicntchq:sq_reqctes
           WHERE cuenta = mcuenta AND estado = "E";
        IF vinicial <> mnum_ini THEN
           LET cod_ret = "563";
           RETURN  cod_ret, v_nombrecte;
        END IF

        -- Actualiza Inventario
        IF v_mod_inv = "S" THEN
           IF v_ult_ent >  ultimo_chq THEN
                LET cod_ret="564";
                RETURN cod_ret, v_nombrecte;
           ELSE
              LET v_stock = v_stock - mcan_cheq;
              UPDATE bdicntchq:sq_stockctes
              SET (ultimo_ent,ultimo_stock) = (ultimo_chq, v_stock)
              WHERE rowid=v_row2;

              UPDATE bdicntchq:sq_reqctes SET (estado, fecha_ent, usuario)=
                                              ("L", fecha, musuario)
               WHERE cuenta = mcuenta
                 AND inicial = mnum_ini;
           END IF;

           SELECT COUNT(*) INTO v_stock FROM bdicntchq:sq_reqctes
            WHERE cuenta = mcuenta
              AND estado  NOT IN ("L", "A");
           -- Genera Requerimiento
           LET v_stock = v_reorden - v_stock;
           IF v_stock > 0 THEN
              LET i = 0;
              FOR i = 1 TO v_stock
                 LET c = v_chq_prov + 1;
                 LET d = v_chq_prov + v_numchqs;
                 INSERT INTO bdicntchq:sq_reqctes
                    VALUES(msucursal, mcuenta, v_divisa, c, d, fecha, fecha,
                           fecha, "X", v_proveedor, 0, musuario);
                 LET v_chq_prov=v_chq_prov + v_numchqs;
              END FOR
              UPDATE bdicntchq:sq_stockctes SET chq_prov = d
               WHERE cuenta = mcuenta;
           END IF;
        END IF;
     END IF;
  END IF;

          SELECT plaza, producto, nombre1, nombre2, apell_paterno,
                 apell_materno, razon_social
            INTO v_plaza, v_producto, v_nombre1, v_nombre2,
                 v_appat, v_apmat, v_razon_soc
            FROM sc_maechq, bdinteg:si_cliente
           WHERE sc_maechq.num_cte = bdinteg:si_cliente.numcte
             AND sc_maechq.empresa = mempresa and cuenta=mcuenta;

          LET v_nombrecte = trim(trim(v_appat)||" "||trim(v_apmat)||" "||trim(v_nombre1)||" "||trim(v_nombre2)||" "||trim(v_razon_soc));

  --------------------------------------------------------------------------
  --Creando la tabla de control de cheques
  --------------------------------------------------------------------------
  WHILE b <> 0
     IF EXISTS( SELECT cuenta, numero FROM sc_contch
                WHERE empresa = mempresa and cuenta = mcuenta AND
                      numero = a ) THEN

        INSERT INTO bdicntchq:sq_duplicados VALUES(mcuenta,a,fecha);
     ELSE
        INSERT INTO sc_contch VALUES (mempresa,mcuenta,a," ",fecha,0);
     END IF;

     LET b = b - 1;
     LET a = a + 1;
  END WHILE;

  --------------------------------------------------------------------------
  --Actualizando el ultimo cheque del maestro
  --------------------------------------------------------------------------
  IF ultimo_chqsc < mcan_cheq or ultimo_chq2 >= mcan_cheq THEN
     update sc_maechq SET (ult_chq)= (ult_chq + mcan_cheq)
     WHERE rowid=v_row;
  END IF;

  LET cod_ret = "000";
--  COMMIT WORK;
  RETURN cod_ret, v_nombrecte;
END
END PROCEDURE;