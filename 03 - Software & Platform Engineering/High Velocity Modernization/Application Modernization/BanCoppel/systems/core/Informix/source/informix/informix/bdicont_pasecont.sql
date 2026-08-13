CREATE PROCEDURE "informix".pasecont(pempresa     CHAR(3),
                                     fecha_pase   DATE,
                                     pusuario     CHAR(8),
                                     pusuariopase CHAR(8),
                                     pproceso     CHAR(10))
   RETURNING CHAR(5), varchar(80);

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
   DEFINE nrows                         SMALLINT;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(30);
   DEFINE wnumpolmn                     SMALLINT;
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wnum_cuota                    SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(20);
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
{****************************************************************************
 **      TERMINA REGISTRO DE PASE CONTABLE                                 **
 **      INICIA REGISTRO DETPOL                                            **
 ****************************************************************************}

   DEFINE detusuario                    CHAR(11);
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
   DEFINE detvalor_cambio               MONEY(12,7);
   DEFINE detvalor_div_cambio           MONEY(12,7);
   DEFINE detmca_aplica                 CHAR(1);
   DEFINE detpoliza_usuario             CHAR(11);
   DEFINE dettipo_mov                   CHAR(1);
   
{***************************************************************************
 **   TERMINA REGISTRO DE DETPOL                                          **
 **   INICIA REGISTRO DE ENCABEZADO DE POLIZA                             **
 ***************************************************************************}

   DEFINE polcifra_control              MONEY(14,2);
   DEFINE polcargo                      MONEY(14,2);
   DEFINE polabono                      MONEY(14,2);
{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE dsecuencia                    INTEGER;
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET wcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN wcod_ret, P_MENSAJE;
   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--   SET DEBUG FILE TO "pasecont.out";
--   TRACE ON;


   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = ""; --NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   --LET detusuario = 'credito';
   LET detusuario = pusuariopase;


   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = pproceso;  -- "PaseCont";
 
	let fecha_pase = fecha_pase;	

      IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
      ELSE
	LET wfecha_hoy = fecha_pase;
      END IF
      

      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF
      
      

--      SELECT proceso
--        INTO wproceso
--        FROM sd_contproc
--       WHERE empresa = pempresa
--         AND proceso = wproceso
--         AND fecha = fecha_pase;

      SELECT proceso
        INTO wproceso
        FROM bdinteg:sx_contproc
       WHERE empresa = pempresa
         AND proceso = wproceso
         AND sistema = "06"
         AND fecha = fecha_pase;




      --borra lo existente en la base de contabilidad
      delete from bdicont:co_poldet
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_detpol
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_poliza
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      SELECT ejecutivo
        INTO wejecutivo
        FROM bdinteg:si_ejecut
       WHERE empresa = pempresa
         AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET wcod_ret = "090";
         LET P_MENSAJE = 'Usuario no Valido para ejecutar el proceso';
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN wcod_ret, P_MENSAJE;
      END IF;

      if wproceso is NULL then

        LET wproceso = pproceso;   --"PaseCont";

        INSERT INTO sd_contproc
        VALUES (pempresa, wproceso, fecha_pase, "I", USER,
                CURRENT, CURRENT, "  ", "Proceso Iniciado");
                
        INSERT INTO bdinteg:sx_contproc 
	   (empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,
	    hora_fin,codret)
        VALUES 
	   (pempresa, wproceso, fecha_pase, "06","I", USER,CURRENT, 
	    CURRENT, "  ");
                
      else
        UPDATE sd_contproc
               set ejecutivo = user
                  ,hora_inicio = current
                  ,hora_fin = current
                  ,status_proc = 'I'
                  ,mensaje = 'PROCESO INICIADO'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   fecha = fecha_pase;
        
        UPDATE bdinteg:sx_contproc
               set ejecutivo = user
                  ,hora_ini = current
                  ,hora_fin = current
                  ,status_proc = 'I'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   sistema = "06"
        AND   fecha = fecha_pase;

      end if;

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

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
          ccosto_orig           CHAR(4)) ;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wbanco
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param = "5";

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

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
      {   SELECT tipo_cpa_mn_div
           INTO valor_cambio
           FROM bdinteg:si_histdiv
          WHERE empresa = pempresa
            AND divisa = wdivisa_cambio
            AND fecha_tc = wfecha_hoy
            AND clase_tpcambio = "O";}

         LET nrows = dbinfo("sqlca.sqlerrd2");
