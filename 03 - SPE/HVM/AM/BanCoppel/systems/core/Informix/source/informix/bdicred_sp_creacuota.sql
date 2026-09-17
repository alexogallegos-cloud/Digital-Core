CREATE PROCEDURE "informix".sp_creacuota(pEmpresa CHAR(3),
                                  pCredito CHAR(20),
                                  pMonto   DECIMAL(14,2)) 
RETURNING CHAR(5);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *       
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vMtoPaso            DECIMAL(14,2);
   DEFINE vMtoDif             DECIMAL(14,2);
   DEFINE vInsoluto           DECIMAL(14,2);
   DEFINE vFecha              DATE;   
   DEFINE vCuotas             SMALLINT;
   DEFINE vMensaje            VARCHAR(50);
   DEFINE i                   SMALLINT;
   DEFINE GLOBAL FechaHoy     DATE DEFAULT NULL;
 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *       
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *       
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vMtoPaso   = 0;    
   LET vMtoDif    = 0;    
   LET vInsoluto  = 0;
   LET vCuotas    = 0;    
   LET vFecha     = "";   
   LET vMensaje   = "";   
   LET i          = 0;    
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

        SELECT COUNT(*)
          INTO vCuotas
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = pCredito
           --AND fecha_cuota = FechaHoy + 1 UNITS MONTH;
           AND fecha_cuota = FechaHoy ;
        IF vCuotas = 0 THEN

          CALL sp_calcula_fecha("001" ,1 ,"M" ,(FechaHoy -1 units month)  ,"01" ,"01")
          RETURNING cod_ret, vMensaje, vFecha;


          INSERT INTO sd_amortiza_credito values
            (pEmpresa,pCredito,vFecha ,"3",0,0,0,"1","0","",
             0,0,"1","0","", 0,0,"1","0","",
             0,0,0,0,0,0,0,"1", 0,0,"1","",
             i,0,0,"","");

        END IF

        LET vMtoPaso = pMonto;

        UPDATE sd_amortiza_credito
           SET capital_mto_cuota = vMtoPaso,
               capital_debe = vMtoPaso
         WHERE empresa = pEmpresa
           AND num_credito = pCredito
           AND fecha_cuota = FechaHoy;

        IF vMtoDif <> 0 THEN
                SELECT MAX(fecha_cuota)
                  INTO vFecha
                  FROM sd_amortiza_credito
                 WHERE empresa = pEmpresa
                   AND num_credito = pCredito
                   AND capital_status = "1";

                UPDATE sd_amortiza_credito
                   SET capital_mto_cuota = capital_mto_cuota + vMtoDif,
                       capital_debe = capital_debe + vMtoDif
                 WHERE empresa = pEmpresa
                   AND num_credito = pCredito
                   AND fecha_cuota = vFecha;
        END IF

        IF cod_ret = "00000" THEN
                LET cod_ret = "000";
        END IF


END
        RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Procedimiento para la insercion de amortizaciones, asi como',
'para el prorrateo de la deuda',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'VERSION: 1.00.001',
'BD    : BDICRED'
;

CREATE PROCEDURE "informix".genmovcierre_cierre(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_codigo_ref             INTEGER,
   p_codigo_fun             VARCHAR(3),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4),
   p_plaza		    VARCHAR(3))
RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_usuario       VARCHAR(8);


DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;
DEFINE vSucOri     CHAR(4);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';

   IF (p_monto IS NULL) THEN
      LET p_monto = 0;
   END IF;

   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_usuario    = USER;

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################


   INSERT INTO sd_movhis_cierre (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       SUC_ORIGEN     )
      VALUES ( p_empresa,
               p_fecha_hoy,
               current,
               p_sucursal,
               p_num_credito,
               p_plaza,
               p_transacc_suc,
               v_usuario,
               p_monto,
               p_codigo_fun,
               p_codigo_ref,
               p_divisa,
               "N",
               p_foliosuc,
               p_num_producto,
	       p_sucursal);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE
