CREATE PROCEDURE "informix".pasecontx(pempresa   CHAR(3),
                          fecha_pase DATE,
                          pusuario   CHAR(8))
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
   DEFINE detsecuencia                  SMALLINT;
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





   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET detusuario = 'credito';

   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = "PaseCont";

      SELECT
         fecha_hoy
      INTO
         wfecha_hoy
      FROM
         sd_fechas
      WHERE
         empresa = pempresa;

      LET wfecha_hoy = fecha_pase;

      SELECT
         proceso
      INTO
         wproceso
      FROM
         sd_contproc
      WHERE
         empresa = pempresa
      AND
         proceso = wproceso
      AND
         fecha = fecha_pase;

      --borra lo existente en la base de contabilidad
      delete from bdicont:co_poldet
      where empresa = pempresa
      and fecha_captura = fecha_pase
      and usuario = 'credito';

      delete from bdicont:co_detpol
      where empresa = pempresa
      and fecha_captura = fecha_pase
      and usuario = 'credito';

      delete from bdicont:co_poliza
      where empresa = pempresa
      and fecha_captura = fecha_pase
      and usuario = 'credito';

      SELECT
         ejecutivo
      INTO
         wejecutivo
      FROM
         bdinteg:si_ejecut
      WHERE
         empresa = pempresa
      AND
         ejecutivo = pusuario;

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

        LET wproceso = "PaseCont";

        INSERT INTO
           sd_contproc
        VALUES
           (pempresa,
            wproceso,
            fecha_pase,
            "I",
            USER,
            CURRENT,
            CURRENT,
            "  ",
            "Proceso Iniciado");
      else
        update sd_contproc
        set ejecutivo = user
           ,hora_inicio = current
           ,hora_fin = current
           ,status_proc = 'I'
           ,mensaje = 'PROCESO INICIADO'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   fecha = fecha_pase;
      end if;

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

      CREATE TEMP TABLE tdetpol
         (
          usuario               CHAR(11)  NOT NULL ,
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
          tipo_mov              CHAR(1)
         ) ;

      SET ISOLATION TO DIRTY READ;

      SELECT
         valor
      INTO
         wbanco
      FROM
         bdinteg:si_param
      WHERE
         empresa = pempresa
      AND
         cod_param = "5";

      SELECT
         valor
      INTO
         wdivisa_cambio
      FROM
         bdinteg:si_param
      WHERE
         empresa = pempresa
      AND
         cod_param  = "17";

      SELECT
         tipo_cpa_mn_div
      INTO
         valor_cambio
      FROM
         bdinteg:si_tpcambio
      WHERE
         empresa = pempresa
      AND
         divisa = wdivisa_cambio
      AND
         fecha_tpcambio = wfecha_hoy
      AND
         clase_tpcambio = "O";

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
         SELECT
            tipo_cpa_mn_div
         INTO
            valor_cambio
         FROM
            bdinteg:si_histdiv
         WHERE
            empresa = pempresa
         AND
            divisa = wdivisa_cambio
         AND
            fecha_tc = wfecha_hoy
         AND
            clase_tpcambio = "O";
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

      LET wusuario = "credito";
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      SELECT
         MAX(control_poliza)
      INTO
         wnumpolmn
      FROM
         bdicont:co_detpol
      WHERE
         usuario = wusuario
      AND
         fecha_captura = wfecha_hoy
      AND
         moneda = "00"
      AND
         empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;

      SELECT
         a.regional,
         b.secuencia,
         b.sucursal,
         b.num_producto,
         b.codigo_fun,
         b.codigo_ref,
         b.num_credito,
         0 num_cuota,
         d.numcte,
         e.apell_paterno,
         e.apell_materno,
         e.nombre1,
         e.nombre2,
         e.razon_social,
         e.sector,
         c.transacc,
         f.abreviatura,
         b.divisa,
         monto monto
      FROM
         bdinteg:si_plazas a,
                 sd_movdia b,
                 sd_transfun c,
                 sd_maecred d,
         bdinteg:si_cliente e,
         bdinteg:si_transacc f
      WHERE
         a.empresa = pempresa
      AND
         b.empresa = pempresa
      AND
         c.empresa = pempresa
      AND
         d.empresa = pempresa
      AND
        e.empresa = pempresa
      AND
        f.empresa = pempresa
	  AND 
		f.sistema ="06"
      AND
        fecha_mov = fecha_pase
      AND
        monto > 0
      AND
        b.plaza = a.plaza
      AND
        c.codigo_fun = b.codigo_fun
      AND
        c.codigo_ref = b.codigo_ref
      AND
        d.num_credito = b.num_credito
      AND
        e.numcte = d.numcte
      AND
        f.numero = c.transacc
      AND
        b.reversado <> "S"
      INTO TEMP x WITH NO LOG;


      FOREACH
         SELECT
            a.regional,
            a.sucursal,
            a.divisa,
            a.codigo_fun,
            a.codigo_ref,
            a.num_cuota,
            a.apell_paterno,
            a.apell_materno,
            a.nombre1,
            a.nombre2,
            a.razon_social,
            a.abreviatura,
            b.transaccion,
            b.secuencia,
            c.valoriza,
            b.c_ccmayor,
            b.c_ccsub,
            b.c_ccsubsub,
            b.c_ccsssub,
            b.c_ccssssub,
            a.sector,
            b.a_ccmayor,
            b.a_ccsub,
            b.a_ccsubsub,
            b.a_ccsssub,
            b.a_ccssssub,
            a.sector,
            a.monto
         INTO
            wregional,
            wsucursal,
            wdivisa,
            wcodigo_fun,
            wcodigo_ref,
            wnum_cuota,
            wapell_paterno,
            wapell_materno,
            wnombre1,
            wnombre2,
            wrazon_social,
            wabreviatura,
            wtransacc,
            wsecuencia,
            wvaloriza,
            wcmayor,
            wcsub1,
            wcsub2,
            wcsub3,
            wcsub4,
            wcsector,
            wamayor,
            wasub1,
            wasub2,
            wasub3,
            wasub4,
            wasector,
            wmonto

         FROM
                  x a,
            bdinteg:si_prodtran b,
            bdinteg:si_transacc c
         WHERE
            b.empresa = pempresa
         AND
            b.sistema = "06"
         AND
            b.producto = a.num_producto
         AND
            b.transaccion = a.transacc
         AND
            c.empresa = pempresa
         AND
            c.numero      = a.transacc
		 AND 
			c.sistema ="06"
         AND
            c.se_contabiliza = 'S'
         ORDER BY
            1,2,3,4,5,6,7,8

            IF (wrazon_social IS NULL OR
                wrazon_social = " ") THEN
               LET wdescripcion_det = wapell_paterno[1,5] ||
                                      " "|| wapell_materno[1,1]  ||
                                      " "|| wnombre1[1,5]  ||
                                      " "|| wabreviatura[1,15];
            ELSE
               LET wdescripcion_det = wrazon_social[1,15] ||
                                      " "|| wabreviatura[1,15];
            END IF;

            SELECT
               sectoriza_cta
            INTO
               wsectoriza
            FROM
               bdinteg:si_catalog
            WHERE
               empresa = pempresa
            AND
               ccmayor = wcmayor
            AND
               ccsub   = wcsub1
            AND
               ccsubsub = wcsub2
            AND
               ccssubsub = wcsub3
            AND
               ccsssubsub = wcsub4
            AND
               sector     = "00";

            IF (wsectoriza = "N") THEN
               LET wcsector = "00";
            END IF;
            SELECT
               sectoriza_cta
            INTO
               wsectoriza
            FROM
               bdinteg:si_catalog
            WHERE
               empresa = pempresa
            AND
               ccmayor = wamayor
            AND
               ccsub   = wasub1
            AND
               ccsubsub = wasub2
            AND
               ccssubsub = wasub3
            AND
               ccsssubsub = wasub4
            AND
               sector     = "00";

            IF (wsectoriza = "N") THEN
               LET wasector = "00";
            END IF;

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
                " "
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
                " "
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
         SELECT
            usuario,
            control_poliza,
            fecha_captura ,
            empresa,
            ccmayor,
            ccsub,
            ccsubsub,
            ccssubsub,
            ccsssubsub,
            sector,
            ciudad,
            sucursal,
            nro_auxiliar,
            naturaleza,
            sum(monto),
            descripcion_det,
            fecha_valida,
            moneda
         INTO
            detusuario,
            detcontrol_poliza,
            detfecha_captura,
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
            detmoneda
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18
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
            detmoneda);

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
   EXECUTE PROCEDURE BDICONT:SP_AUDITAPASE(FECHA_PASE,PEMPRESA,detusuario)
           INTO WCOD_RET, P_MENSAJE;

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
   ELSE
      UPDATE sd_contproc
      SET status_proc = "C",
          mensaje = 'ERROR: ' || P_MENSAJE,
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
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

