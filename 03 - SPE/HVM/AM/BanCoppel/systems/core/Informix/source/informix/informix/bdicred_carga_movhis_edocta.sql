CREATE PROCEDURE "informix".carga_movhis_edocta(fecha_hoy date)
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

--
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "000";
LET vsqlerr = 0;
LET numcredito="";
LET icontador=1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "limpia_amortizacredito.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

  update statistics medium for table bdicred:sd_movhisedocta;

  FOREACH WITH HOLD 
		SELECT a.empresa,			a.secuencia,			   a.fecha_mov,			
			   a.hora_mov,			a.sucursal,                a.num_credito,
			   a.plaza,				a.transacc_suc,			   a.usuario,
			   a.monto,             a.codigo_fun,			   a.codigo_ref,
			   a.divisa,			a.reversado,			   a.folio_suc,
			   a.num_producto,      a.nro_tarjeta,			   a.referencia,
			   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
		       a.rfc_comer,			a.referencia23		
          into
               p_empresa,           p_secuencia,               p_fecha_mov, 
               p_hora_mov,          p_sucursal,                p_num_credito, 
               p_plaza,             p_transacc_suc,            p_usuario, 
               p_monto,             p_codigo_fun,              p_codigo_ref, 
               p_divisa,            p_reversado,               p_folio_suc, 
               p_num_producto,      p_nro_tarjeta,             p_referencia, 
               p_tipo_cambio,       p_monto_dls,               p_suc_origen, 
               p_rfc_comer,         p_referencia23
        FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
		WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
		AND c.numero = b.transacc AND c.se_emite_edocta = "S"
		AND fecha_mov > date(fecha_hoy - 1 UNITS MONTH) AND fecha_mov <= fecha_hoy
		AND c.sistema ="06" --Se agrega el sistema 06 a la validacion
		AND reversado <> "S"
		

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        insert into sd_movhisedocta 
             values (p_empresa, p_secuencia, p_fecha_mov, p_hora_mov, p_sucursal, p_num_credito, p_plaza, p_transacc_suc, p_usuario, p_monto, p_codigo_fun, p_codigo_ref, p_divisa, p_reversado, p_folio_suc, p_num_producto, p_nro_tarjeta, p_referencia, p_tipo_cambio, p_monto_dls, p_suc_origen, p_rfc_comer, p_referencia23);
    
    IF icontador>=90000 then
        COMMIT WORK; 
        update statistics medium for table bdicred:sd_movhisedocta;
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  update statistics medium for table bdicred:sd_movhisedocta;


  RETURN scod_ret;
END
END PROCEDURE;