DOCUMENT           
'Procedimiento para la insercion de los movmientos que',
'son generdos por el cierre        ',
'AUTOR : Antonio Ruiz',
'FECHA : 19/Octubre/2007',   
'VERSION: 1.00.000',
'BD    : BDICRED' ;

CREATE PROCEDURE "informix".calc_iva_grav_cierre(o_empresa    CHAR(3),
			       o_sucursal   CHAR(4),
			       o_numcred    CHAR(20),
			       o_monto      DECIMAL(14,2),
			       o_folio      CHAR(16),
			       o_tasa       CHAR(4),
			       o_divisa     CHAR(2),
			       o_diascalc   SMALLINT,
			       o_diasacum   SMALLINT,
			       o_intperiodo DECIMAL(14,2),
			       o_producto   CHAR(4),
			       o_bandera    CHAR(1),
			       o_plaza      CHAR(3),
			       o_contabiliza CHAR(1),
			       o_precioreal DECIMAL(14,6) )

RETURNING CHAR(5),       -- Codigo Retorno
          DECIMAL(14,2);

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE CodRet              CHAR(5);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE vIntGrav            DECIMAL(14,2);
DEFINE vIntNoGrav	   DECIMAL(14,2);
DEFINE vTasaIva  	   DECIMAL(14,6);
DEFINE vTasaReal  	   DECIMAL(14,6);
DEFINE vIvaIntGrav         DECIMAL(14,2);
DEFINE vIvaReal            DECIMAL(14,2);
DEFINE GLOBAL FechaHoy     DATE DEFAULT NULL;
DEFINE GLOBAL vIvaSuc      DECIMAL(5,3)  DEFAULT 0;
DEFINE GLOBAL vIvaBase     DECIMAL(5,3)  DEFAULT 0;
DEFINE Mensaje             VARCHAR(20);
DEFINE vReferencia         SMALLINT;
DEFINE vTran		   CHAR(4);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   LET CodRet = sql_err;
   RETURN CodRet, vIvaIntGrav;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET CodRet        = "000";
LET vIvaIntGrav   = 0;
LET vIvaReal      = 0;
LET vTasaReal     = 0;
LET vTran         = "0000";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	IF o_precioreal <> 0 THEN
		LET vTasaIva = (o_tasa / 100) - (o_precioreal * 12);
		LET vTasaIva = (vTasaIva / (o_tasa / 100)) * vIvaSuc ;
		LET vIvaIntGrav = (o_intperiodo) * vTasaIva;
	        LET vIvaReal = (o_intperiodo) * vIvaSuc;
		-- Determina Int Gravado y No Gravado
		LET vTasaIva = (o_tasa / 100) - (o_precioreal * 12);
		LET vTasaReal = vTasaIva / (o_tasa / 100);
		LET vIntGrav = o_intperiodo * vTasaReal;
		LET vIntNoGrav = o_intperiodo - vIntGrav;
	ELSE
		LET vIvaIntGrav = o_intperiodo * vIvaSuc;
		LET vIntGrav = o_intperiodo;
		LET vIntNoGrav = 0;
	END IF

	IF o_contabiliza = "S" THEN
	   -- Genera Movmiento de Interes Gravado
           CALL genmovcierre_cierre(o_empresa, o_numcred, o_producto,10,
                             "606", FechaHoy, vIntGrav, o_folio,
                             o_sucursal, o_divisa, "0000",o_plaza)
           RETURNING CodRet, Mensaje;
           IF (CodRet <> "00000") THEN
                 RETURN CodRet, vIvaIntGrav;
           ELSE
              LET CodRet = "000";
           END IF;

	   -- Genera Movimiento de Interes No Gravado
	   IF vIntNoGrav > 0 THEN
        	CALL genmovcierre_cierre(o_empresa, o_numcred, o_producto,11,
                	    "606", FechaHoy, vIntNoGrav, o_folio,
                  	    o_sucursal, o_divisa, "0000",o_plaza)
        	RETURNING CodRet, Mensaje;
        	IF (CodRet <> "00000") THEN
              	   RETURN CodRet, vIvaIntGrav;
        	ELSE
           	   LET CodRet = "000";
        	END IF;
	   END IF

	   -- Genera Movimiento de Iva de Int Gravado
	   IF vIvaSuc = vIvaBase THEN
		IF o_bandera = "0" THEN
			LET vReferencia = 20; -- Iva Vigente 15%
		ELSE
			LET vReferencia = 22; -- Iva Vencido 15%
		END IF
	   ELSE
		IF o_bandera = "0" THEN
		   	LET vReferencia = 21; -- Iva Vigente 10%
		ELSE
		   	LET vReferencia = 23; -- Iva Vencido 10%
		END IF
	   END IF
           CALL genmovcierre_cierre(o_empresa, o_numcred, o_producto,vReferencia,
                  "340", FechaHoy, vIvaIntGrav, o_folio,
                  o_sucursal, o_divisa, "0000",o_plaza)
           RETURNING CodRet, Mensaje;

           IF (CodRet <> "00000") THEN
              RETURN CodRet, vIvaIntGrav;
           ELSE
              LET CodRet = "000";
           END IF;
	END IF

	RETURN CodRet, vIvaIntGrav;