--         IF (nrows = 0) THEN
--            LET wcod_ret ="017";
--            IF (wbegin = "S") THEN
--               ROLLBACK WORK;
--               BEGIN WORK;
--            ELSE
--               ROLLBACK WORK;
--            END IF;
--            RETURN wcod_ret, P_MENSAJE;
--         END IF;
      END IF;

      LET wusuario = pusuariopase;   --"credito";  
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      SELECT MAX(control_poliza)
        INTO wnumpolmn
        FROM bdicont:co_detpol
       WHERE usuario = wusuario
         AND fecha_captura = wfecha_hoy
         AND moneda = "00"
         AND empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;
      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
         SELECT a.regional,
	        b.secuencia, b.suc_origen, b.num_producto, b.codigo_fun,
                b.codigo_ref, b.num_credito, 0 num_cuota,
                d.numcte, 
                e.apell_paterno, e.apell_materno, e.nombre1, e.nombre2,
                e.razon_social, e.sector,
                c.transacc, f.descripcion abreviatura, b.divisa, monto monto,
	        b.sucursal
           FROM bdinteg:si_plazas a, sd_movhis b, sd_transfun c,
                sd_maecred d, bdinteg:si_cliente e, bdinteg:si_transacc f
          WHERE b.empresa = pempresa
            AND b.plaza = a.plaza
            AND b.reversado <> "S"
  	    AND TRIM(b.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND fecha_mov = fecha_pase
            AND monto > 0
            AND c.codigo_fun = b.codigo_fun
            AND c.codigo_ref = b.codigo_ref
            AND c.empresa = pempresa
            AND d.num_credito = b.num_credito
            AND d.empresa = pempresa
            AND e.numcte = d.numcte
            AND f.sistema = "06"
            AND f.empresa = pempresa
            AND f.numero = c.transacc
            AND f.se_contabiliza <> "N"
            AND a.empresa = pempresa
           INTO TEMP x WITH NO LOG;
      ELSE
         SELECT a.regional,
                b.secuencia, b.suc_origen, b.num_producto, b.codigo_fun,
                b.codigo_ref, b.num_credito, 0 num_cuota,
                d.numcte,
                e.apell_paterno, e.apell_materno, e.nombre1, e.nombre2,
                e.razon_social, e.sector,
                c.transacc, f.descripcion abreviatura, b.divisa, monto monto,
                b.sucursal
           FROM bdinteg:si_plazas a, sd_movhis b, sd_transfun c,
                sd_maecred d, bdinteg:si_cliente e, bdinteg:si_transacc f
          WHERE b.empresa = pempresa
            AND b.plaza = a.plaza
            AND b.reversado <> "S"
            AND TRIM(b.folio_suc) NOT IN ("CalifCartReserva", "CalifCart")
            AND fecha_mov = fecha_pase
            AND monto > 0
            AND c.codigo_fun = b.codigo_fun
            AND c.codigo_ref = b.codigo_ref
            AND c.empresa = pempresa
            AND d.num_credito = b.num_credito
            AND d.empresa = pempresa
            AND e.numcte = d.numcte
            AND f.sistema = "06"
            AND f.empresa = pempresa
            AND f.numero = c.transacc
            AND f.se_contabiliza <> "N"
            AND a.empresa = pempresa
           INTO TEMP x WITH NO LOG;
      END IF


      FOREACH
         SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun,
                a.codigo_ref, a.num_cuota, a.apell_paterno,
                a.apell_materno, a.nombre1, a.nombre2, a.razon_social,
                a.abreviatura, b.transaccion, b.secuencia, c.valoriza,
                b.c_ccmayor, b.c_ccsub, b.c_ccsubsub, b.c_ccsssub,
                b.c_ccssssub, b.c_sector, 
	        b.a_ccmayor, b.a_ccsub, b.a_ccsubsub, b.a_ccsssub, 
	        b.a_ccssssub, b.a_sector,
                a.monto, a.suc_origen
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wnum_cuota, wapell_paterno, wapell_materno,
                wnombre1, wnombre2, wrazon_social, wabreviatura,
                wtransacc, wsecuencia, wvaloriza,
	        wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                wmonto, wsucorigen
           FROM x a, bdinteg:si_prodtran b, bdinteg:si_transacc c
          WHERE b.empresa = pempresa
            AND b.sistema = "06"
            AND b.producto = a.num_producto
            AND b.transaccion = a.transacc
            AND c.empresa = pempresa
            AND c.numero = a.transacc
          ORDER BY 1,2,3,4,5,6,7,8

            {IF (wrazon_social IS NULL OR
                wrazon_social = " ") THEN
               LET wdescripcion_det = wapell_paterno[1,5] ||
                                      " "|| wapell_materno[1,1]  ||
                                      " "|| wnombre1[1,5]  ||
                                      " "|| wabreviatura[1,15];
            ELSE
               LET wdescripcion_det = wrazon_social[1,15] ||
                                      " "|| wabreviatura[1,15];
            END IF;}
            LET wdescripcion_det = wabreviatura;

            {SELECT sectoriza_cta
              INTO wsectoriza
              FROM bdinteg:si_catalog
             WHERE empresa = pempresa
               AND ccmayor = wcmayor
               AND ccsub   = wcsub1
               AND ccsubsub = wcsub2
               AND ccssubsub = wcsub3
               AND ccsssubsub = wcsub4
               AND sector     = wcsector;

            IF (wsectoriza = "N") THEN
               LET wcsector = "00";
            END IF;
            SELECT sectoriza_cta
              INTO wsectoriza
              FROM bdinteg:si_catalog
             WHERE empresa = pempresa
               AND ccmayor = wamayor
               AND ccsub   = wasub1
               AND ccsubsub = wasub2
               AND ccssubsub = wasub3
               AND ccsssubsub = wasub4
               AND sector     = wasector;

            IF (wsectoriza = "N") THEN
               LET wasector = "00";
            END IF;}

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

{
            IF (wcodigo_fun = "039") THEN
               IF (wcodigo_ref = 1) then
                  LET wcsub1 = wnum_cuota;
               ELSE
                  LET wasub1 = wnum_cuota;
               END IF;
            END IF;
}
           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
		wsucorigen
               );

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;
{
            IF (wcodigo_fun = "039") THEN
               LET wcsub1 = wcodigo_ref;
            END IF;
}
            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
		wsucorigen
               );
      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      LET detvalor_cambio = 0;
      LET detvalor_div_cambio = 0;
      LET detmca_aplica = " ";
      LET dettipo_mov = " ";


      FOREACH
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY
            11, 12, 5, 6, 7, 8, 9, 10

         IF (detmoneda = "00") THEN
            LET detcontrol_poliza = wnumpolmn;
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
         ELSE
            LET detcontrol_poliza = wnumpoldl;
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
         END IF;

         LET detpoliza_usuario = detusuario;
         INSERT INTO
            bdicont:co_poldet
         VALUES
           (detusuario,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detmayor,
            detsub1,
            detsub2,
            detsub3,
            detsub4,
            detsector,
            detciudad,
            detsucursal,
            detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
	    dccosto_orig);

      END FOREACH;

      DROP TABLE tdetpol;
      DROP TABLE x;

   IF (wbegin = "S") THEN
      COMMIT WORK;
      BEGIN WORK;
   ELSE
      COMMIT WORK;
   END IF;

   --EJECUTA EL PROCESO DE AUDITOR
   EXECUTE PROCEDURE BDICONT:AUDITAPASE(FECHA_PASE,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

   IF v_error = 0 then
      UPDATE sd_contproc
      SET status_proc = "F",
          mensaje = 'PROCESO EXITOSO',
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "F",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   ELSE
      UPDATE sd_contproc
      SET status_proc = "C",
          mensaje = 'ERROR: ' || P_MENSAJE,
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "C",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   END IF;
   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE

DOCUMENT
"Programa de Pase contable, lee de sd_movdia y graba en bdicont:co_poliza",
"y en bdicont:co_detpol",
"Autor : Raul Mendoza D'nes",
"Fecha : 17/Julio/2001",
"Ver.  : 1.0",
"Mod.  : 31/julio/2001 Para colocar el control de semestres RMD",
"B.D   : bdicred",
"Mod.  : Se Modifico Por Que En Detpol El Usuario Era de 8 Posiciones",
"Mod.  : Sergio Ruiz",
"Mod.  : 07/Noviembre/2001  Raul Mendoza D'nes",
"      : Se modifoca para que no se agrupen los montos por cuenta",
"      : ya que GE capital necesita el registro por movimiento",
"      : y se coloca en la descripcion del movimiento el nombre",
"      : del cliente abreviado junto con la descripcion de la ",
"      : transaccion abreviada en el siguiente formato 14 caracteres",
"      : para el nombre con 6 para apell paterno, espacio, 1 para",
"      : apell materno espacio 6 para nombre, una diagonal y 14 para",
"      : la descripcion de la transaccion abreviada",
"Mod   : RAUL MENDOZA",
"      : 3/Dic/2001",
"      : Se pasa como parametro el usuario que genera el pase contable";

create procedure "informix".pasecont(pfecha_hoy date)
returning char(3);

-- ***************************************************************************
-- SPL revisado     MCT 01-05-98
-- ***************************************************************************
define cod_ret char(3);
define vw_cargo_abono, vw_mca_aplic char(1);
define vw_ccmayor,vw_ccsub,vw_ccsubsub char(10);
define vw_ccssubsub,vw_ccsssubsub,vw_sector char(10);
define vw_moneda, moneda_ant char(2);
define vw_ciudad char(3); 
define vw_sucursal, vw_suc_usuario char(4); 
define v_empresa, empresa_ant char(3);
define vw_usuario char(8);
define vw_usuar char(8);
define vw_auxiliar char(12);
define vw_descripcion char(50);
define vw_monto, vw_valor_cambio, vw_valor_div, vw_capt_cargo, vw_capt_abono,
       vw_cifra_control money(14,2);
define v_valor money(14,7);
define vw_control_poliza, vw_secuencia smallint;
define vw_fecha_hoy date;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
let cod_ret         = "000";
let vw_secuencia    = 0;
let vw_auxiliar     = "0";
let vw_descripcion  = "Saldos Iniciales";
let vw_valor_cambio = 0;
let vw_valor_div    = 0;
let vw_mca_aplic    = "0";
let moneda_ant      = "01";
let empresa_ant     = "001";



-- ***************************************************************************
-- Extrae el usuario a asignar en el Pase Contable
-- ***************************************************************************
select ejecutivo, sucursal into vw_usuario, vw_suc_usuario
from bdinteg:si_ejecut
where ejecutivo = USER;
if vw_usuario is null or vw_suc_usuario is null then
   let cod_ret = "158";
   return cod_ret;
end if

-- ***************************************************************************
-- Asigna la fecha de hoy dada como parametro
-- ***************************************************************************
let vw_fecha_hoy = pfecha_hoy;

-- ***************************************************************************
-- Extrae el ultimo numero de Control de Poliza por el usuario
-- ***************************************************************************
select max(control_poliza) into vw_control_poliza
from bdicont:co_poliza
where usuario = vw_usuario;
if vw_control_poliza is null then
   let vw_control_poliza = 1;
else
   let vw_control_poliza = vw_control_poliza + 1;
end if

-- ***************************************************************************
-- Cada registro de la Tabla Contable de Cheques lo graba en Detalle de Poliza
-- ***************************************************************************
Foreach
   select sucursal, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,
	  cargo_abono, monto, moneda, empresa,suc_cta
	  into vw_sucursal, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
	  vw_ccsssubsub, vw_sector, vw_cargo_abono, vw_monto, vw_moneda,
          v_empresa,vw_ciudad
   from co_contab
   where monto != 0
   order by empresa, moneda, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector

   let vw_secuencia = vw_secuencia + 1;


   if moneda_ant <> vw_moneda or empresa_ant <> v_empresa then
      -- Extrae el monto capturado al cargo por la poliza
      select sum(monto) into vw_capt_cargo from bdicont:co_detpol
      where usuario = vw_usuario and control_poliza = vw_control_poliza and
	    fecha_captura = vw_fecha_hoy and naturaleza = "D" and  -- Debito
            moneda = moneda_ant;
      if vw_capt_cargo is null then
	 let vw_capt_cargo = 0;
      end if

      -- Extrae el monto capturado al abono por la poliza
      select sum(monto) into vw_capt_abono from bdicont:co_detpol
      where usuario = vw_usuario and control_poliza = vw_control_poliza and
	    fecha_captura = vw_fecha_hoy and naturaleza = "C" and  -- Credito
            moneda = moneda_ant;
      if vw_capt_abono is null then
	 let vw_capt_abono = 0;
      end if

      if vw_capt_cargo = vw_capt_abono then
         let vw_cifra_control = vw_capt_cargo;
      else
         let vw_cifra_control = 0;
      end if
      -- Graba el encabezado de la poliza
      insert into bdicont:co_poliza
      values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_cifra_control,
	     vw_capt_cargo, vw_capt_abono, moneda_ant, vw_descripcion);
      -- inicializa control y secuencia de cada poliza
      let vw_secuencia = 0;
      let vw_control_poliza = vw_control_poliza + 1;
   end if

   insert into bdicont:co_detpol
   values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_secuencia,
	  v_empresa, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
          vw_ccsssubsub, vw_sector, vw_ciudad, vw_sucursal, vw_auxiliar,
          vw_cargo_abono, vw_monto, vw_descripcion, vw_fecha_hoy, vw_moneda,
          vw_valor_cambio, vw_valor_div, vw_mca_aplic);
   let moneda_ant  = vw_moneda;
   let empresa_ant = v_empresa;
