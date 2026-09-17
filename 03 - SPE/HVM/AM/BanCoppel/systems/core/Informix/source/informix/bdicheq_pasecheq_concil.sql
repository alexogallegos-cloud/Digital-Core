CREATE PROCEDURE "informix".pasecheq_concil(pempresa char(3))

RETURNING char(5),CHAR(5), varchar(80);

   DEFINE GLOBAL vg_secuencia INTEGER   DEFAULT 0;
   DEFINE vcodret char(5);
   DEFINE vfecha_hoy date;
   DEFINE min_fecha  DATE;
   DEFINE min_fecha1  DATE;
   DEFINE difer_fechas INTEGER;
   DEFINE difer_fechas1 INTEGER;
   DEFINE vsqlerr integer;
   DEFINE vsucopero_ref  char(4);
   DEFINE vproducto      char(4);
   DEFINE vmoneda        char(2);
   DEFINE vtransacc      char(4);
   DEFINE vmonto_tot     money(14,2);
   DEFINE vexento_isr    char(1);
   DEFINE vsector        char(2);
   DEFINE vvaloriza      char(1);
   DEFINE vcancelad      char(1);
   DEFINE vsuccta        char(4);
   DEFINE wdescripcion   char(50);
   DEFINE wabreviatura   char(50);
   DEFINE vfechaproc     date;
   DEFINE vporcentaje    decimal(9,6);
   DEFINE vtasa_bruta, vsobretasa decimal(9,6);
   DEFINE vtpcambval    decimal(14,6);
   DEFINE vmonto1, vmonto2 money(14,2);
   DEFINE vdivisa_cambio char(2);
   DEFINE vcodigo_mn     char(2);
   DEFINE v_sistema      char(2);
   DEFINE vtransacc_t1,vtranprovint char(4);
   DEFINE vcobraisr      char(1);
   DEFINE vexiste        integer;
   DEFINE vexistefin     integer;
   DEFINE vproceso       char(10);
   DEFINE vsistema       char(02);
   DEFINE vestatusproc   char(1);
   DEFINE vhora_tc       datetime hour to minute;
   DEFINE vt_cuenta      char(20);
   DEFINE vt_folio_suc   char(16);
   DEFINE vt_fech_hor    datetime hour to minute;
   DEFINE vdummy1        char(5);
   DEFINE vdummy2        char(20);
   DEFINE vt_naturaleza  char(1);
   DEFINE v_dias_resp    INTEGER;
   DEFINE v_dias_resp1   INTEGER;
   DEFINE vcontador      INTEGER;
   DEFINE vcontador1     INTEGER;
   DEFINE vrowid         INTEGER;
   DEFINE vrowid1         INTEGER;
   DEFINE v_registros    INTEGER;
   DEFINE v_registros1   INTEGER;

------ PRE-POLIZA CREDITO ----------
   DEFINE wcod_ret                      CHAR(5);
   DEFINE P_MENSAJE                     VARCHAR(80);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;
   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(30);
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
 /**         INICIA REGISTRO DE PASE CONTABLE                               **/
   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wsecuencia                    SMALLINT;
   DEFINE wvaloriza                     CHAR(1);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);
   DEFINE wamayor                       CHAR(4);
   DEFINE wasub1                        CHAR(3);
   DEFINE wasub2                        CHAR(3);
   DEFINE wasub3                        CHAR(3);
   DEFINE wasub4                        CHAR(3);
   DEFINE wasector                      CHAR(3);
   DEFINE wmonto                        MONEY(14,2);
 /**      TERMINA REGISTRO DE PASE CONTABLE - INICIA REGISTRO DETPOL     */
   DEFINE detusuario                    CHAR(11);
   DEFINE pusuariopase                  CHAR(11);
   DEFINE detcontrol_poliza             SMALLINT;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  INTEGER;
   DEFINE detempresa                    CHAR(3);
   DEFINE detmayor                      CHAR(4);
   DEFINE detsub1                       CHAR(3);
   DEFINE detsub2                       CHAR(3);
   DEFINE detsub3                       CHAR(3);
   DEFINE detsub4                       CHAR(3);
   DEFINE detsector                     CHAR(3);
   DEFINE detciudad                     CHAR(3);
   DEFINE detsucursal                   CHAR(4);
   DEFINE detnro_auxiliar               CHAR(9);
   DEFINE detnaturaleza                 CHAR(1);
   DEFINE detmonto                      MONEY(14,2);
   DEFINE detdescripcion_det            CHAR(30);
   DEFINE detfecha_valida               DATE;
   DEFINE detmoneda                     CHAR(2);
   DEFINE detpoliza_usuario             CHAR(11);
 /**   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **/
   DEFINE dsecuencia                    INTEGER;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);
   DEFINE icontador INTEGER;
