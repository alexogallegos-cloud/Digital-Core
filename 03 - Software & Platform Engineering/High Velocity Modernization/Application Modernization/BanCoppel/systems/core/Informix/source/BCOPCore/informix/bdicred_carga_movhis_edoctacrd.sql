CREATE PROCEDURE "informix".carga_movhis_edoctacrd(fecha_hoy DATE, pnum_producto CHAR(4))
RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;
--
DEFINE p_empresa     	CHAR(3);
DEFINE p_secuencia   	integer;
DEFINE p_fecha_mov   	DATE ;
DEFINE p_hora_mov    	DATETIME HOUR to FRACTION(3);
DEFINE p_sucursal    	CHAR(4);
DEFINE p_num_credito 	CHAR(20);
DEFINE p_plaza       	CHAR(3);
DEFINE p_transacc_suc	CHAR(4);
DEFINE p_usuario     	CHAR(8);
DEFINE p_monto       	DECIMAL(18,2);
DEFINE p_codigo_fun  	CHAR(3);
DEFINE p_codigo_ref  	INTEGER;
DEFINE p_divisa      	CHAR(2);
DEFINE p_reversado   	CHAR(1);
DEFINE p_folio_suc   	CHAR(16);
DEFINE p_num_producto	CHAR(4);
DEFINE p_nro_tarjeta 	VARCHAR(20,1);
DEFINE p_referencia  	VARCHAR(80,1);
DEFINE p_tipo_cambio 	DECIMAL(14,6);
DEFINE p_monto_dls   	DECIMAL(14,2);
DEFINE p_suc_origen  	VARCHAR(4,1);
DEFINE p_rfc_comer   	VARCHAR(20,1);
DEFINE p_referencia23	VARCHAR(23,1);
DEFINE cBanBegin        CHAR(1);
DEFINE p_descripcion    VARCHAR(100,1);
DEFINE p_naturaleza     CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret   = "000";
LET vsqlerr    = 0;
LET numcredito = "";
LET icontador  = 1;
LET cBanBegin  = 'N';
LET p_descripcion = "";
LET p_naturaleza  = "";

-- Autor: Jose de Jesus Almeida
-- Fecha: 2009/07/23
-- Modificación: Se realiza modificación con la finalidad de agregar un parámetro
--               para identificar si sera la obtencion de los datos para la generación
--               de estados de cuenta para tarjetas de crédito o para créditos otorgados
--               de forma reestructurada, la solicitud del cambio fue solicitada en el
--               anexo incluido en el RQM 10 105 (Edo.Cta Reestructura)

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
   	  IF cBanBegin= 'S' THEN
	     ROLLBACK WORK;
	  END IF;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "carga_movhis_edocta.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

  set isolation to dirty read;

  select * from "informix".sd_movhiscrd 
  where fecha_mov between  fecha_hoy - 1 UNITS MONTH and fecha_hoy
    and num_credito in (select num_credito from "informix".sd_maecredcrd where num_producto = pnum_producto)
  into temp temp_movhiscrd with no log;

  create index inx1_temp_movhiscrd on temp_movhiscrd(codigo_fun, codigo_ref);
  create index inx2_temp_movhiscrd on temp_movhiscrd(fecha_mov, num_producto, reversado);
  update statistics medium for table temp_movhiscrd;

  FOREACH WITH HOLD


                SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
                       a.hora_mov,			a.sucursal,                a.num_credito,
                       a.plaza,				a.transacc_suc,			   a.usuario,
                       a.monto,             a.codigo_fun,			   a.codigo_ref,
                       a.divisa,			a.reversado,			   a.folio_suc,
                       a.num_producto,      a.nro_tarjeta,			   a.referencia,
                       a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
                       a.rfc_comer,			a.referencia23,     TRIM(b.descripcion),
                       c.naturaleza
                  INTO
                       p_empresa,           p_secuencia,               p_fecha_mov,
                       p_hora_mov,          p_sucursal,                p_num_credito,
                       p_plaza,             p_transacc_suc,            p_usuario,
                       p_monto,             p_codigo_fun,              p_codigo_ref,
                       p_divisa,            p_reversado,               p_folio_suc,
                       p_num_producto,      p_nro_tarjeta,             p_referencia,
                       p_tipo_cambio,       p_monto_dls,               p_suc_origen,
                       p_rfc_comer,         p_referencia23,            p_descripcion,
                       p_naturaleza
                 FROM temp_movhiscrd a,"informix".sd_transfun b, bdinteg:si_transacc  c
                WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
                  AND c.numero = b.transacc AND c.se_emite_edocta = "S"
                  AND fecha_mov >= case
                  WHEN date(fecha_hoy - 1 UNITS MONTH) = (select fecha_apertura from bdicred:sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
                  THEN date(fecha_hoy - 1 UNITS MONTH)
                  ELSE date(fecha_hoy - 1 UNITS MONTH + 1 units day) end
                  AND fecha_mov <= fecha_hoy
                  AND a.reversado = "N"
                  AND c.se_emite_edocta = "S"
				  AND c.sistema ="06" --Se agrega el sistema 06 a la validacion
                  AND a.num_producto = pnum_producto

          BEGIN WORK;
                INSERT INTO "informix".sd_movhisedoctacrd
                     VALUES (p_empresa, p_secuencia, p_fecha_mov, p_hora_mov, p_sucursal, p_num_credito, p_plaza, p_transacc_suc, p_usuario, p_monto, p_codigo_fun, p_codigo_ref, p_divisa, p_reversado, p_folio_suc, p_num_producto, p_nro_tarjeta, p_referencia, p_tipo_cambio, p_monto_dls, p_suc_origen, p_rfc_comer, p_referencia23,p_descripcion,p_naturaleza);
          COMMIT WORK;

  END FOREACH

  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_movhisedoctacrd;

  RETURN scod_ret;
END
END PROCEDURE;