end foreach;

-- Genera el encabezado de la ultima poliza
select sum(monto) into vw_capt_cargo from bdicont:co_detpol
where usuario = vw_usuario and control_poliza = vw_control_poliza and
      fecha_captura = vw_fecha_hoy and naturaleza = "D" and  -- Debito
      moneda = moneda_ant;
if vw_capt_cargo is null then
   let vw_capt_cargo = 0;
end if

-- Extrae el monto capturado al abono por la poliza
select sum(monto) into vw_capt_abono from bdicont:co_detpol
where usuario = vw_usuario and control_poliza = vw_control_poliza and
      fecha_captura = vw_fecha_hoy and naturaleza = "C" and  -- Credito
      moneda = moneda_ant;
if vw_capt_abono is null then
   let vw_capt_abono = 0;
end if

select nombre into vw_descripcion
from bdinteg:si_sucursales where sucursal = vw_suc_usuario;
let vw_descripcion = "Saldos Iniciales";
-- let vw_descripcion = "Saldos Iniciales"; REVIEW MCT ...

if vw_capt_cargo = vw_capt_abono then
   let vw_cifra_control = vw_capt_cargo;
else
   let vw_cifra_control = 0;
end if
-- Graba el encabezado de la poliza
insert into bdicont:co_poliza
values(vw_usuario, vw_control_poliza, vw_fecha_hoy, vw_cifra_control,
       vw_capt_cargo, vw_capt_abono, moneda_ant, vw_descripcion);
return cod_ret;
end procedure;