----------------------------------------------------------------------------------
   LET v_registros = 0;
   LET v_registros1 = 0;
   LET difer_fechas = 0;
   LET difer_fechas1 = 0;
   LET vcontador = 1;
   LET vcontador1 = 1;
   LET vrowid = 0;
   LET vrowid1 = 0;
   LET v_dias_resp = 0;
   LET v_dias_resp1 = 0;
   LET vcodret  = "000";
   let wcod_ret = "000";
   let P_MENSAJE = "";
   LET vsistema = "01";
   LET vproceso = "pasechq";
   LET vg_secuencia = 0;

   --SET debug file to "/tmp/pasecheq_concil.out";
   --trace on;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,wcod_ret, P_MENSAJE;
      END IF;
   END EXCEPTION;

   -- Asigna la fecha de hoy
   SELECT fecha_ant INTO vfecha_hoy
   FROM sc_fechas WHERE empresa = pempresa;


   ---------- DEPURACION DE CAPTACION ----------
   SELECT count(*) INTO v_registros FROM sc_contab_prep
    WHERE fecha_captura = vfecha_hoy
      AND usuario IS NOT NULL;

        IF v_registros > 0 THEN
            RETURN vcodret,wcod_ret, P_MENSAJE;
        END IF;

   SELECT count (DISTINCT fecha_captura) INTO v_dias_resp FROM sc_contab_prep;

        IF v_dias_resp >= 7 THEN

            SELECT MAX(fecha_captura) - 7 UNITS DAY 
              INTO min_fecha 
              FROM bdicheq:sc_contab_prep;
    
            FOREACH WITH HOLD
				SELECT rowid INTO vrowid
                  FROM sc_contab_prep
                 WHERE fecha_captura <= min_fecha
                   AND usuario IS NOT NULL

                    IF vcontador = 1 THEN
                        BEGIN WORK;
                    END IF;

                    DELETE FROM sc_contab_prep WHERE rowid = vrowid;

                    IF vcontador >= 3000 THEN
						COMMIT WORK;
                        LET vcontador = 1;
                    ELSE
						LET vcontador = vcontador + 1 ;
                    END IF;

            CONTINUE FOREACH;
            END FOREACH;

            IF vcontador > 1 THEN
                COMMIT WORK;
                LET vcontador = 1;
            END IF;

        END IF    

   ---------- DEPURACION DE CREDITO ----------
   SELECT count(*) INTO v_registros1 FROM bdicred:sd_contab_prep
    WHERE fecha_captura = vfecha_hoy
      AND usuario IS NOT NULL;

   IF v_registros1 > 0 THEN
      RETURN vcodret,wcod_ret, P_MENSAJE;
   END IF;

   SELECT count (DISTINCT fecha_captura) INTO v_dias_resp1 FROM bdicred:sd_contab_prep;

   IF v_dias_resp1 >= 7 THEN

		SELECT MAX(fecha_captura) - 7 UNITS DAY 
          INTO min_fecha1 
          FROM bdicred:sd_contab_prep;

        FOREACH WITH HOLD
			SELECT rowid INTO vrowid1
              FROM bdicred:sd_contab_prep
             WHERE fecha_captura <= min_fecha1
               AND usuario IS NOT NULL

                IF vcontador1 = 1 THEN
                    BEGIN WORK;
                END IF;

                DELETE FROM bdicred:sd_contab_prep WHERE rowid = vrowid1;

                IF vcontador1 >= 3000 THEN
                    COMMIT WORK;
                    LET vcontador1 = 1;
                ELSE
                    LET vcontador1 = vcontador1 + 1 ;
                END IF;

                CONTINUE FOREACH;
                END FOREACH;

                IF vcontador1 > 1 THEN
                    COMMIT WORK;
                    LET vcontador1 = 1;
                END IF;
   END IF