CREATE PROCEDURE "informix".udetallelayout_edocuenta(
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)
RETURNING CHAR(5);


--DECLARACION DE VARIABLES:


DEFINE v_id_registro   		char(3);
DEFINE v_marca         		char(3);
DEFINE cod_ret             	char(5);
DEFINE sql_err             	integer;

DEFINE v_dia           		char(2);
DEFINE v_mes           		char(2);
DEFINE v_ano	       		char(4);
DEFINE v_fecha_emi     		date;
DEFINE v_referencia    		char(296);
DEFINE v_referencia23  		char(279);
DEFINE v_rfc_comer     		char(276);
DEFINE v_transacc      		char(4);
DEFINE v_monto         		decimal(18,2);
DEFINE v_num_credito   		char(20);

DEFINE v_concepto      		varchar(255);
DEFINE v_naturaleza    		char(1);
DEFINE v_secuencia     		integer;
DEFINE v_letra         		char(15);
DEFINE v_fecha_mov     		char(12);

DEFINE v_compra	       		decimal(18,2);
DEFINE v_abono	       		decimal(18,2);
DEFINE v_usted_debe_ant     decimal(18,2);
DEFINE v_usted_debe     	decimal(18,2);

DEFINE v_maximo        		char(10);
DEFINE v_fecha_corte   		char(12);
DEFINE v_contador      		smallint;



