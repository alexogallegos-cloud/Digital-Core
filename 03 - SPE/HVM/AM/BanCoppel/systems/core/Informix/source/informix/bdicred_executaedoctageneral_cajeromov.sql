CREATE PROCEDURE "informix".executaedoctageneral_cajeromov(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
--------------------------------------------------------
--	INICIALIZACION VARIABLES 
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc

--SET DEBUG FILE TO "ExecutaEdoCtaGeneral.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	
	-------------------------------------------------------
	--SE INICIALIZA TABLA PARA EDOCTAS
	------------------------------------------------------
	Truncate sd_movhisedocta;
        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy)) 
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	INSERT INTO sd_movhisedocta
		SELECT a.empresa,			a.secuencia,			   a.fecha_mov,			
			   a.hora_mov,			a.sucursal,                a.num_credito,
			   a.plaza,				a.transacc_suc,			   a.usuario,
			   a.monto,             a.codigo_fun,			   a.codigo_ref,
			   a.divisa,			a.reversado,			   a.folio_suc,
			   a.num_producto,      a.nro_tarjeta,			   a.referencia,
			   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
		       a.rfc_comer,			a.referencia23		
        FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
		WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
		AND c.numero = b.transacc AND c.se_emite_edocta = "S"
		and c.sistema ="06"
		AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
		AND reversado <> "S";
	-------------------------------------------------------
    --SE CORRE ACTUALIZACION DE ESTADISTICAS 
    ------------------------------------------------------
	
	UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;	
	-------------------------------------------------------
	--SE ARREGLAN TRANSACCIONES
	------------------------------------------------------
	CALL ARR_MOVHIS();
END;

	RETURN "000";

END PROCEDURE ;