END PROCEDURE 
DOCUMENT
'Procedimiento para el calculo de los intereses',
'gravados y exentos, asi como la generancion de los mismos',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'VERSION : 1.00.002',
'BD    : BDICRED'  ;

CREATE PROCEDURE "informix".pasecont_cierre(pempresa     CHAR(3),
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
           FROM bdinteg:si_plazas a, sd_movhis_cierre b, sd_transfun c,
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
           FROM bdinteg:si_plazas a, sd_movhis_cierre b, sd_transfun c,
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

create procedure "informix".actmora(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vnum_credito    char(20);
define vStatus         char(1);
define vsqlerr         Integer;
define vCuotas         Integer;
define vMtoVigente     money(14,2);
define vSdoMinimo      money(14,2);
define vMtoTransi      money(14,2);
define vCapVencido     money(14,2);
define vIntVenc        money(14,2);
define vMtoCuota       money(14,2);
define vMtoCuotaVig    money(14,2);
define vInt            money(14,2);
define vMora           money(14,2);
define vTotAdeudoVenc  money(14,2);
define vMto1           money(14,2);
define vMto2           money(14,2);
define vCapPag         money(14,2);
define vCuotaVig       money(14,2);
define vTotCap         money(14,2);
define vRem1           money(14,2);
define vRem2           money(14,2);
define vTotInt         money(14,2);
define v1              money(14,2);
define vFecVenci       date;
define vFecha          date;
DEFINE vBegin     CHAR(1);


-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "actcuota.out";
 -- trace on;



  LET vBegin     = "?";
  let vnum_credito    = "";
  let vcodret         = "000";
  let vMtoVigente     =0;
  let vSdoMinimo      =0;
  let vMtoTransi      =0;
  let vCuotas         =0;
  let vCapVencido     =0;
  let vIntVenc        =0;
  let vMtoCuota       =0;
  let vMtoCuotaVig    =0;
  let vInt            =0;
  let vTotAdeudoVenc  =0;
  let vMto1           =0;
  let vMto2           =0;
  let vCapPag         =0;
  let vCuotaVig       =0;
  let vMora           =0;
  let  vTotCap        =0;
  let  vTotInt        =0;
  let  vRem1          =0;
  let  vRem2          =0;
  let vFecha          ='';
  Let vStatus         ='';


--Moratorios

FOREACH WITH HOLD

   Select num_credito,
        NVL(sum((mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag)
        + (mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag)),0)
   Into vnum_credito , vMora
   From sd_amortiza_credito
   Where empresa='001'  and (mora_provi_ordi + mora_provi_cope) > 0
   Group by 1

  BEGIN WORK;
  LET vBegin = "S";

   update sd_maesdos set sdo_contab_mora = vMora,
                         sdo_moratorio   = 0
   where empresa = "001" and num_credito = vnum_credito;
   
  COMMIT WORK;
  LET vBegin ="N";
END FOREACH;

return vcodret;
end
end procedure
;