-------------------------

   EXECUTE PROCEDURE sp_buscatemporal('his1') INTO vdummy1, vdummy2,vdummy2;
   IF vdummy1 = '000' THEN
      DROP TABLE his1;
   END IF;

   SELECT valor INTO vdivisa_cambio
     FROM bdinteg:si_param
    WHERE empresa = pempresa AND descripcion = "divisa cambio";

   SELECT valor INTO vcodigo_mn
     FROM bdinteg:si_param
    WHERE empresa = pempresa AND descripcion = "codigo mn";

   SELECT valor INTO vtransacc_t1
     FROM sc_param
    WHERE empresa = pempresa AND codparam = "tranlibsbc";

   SELECT valor INTO vtranprovint
     FROM sc_param
    WHERE empresa = pempresa AND codparam = "tranprov";

   SELECT sistema INTO v_sistema
     FROM bdinteg:si_sistema
    WHERE siglas = "SC";

   --
   SELECT precio_venta INTO vtpcambval
     FROM bdinteg:si_tpcambio
    WHERE empresa = pempresa AND divisa = vdivisa_cambio AND
          fecha_tpcambio = vfecha_hoy AND
          clase_tpcambio = "O";
   IF vtpcambval IS NULL THEN
      SELECT max(hora_tc) INTO vhora_tc
      FROM bdinteg:si_histdiv
      WHERE empresa = pempresa AND divisa = vdivisa_cambio AND
            fecha_tc = vfecha_hoy
            AND clase_tpcambio = "O";
      SELECT precio_venta INTO vtpcambval
      FROM bdinteg:si_histdiv
      WHERE empresa = pempresa AND divisa = vdivisa_cambio AND
            fecha_tc = vfecha_hoy
            AND clase_tpcambio = "O"
            AND hora_tc = vhora_tc;
      IF vtpcambval is null then
         LET vtpcambval = 1;
      END IF
   END IF

   --
    SELECT cuenta, sucursal, producto, transacc, monto_tot, cancelad, folio_suc, fech_hor
      FROM sc_movhis
     WHERE empresa = pempresa
	   AND cuenta IS NOT NULL
       AND fech_alt = vfecha_hoy
	  INTO temp his1 WITH NO LOG;

    CREATE INDEX idx01his1 on his1(cuenta,cancelad);

    UPDATE STATISTICS MEDIUM FOR TABLE his1;

   FOREACH
      SELECT md.sucursal,md.producto,divisa,transacc,
             monto_tot,cl.sector,tr.valoriza,cancelad,
             mc.sucursal,tr.descripcion abreviatura,
             md.cuenta, md.folio_suc, md.fech_hor, tr.naturaleza
        INTO vsucopero_ref,vproducto,vmoneda,vtransacc,
             vmonto_tot,vsector,vvaloriza,vcancelad,
			 vsuccta,wabreviatura,
             vt_cuenta, vt_folio_suc, vt_fech_hor, vt_naturaleza
        FROM his1 md,sc_maechq mc,sc_producto pr,
	     bdinteg:si_transacc tr, bdinteg:si_cliente cl
        WHERE mc.empresa = pempresa
          AND mc.cuenta = md.cuenta
          AND pr.empresa = pempresa
          AND pr.producto = md.producto
          AND cl.numcte = mc.num_cte
		  AND md.cuenta = mc.cuenta
          AND md.cancelad <> "S"
		  AND tr.empresa = pempresa
		  AND tr.numero = md.transacc
          AND tr.se_contabiliza = "S"

      LET wdescripcion = wabreviatura;

      -- Verifica si es Transaccion de provision de Interes
      IF vtransacc = vtranprovint THEN
         IF vmoneda = vcodigo_mn THEN
           call extrae_cont_det(pempresa,1,vmonto_tot,vsucopero_ref,vproducto,
                                vmoneda,vtransacc,vsector,vcancelad,
                                vsuccta,wdescripcion,
                                vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                                vcodigo_mn, vtransacc_t1, v_sistema,vt_naturaleza) returning vcodret;
	   CONTINUE FOREACH;
	 END IF
	 IF vmoneda != vcodigo_mn AND vvaloriza = "S" THEN
	   CALL extrae_cont_det(pempresa,1,vmonto_tot,vsucopero_ref,vproducto,
                                vmoneda,vtransacc,vsector,vcancelad,
                                vsuccta,wdescripcion,
                                vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                                vcodigo_mn, vtransacc_t1, v_sistema,vt_naturaleza) returning vcodret;
           LET vmonto2 = vmonto_tot * vtpcambval;
	   CALL extrae_cont_det(pempresa,3,vmonto2,vsucopero_ref,vproducto,
                                vcodigo_mn,vtransacc,vsector,vcancelad,
                                vsuccta,wdescripcion,
                                vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                                vcodigo_mn, vtransacc_t1, v_sistema,vt_naturaleza) returning vcodret;
           CONTINUE FOREACH;
         END IF
      END IF

      -- Verifica si es movimiento valorizado
      IF vmoneda <> vcodigo_mn AND vvaloriza = "S"  THEN
        LET vmonto2 = vmonto_tot * vtpcambval;
	CALL extrae_cont_det(pempresa,3,vmonto2,vsucopero_ref,vproducto,
                             vcodigo_mn,vtransacc,vsector,vcancelad,
                             vsuccta,wdescripcion,
                             vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                             vcodigo_mn, vtransacc_t1, v_sistema, vt_naturaleza) returning vcodret;
      END IF

      IF vtransacc <> "0231" AND vtransacc <> "0232" AND vtransacc <> "3313" AND vtransacc <> "3314" AND
         vtransacc <> vtransacc_t1 AND vtransacc <> "0269" THEN
          CALL extrae_cont_det(pempresa,1,vmonto_tot,vsucopero_ref,vproducto,
                               vmoneda,vtransacc,vsector,vcancelad,
                               vsuccta,wdescripcion,
                               vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                               vcodigo_mn, vtransacc_t1, v_sistema, vt_naturaleza) returning vcodret;
      END IF

      --- Contabiliza Camara,231,232,3246,269
      IF vtransacc = "0231" OR vtransacc = "0232" OR
        vtransacc = "3313" OR vtransacc = "3314" OR
        vtransacc = vtransacc_t1 OR vtransacc = "0269" THEN
          CALL extrae_cont_det(pempresa,1,vmonto_tot,vsucopero_ref,vproducto,
                               vmoneda,vtransacc,vsector,vcancelad,
                               vsuccta,wdescripcion,
                               vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                               vcodigo_mn, vtransacc_t1, v_sistema, vt_naturaleza) returning vcodret;
          IF vtransacc = vtransacc_t1 OR vtransacc = "0269" THEN
             CALL extrae_cont_det(pempresa,2,vmonto_tot,vsucopero_ref,vproducto,
                                  vmoneda,vtransacc,vsector,vcancelad,
                                  vsuccta,wdescripcion,
                                  vt_cuenta,vt_folio_suc,vfecha_hoy, vt_fech_hor,
                                  vcodigo_mn, vtransacc_t1, v_sistema, vt_naturaleza) returning vcodret;
          END IF
      END IF
   END FOREACH
