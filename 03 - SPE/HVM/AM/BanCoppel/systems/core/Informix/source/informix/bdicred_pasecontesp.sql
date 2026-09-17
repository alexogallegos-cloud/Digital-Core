CREATE PROCEDURE "informix".pasecontesp(pempresa     CHAR(3),
                                     fecha_pase   DATE,  -- Fecha Movimiento
                                     pusuario     CHAR(8), -- Informix
                                     pusuariopase CHAR(8), -- El de la Poliza
                                     pproceso     CHAR(10), -- "pase"
				     fecha_aplic  DATE) -- Fecha proceso conta
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
   DEFINE nrows                         integer;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(30);
   DEFINE wnumpolmn                     integer;
   DEFINE wnumpoldl                     integer;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);
   DEFINE vCred				CHAR(20);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   integer;
   DEFINE wnum_cuota                    integer;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(20);
   DEFINE wsecuencia                    integer;
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
   DEFINE detcontrol_poliza             integer;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  integer;
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
   DEFINE dcontrol_poliza               integer;
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

-- SET DEBUG FILE TO "pasecontrev.out";
-- TRACE ON;


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

--      IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
--      ELSE
	LET wfecha_hoy = fecha_aplic;
--      END IF
      

      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF
      
      

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

        LET wproceso = pproceso;   --"PaseCont";

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
      LET wdescripcion_det = "MOVTOS RETRO DE CREDITO DEL DIA ";
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
         SELECT a.regional,
                b.secuencia, b.suc_origen, b.num_producto, b.codigo_fun,
                b.codigo_ref, b.num_credito, 0 num_cuota,
                d.numcte, " " apell_paterno ," " apell_materno ,
	        " " nombre1," " nombre2," " razon_social, "32" sector,
                c.transacc, f.descripcion abreviatura, b.divisa, monto monto,
                b.sucursal
           FROM bdinteg:si_plazas a, sd_movcapprov b, sd_transfun c,
                bdinteg:si_transacc f, sd_maecred d
          WHERE b.empresa = pempresa
            AND b.plaza = a.plaza
            AND b.reversado <> "S"
        --    AND b.monto_dls in(2011,2011.10)
            AND fecha_mov = fecha_pase
            --AND monto > 0
            AND c.codigo_fun = b.codigo_fun
            AND c.codigo_ref = b.codigo_ref
            AND c.empresa = pempresa
            AND f.sistema = "06"
            AND f.empresa = pempresa
            AND f.numero = c.transacc
            AND f.se_contabiliza <> "N"
            AND a.empresa = pempresa 
	    AND d.num_credito = b.num_credito
	    AND d.empresa = b.empresa
           INTO TEMP x WITH NO LOG;


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
                fecha_pase,
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
                fecha_pase,
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
   EXECUTE PROCEDURE BDICONT:AUDITAPASE(wfecha_hoy,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE

DOCUMENT
"Programa de Pase contable, especial retroactivoa",
"Autor : Antonio Ruiz Mtz. ",
"Fecha : 27/Nov/2007",
"Ver.  : 1.0" ;

create procedure "informix".auditbancoppel(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vnum_credito    char(20);
define vsqlerr         Integer;
define vmonto_vencido  money(14,2);
define vsdo_cap        money(14,2);

define vSdoCapIns         money(14,2);
define vSdoCap            money(14,2);
define vMtoVevTrap        money(14,2);
define vCapTraspNoVenc    money(14,2);
define vMtoFinan          money(14,2);
define vSdoCapInsH        money(14,2);
define vSdoCapH           money(14,2);
define vMtoVencH          money(14,2);
define vMtoVevTrapH       money(14,2);
define vCapTraspNoVencH   money(14,2);
define vMtoFinanH         money(14,2);
define vDifMtoFinan       money(14,2);
define vDifMtoVenc        money(14,2);
define vFecVenci          date;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "audita.out";
  --trace on;



  let vnum_credito    = "";
  let vcodret         = "000";
  let vmonto_vencido  = 0;
  let vsdo_cap        = 0;
  let vFecVenci       ='';
  let vSdoCapIns       =0;
  let vSdoCap          =0;
  let vMtoVevTrap      =0;
  let vCapTraspNoVenc  =0;
  let vMtoFinan        =0;
  let vSdoCapInsH      =0;
  let vSdoCapH         =0;
  let vMtoVencH        =0;
  let vMtoVevTrapH     =0;
  let vCapTraspNoVencH =0;
  let vMtoFinanH       =0;
  let vDifMtoFinan     =0;
  let vDifMtoVenc      =0;

--Creditos Vigentes Cuadra saldos capitales y inicializa vencidos

foreach
  select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  sdo_capital != sdo_cap_insoluto
     and  a.status_cred = "AA"

   update sd_maesdos set sdo_capital = sdo_cap_insoluto,
       monto_vencido = 0,mto_venc_trasp = 0,cap_tras_no_venci = 0,
       sdo_moratorio = 0 where empresa = "001" and num_credito = vnum_credito;

end foreach

  FOREACH
       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapIns,vSdoCap,vmonto_vencido,vMtoVevTrap,vCapTraspNoVenc,vMtoFinan
       FROM sd_maesdos
       WHERE num_credito in (SELECT num_credito FROM sd_maecred WHERE status_cred='BA') and empresa = pempresa

       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapInsH,vSdoCapH,vMtoVencH,vMtoVevTrapH,vCapTraspNoVencH,vMtoFinanH
       FROM sd_maesdoshist
       WHERE fecha = '04/20/2008' and empresa = pempresa and num_credito = vnum_credito;

       IF vMtoFinan <= 0 THEN
             UPDATE sd_maesdos set sdo_capital      =  sdo_capital + vmonto_vencido,
                                   monto_vencido    = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
             CONTINUE FOREACH;
      END IF;

       let vDifMtoFinan  = vMtoFinanH -vMtoFinan ;
       IF vmonto_vencido > 0 THEN
          let vDifMtoVenc = vMtoVencH - vDifMtoFinan;
          IF vDifMtoVenc > 0 THEN
             let vSdoCap        = vSdoCap + (vmonto_vencido - vDifMtoVenc);
             let vmonto_vencido = vDifMtoVenc;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = vmonto_vencido
            WHERE num_credito = vnum_credito and empresa = pempresa;
          ELIF vDifMtoVenc <= 0 THEN
             let vSdoCap        = vSdoCap + vmonto_vencido;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
          END IF;
        ELSE
             let vSdoCap        = vSdoCap + vmonto_vencido;
             UPDATE sd_maesdos set sdo_capital = vSdoCap,
                                   monto_vencido = 0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
        END IF;
   END FOREACH

  FOREACH
       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapIns,vSdoCap,vmonto_vencido,vMtoVevTrap,vCapTraspNoVenc,vMtoFinan
       FROM sd_maesdos
       WHERE num_credito in (SELECT num_credito FROM sd_maecred WHERE status_cred='BT') and empresa = pempresa

       SELECT num_credito,sdo_cap_insoluto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,monto_financiado
       INTO vnum_credito,vSdoCapInsH,vSdoCapH,vMtoVencH,vMtoVevTrapH,vCapTraspNoVencH,vMtoFinanH
       FROM sd_maesdoshist
       WHERE fecha = '04/20/2008' and empresa = pempresa and num_credito = vnum_credito;

       IF vMtoFinan <= 0 THEN
             UPDATE sd_maesdos set sdo_capital      =  vCapTraspNoVenc + vMtoVevTrap,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
             CONTINUE FOREACH;
      END IF;

       let vDifMtoFinan  = vMtoFinanH -vMtoFinan ;
       IF vMtoVevTrap > 0 THEN
          let vDifMtoVenc = vMtoVevTrapH - vDifMtoFinan;
          IF vDifMtoVenc > 0 THEN
             let vCapTraspNoVenc  = vCapTraspNoVenc + (vMtoVevTrap - vDifMtoVenc);
             let vMtoVevTrap = vDifMtoVenc;
             UPDATE sd_maesdos set mto_venc_trasp     = vMtoVevTrap,
                                   cap_tras_no_venci = vCapTraspNoVenc
            WHERE num_credito = vnum_credito and empresa = pempresa;
          ELIF vDifMtoVenc <= 0 THEN
             let vCapTraspNoVenc  = vCapTraspNoVenc +  vMtoVevTrap;
             UPDATE sd_maesdos set sdo_capital      = vCapTraspNoVenc,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
          END IF;
        ELSE
             let vCapTraspNoVenc  = vCapTraspNoVenc +  vMtoVevTrap;
             UPDATE sd_maesdos set sdo_capital      = vCapTraspNoVenc,
                                   monto_vencido    = 0,
                                   mto_venc_trasp   = 0,
                                   cap_tras_no_venci=0
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecred set status_cred = 'AA'
             WHERE num_credito = vnum_credito and empresa = pempresa;
             UPDATE sd_maecredanexo set fecha_vencto = ''
             WHERE num_credito = vnum_credito and empresa = pempresa;
        END IF;
   END FOREACH


-- Nivela Saldos Transitorio con Cuotas cero
foreach
  select  a.num_credito ,monto_vencido into vnum_credito,vmonto_vencido
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  (monto_vencido < 0 Or sdo_capital < 0)
     and  a.status_cred = "BA"

   update sd_maesdos set sdo_capital = sdo_capital + vmonto_vencido,
          monto_vencido = 0
   where  empresa = "001" and num_credito = vnum_credito;
   update sd_maecred set status_cred = "AA"
   where  empresa = "001" and num_credito = vnum_credito;
   UPDATE sd_maecredanexo set fecha_vencto = ''
   WHERE num_credito = vnum_credito and empresa = pempresa;

end foreach
foreach
   select  a.num_credito ,monto_vencido into vnum_credito,vmonto_vencido
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
     and  monto_vencido = 0 and sdo_capital = 0
     and  a.status_cred = "BA"

   update sd_maecred set status_cred = "AA"
   where  empresa = "001" and num_credito = vnum_credito;
   UPDATE sd_maecredanexo set fecha_vencto = ''
   WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

--Nivela Saldos Con 1 Cuota Vencida

--foreach
-- select  a.num_credito ,sdo_cap_insoluto,sum(monto_vencido +  mto_venc_trasp + cap_tras_no_venci )
--         into vnum_credito ,vsdo_cap, vmonto_vencido
--    from  sd_maecred a,sd_maesdos b
--   where  a.empresa = b.empresa and a.num_credito = b.num_credito
   --  and  sdo_capital != sdo_cap_insoluto and b.sdo_capital = 0
--    and  sdo_capital  = 0
--     and  a.status_cred = "BT"
--    group by 1,2
--   If vsdo_cap = vmonto_vencido Then
--          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
--                                monto_vencido = 0,
--                                mto_venc_trasp = 0,
--                                cap_tras_no_venci = 0,
--                                sdo_moratorio = 0
--          where empresa = "001" and num_credito = vnum_credito;
--   End if;
--end foreach

foreach
 select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
    and  sdo_capital  < 0 and (mto_venc_trasp < 0 or mto_venc_trasp > 0)
     and  a.status_cred = "BT"
          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
                                monto_vencido = 0,
                                mto_venc_trasp = 0,
                                cap_tras_no_venci = 0,
                                sdo_moratorio = 0
          where empresa = "001" and num_credito = vnum_credito;
          update sd_maecred set status_cred = "AA"
          where  empresa = "001" and num_credito = vnum_credito;
          UPDATE sd_maecredanexo set fecha_vencto = ''
          WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

foreach
 select  a.num_credito into vnum_credito
    from  sd_maecred a,sd_maesdos b
   where  a.empresa = b.empresa and a.num_credito = b.num_credito
    and  sdo_capital  < 0 and  mto_venc_trasp <= 0
     and  a.status_cred = "BT"
          update sd_maesdos set sdo_capital   = sdo_cap_insoluto,
                                monto_vencido = 0,
                                mto_venc_trasp = 0,
                                cap_tras_no_venci = 0,
                                sdo_moratorio = 0
          where empresa = "001" and num_credito = vnum_credito;

          update sd_maecred set status_cred = "AA"
          where  empresa = "001" and num_credito = vnum_credito;
          UPDATE sd_maecredanexo set fecha_vencto = ''
          WHERE num_credito = vnum_credito and empresa = pempresa;
end foreach

return vcodret;
end
end procedure
;