--SE INICIALIZAN VARIABLES:

LET v_id_registro  = "";
LET v_marca        = "";

LET v_dia          = "";
LET v_mes          = "";
LET v_ano	   	   = "";
LET v_referencia   = "";
LET v_referencia23 = "";
LET v_rfc_comer    = "";
LET v_transacc     = "";
LET v_monto     = 0;
LET v_num_credito  = "";

LET v_concepto     = "";
LET v_naturaleza   = "";
LET v_letra        = "";
LET v_fecha_mov    = "";

LET v_compra    = "";
LET v_abono     = "";
LET v_usted_debe_ant      = 0;
LET v_usted_debe      = 0;

LET v_maximo       = "";
LET v_fecha_corte  = "";
LET v_contador     = 0;

 --SET DEBUG FILE TO "detalleedocuenta.out";
 --TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    --------------------------------------------------------
    --	OBTIENE EL TOTAL REGISTROS DETALLE DE LA CUENTA
    --------------------------------------------------------
	SELECT NVL(MAX(secuencia), 0) + 1 as maximo
		INTO v_maximo
	FROM sd_detalle_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = v_num_credito ;

    --------------------------------------------------------
    --      GENERA USTED DEBIA
    --------------------------------------------------------

	SELECT usted_debia
		INTO v_usted_debe_ant
	FROM sd_encabezado2_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = pnum_credito;


	INSERT INTO sd_detalle_edocta
				(
				fecha_emision,num_credito,secuencia,
			    fecha_mov,concepto,cargos,nlinea
			    )
			VALUES(
				pfechahoy,pnum_credito,v_maximo,
			    "","USTED DEBIA",NVL(v_usted_debe_ant,0),1
			    );

    --------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	FOREACH SELECT 	DAY(a.fecha_mov),MONTH(a.fecha_mov),YEAR(a.fecha_mov),
				a.fecha_mov,a.referencia,a.referencia23,
				a.rfc_comer,a.transacc_suc,a.monto,
				a.num_credito,TRIM(c.descripcion),b.naturaleza,
				a.secuencia,
                DECODE( MONTH(a.fecha_mov),
                		"1","ENE","2","FEB","3","MAR",
                		"4","ABR","5","MAY","6","JUN",
                		"7","JUL","8","AGO","9","SEP",
                		"10","OCT","11","NOV","12","DIC")
		 		INTO    v_dia,v_mes,v_ano,
		 				v_fecha_emi,v_referencia,v_referencia23,
						v_rfc_comer,v_transacc,v_monto,
						v_num_credito,v_concepto,v_naturaleza,
						v_secuencia,v_letra
			FROM sd_movhisedocta  a
			INNER JOIN sd_transfun c
				ON a.codigo_fun = c.codigo_fun
				AND a.codigo_ref = c.codigo_ref
				AND  a.empresa = c.empresa
			INNER JOIN  bdinteg:si_transacc b
				ON c.empresa = b.empresa
				AND c.transacc = b.numero
				and b.sistema = "06"
			WHERE  a.empresa = pempresa
				AND a.num_credito = pnum_credito
				AND a.fecha_mov > pfechahoy - 1 UNITS MONTH
				AND a.fecha_mov <= pfechahoy
				AND a.reversado <> "S"
				AND b.se_emite_edocta = "S"
			ORDER BY a.fecha_mov,a.secuencia


			IF v_monto = 0 THEN
				CONTINUE FOREACH;
			END IF
		    --------------------------------------------------------
		    --      GENERO LA DESCRIPCION DEL MOVIMIENTO
		    --------------------------------------------------------
			IF v_referencia IS NULL THEN
				LET v_concepto = NVL(TRIM(v_concepto),'');
			ELSE
				IF v_referencia[1,8] = "intercar" THEN
				   LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 16))
				   					|| "  " ||
				   					NVL(TRIM(v_referencia23),'')
				   					|| "  " ||
				   					NVL(TRIM(v_rfc_comer),'');
				   IF v_concepto[1,8] = "intercar" THEN
						LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 16));
				   END IF
				ELSE
					LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,16]);
				END IF
			END IF
		    --------------------------------------------------------
		    --ARMO LA FEC MOVIMIENTO CON LETRA
		    --------------------------------------------------------
			IF v_mes IS NOT NULL THEN
		     	LET v_fecha_mov = Trim(v_dia)  || "-" ||
		     					  Trim(v_letra)|| "-" ||
		     					  v_ano[3]||v_ano[4];
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		    --------------------------------------------------------
			IF v_naturaleza IS NOT NULL THEN
				IF v_naturaleza = "A" THEN
					LET v_abono  = v_monto;
				ELSE
					LET v_compra = v_monto;
				END IF;
			ELSE
				LET v_compra = v_monto;
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		    --------------------------------------------------------
			LET v_maximo = v_maximo + 1 ;
			LET v_contador = 0;
		    --------------------------------------------------------
		    --DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		    --------------------------------------------------------
				FOREACH EXECUTE PROCEDURE corta_linea(v_concepto) INTO v_concepto

					LET v_contador = v_contador + 1;
					IF v_contador = 1 THEN
						 INSERT INTO sd_detalle_edocta
						 	(
						 	fecha_emision,num_credito,secuencia,
							fecha_mov,concepto,cargos,
							abonos,nlinea
							)
						VALUES
							(
							pfechahoy,v_num_credito,v_maximo,
							v_fecha_mov,Trim(v_concepto),v_compra,
							v_abono,v_contador
							);
					ELSE
						INSERT INTO sd_detalle_edocta
							(
							fecha_emision,num_credito,secuencia,
							concepto,nlinea
							)
						VALUES(
							pfechahoy,v_num_credito,v_maximo,
							Trim(v_concepto),v_contador
							);
					END IF;

				END FOREACH;
		    --------------------------------------------------------
		    --INICIALIZA LAS VARIABLES
		    --------------------------------------------------------
			LET v_num_credito  = "";
			LET v_fecha_mov    = "";
			LET v_concepto     = "";
			LET v_compra       = "";
			LET v_abono        = "";

	END FOREACH;

    --------------------------------------------------------
    --      GENERA USTED DEBE
    --------------------------------------------------------
	SELECT usted_debe
		INTO v_usted_debe
	FROM sd_encabezado2_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = pnum_credito;

	INSERT INTO sd_detalle_edocta
			(
			fecha_emision,num_credito,secuencia,
			fecha_mov,concepto,cargos,nlinea
			)
			VALUES
			(
			pfechahoy,pnum_credito,v_maximo + 1,
			"","USTED DEBE",NVL(v_usted_debe,0),1
			);


  END;
  RETURN cod_ret;

END PROCEDURE ;