-----------
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET pusuariopase = 'credito';
   LET detusuario = pusuariopase;
   LET icontador = 1;

   LET wcod_ret = "000";
   LET vfecha_hoy = vfecha_hoy;

      IF vfecha_hoy IS NULL OR vfecha_hoy = " " THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM bdicred:sd_fechas
          WHERE empresa = pempresa;
      ELSE
    	LET wfecha_hoy = vfecha_hoy;
      END IF

      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN vcodret,wcod_ret, P_MENSAJE;
      END IF

 /** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS NECESARIOS PARA EL PASE CONTABLE */

      CREATE TEMP TABLE tdetpol
         ( usuario               CHAR(11)  NOT NULL ,
          control_poliza        SMALLINT NOT NULL ,
          fecha_captura         DATE     NOT NULL ,
          secuencia             INTEGER  NOT NULL ,
          empresa               CHAR(3),
          ccmayor               CHAR(4),
          ccsub                 CHAR(3),
          ccsubsub              CHAR(3),
          ccssubsub             CHAR(3),
          ccsssubsub            CHAR(3),
          sector                CHAR(3),
          ciudad                CHAR(3),
          sucursal              CHAR(4),
          nro_auxiliar          CHAR(9),
          naturaleza            CHAR(1),
          monto                 MONEY(19,2),
          descripcion_det       CHAR(30),
          fecha_valida          DATE,
          moneda                CHAR(2),
          valor_cambio          MONEY(12,7),
          valor_div_cambio      MONEY(12,7),
          mca_aplic             CHAR(1),
          poliza_usuario        CHAR(11),
          tipo_mov              CHAR(1),
          ccosto_orig           CHAR(4)) with no log;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wdivisa_cambio
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param  = "17";

      SELECT tipo_cpa_mn_div
        INTO valor_cambio
        FROM bdinteg:si_tpcambio
       WHERE empresa = pempresa
         AND divisa = wdivisa_cambio
         AND fecha_tpcambio = wfecha_hoy
         AND clase_tpcambio = "O";

      LET wusuario = pusuariopase;   --"credito";
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM bdicred:sd_movhis a, bdicred:sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = vfecha_hoy
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      ELSE
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM bdicred:sd_movhis a, bdicred:sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito   AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) NOT IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = vfecha_hoy        AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      END IF

      FOREACH
         SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wsucorigen, wabreviatura, wsecuencia, wvaloriza,
	            wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector, wmonto
           FROM x a, bdicred:sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun     AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa         AND c.numero = b.transacc
            AND c.sistema = "06"              AND d.empresa = b.empresa
            AND d.producto = a.num_producto   AND d.sistema = c.sistema
            AND d.transaccion = b.transacc    AND d.secuencia > 0
          ORDER BY 1,2,3,4,5,6

            LET wdescripcion_det = wabreviatura;

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;


   LET wcmayor = trim(wcmayor);
   IF wcmayor[1,2] = "95" THEN

           INSERT INTO tdetpol
                VALUES (wusuario, 0, wfecha_hoy, dsecuencia, "001",
                        wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                        wregional, wsucursal, wnro_auxiliar, "D", wmonto, wdescripcion_det,
                        wfecha_hoy, wdivisa, 0, 0, " ", wusuario, " ", wsucursal);
   ELSE

           INSERT INTO tdetpol
                VALUES (wusuario, 0, wfecha_hoy, dsecuencia, "001",
                        wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                        wregional, wsucursal, wnro_auxiliar, "D", wmonto, wdescripcion_det,
                        wfecha_hoy, wdivisa, 0, 0, " ", wusuario, " ", wsucorigen);

   END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

  LET wamayor = trim(wamayor);
  IF wamayor[1,2] = "95" THEN

            INSERT INTO tdetpol
                 VALUES (wusuario, 0, wfecha_hoy, dsecuencia, "001",
                         wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                         wregional, wsucursal, wnro_auxiliar, "C", wmonto, wdescripcion_det,
                         wfecha_hoy, wdivisa, 0, 0, " ", wusuario, " ", wsucursal);
   ELSE
            INSERT INTO tdetpol
                 VALUES (wusuario, 0, wfecha_hoy, dsecuencia, "001",
                         wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                         wregional, wsucursal, wnro_auxiliar, "C", wmonto, wdescripcion_det,
                         wfecha_hoy, wdivisa, 0, 0, " ", wusuario, " ", wsucorigen);
   END IF;

      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      
      FOREACH with hold
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM tdetpol
         GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY 11, 12, 5, 6, 7, 8, 9, 10

        IF icontador = 1 THEN
			BEGIN WORK;
        END IF;

        IF (detmoneda = "00") THEN
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
        ELSE
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
        END IF;

        IF detnaturaleza = 'D' THEN

            INSERT INTO bdicred:sd_contab_prep
                 VALUES (detusuario, detfecha_captura, '', detsecuencia, detempresa,
                         detmayor, detsub1, detsub2, detsub3, detsub4, detsector,
                         detsucursal, detnro_auxiliar, 'D', detmoneda, dccosto_orig,
                         '','', detmonto, 0, detdescripcion_det, '','','');
        ELSE

            INSERT INTO bdicred:sd_contab_prep
                 VALUES (detusuario, detfecha_captura, '', detsecuencia, detempresa,
                         detmayor, detsub1, detsub2, detsub3, detsub4, detsector,
                         detsucursal, detnro_auxiliar, 'C', detmoneda, dccosto_orig,
                         '','', 0, detmonto, detdescripcion_det, '','','');

        END IF;

        IF icontador>=3000 then
            COMMIT WORK;
            LET icontador=1;
        ELSE
            LET icontador=icontador+1;
        END IF;

      END FOREACH;

	  IF icontador > 1 THEN
		COMMIT WORK;
	  END IF;

      DROP TABLE tdetpol;
      DROP TABLE x;

   RETURN vcodret,wcod_ret, P_MENSAJE;

  END
END PROCEDURE;