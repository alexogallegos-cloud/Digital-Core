CREATE PROCEDURE "informix".executaedoctageneral_lib(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno          INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            VARCHAR(255);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;
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
LET v_cat                   = 0; --- CAT
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 100;

---SET DEBUG FILE TO "ExecutaEdoCtaGeneral.dbg";
---TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	--INSERT INTO sd_movhisedocta
	--	SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
	--		   a.hora_mov,			a.sucursal,                a.num_credito,
	--		   a.plaza,				a.transacc_suc,			   a.usuario,
	--		   a.monto,             a.codigo_fun,			   a.codigo_ref,
	--		   a.divisa,			a.reversado,			   a.folio_suc,
	--		   a.num_producto,      a.nro_tarjeta,			   a.referencia,
	--		   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
	--	       a.rfc_comer,			a.referencia23
    --    FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";

   ---EXECUTE PROCEDURE carga_movhis_edocta (pfechahoy) INTO v_cod_ret;

   ---IF v_cod_ret<> "000" THEN
         ---RETURN v_cod_ret;
   ---END IF;

	SET ISOLATION TO DIRTY READ;


 	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 FOREACH 
          SELECT empresa,num_credito
 			INTO v_empresa,v_num_credito
-- 			FROM bdicred:sd_movhisedocta
--            where empresa = pempresa
--            and codigo_fun = '002'
--            and codigo_ref = 37
            ---and num_credito = '600000005089'
--            group by empresa,num_credito
--            order by num_credito
			FROM bdicred:sd_movhisedocta
            where empresa = pempresa
            and codigo_fun = '002'
            and codigo_ref in (30,40,41,42)
            and num_credito not in 
                  (SELECT num_credito
         			FROM bdicred:sd_movhisedocta
                   where empresa = pempresa
                     and codigo_fun = '002'
                     and codigo_ref = '37'
                group by num_credito)
--            and num_credito = '600000005089'
            group by empresa,num_credito
            order by num_credito


		EXECUTE PROCEDURE generaestadosdecuenta_lib
					(
					v_empresa,
					v_num_credito,
					pfechahoy
					) INTO v_cod_ret;

      	IF v_cod_ret <> "000" THEN

      		SELECT descripcion  INTO v_descripcion
      		FROM bdinteg:si_codret
      		WHERE codigo_retorno = v_cod_ret
      		AND sistema  ="06";

      		INSERT INTO sd_valedocta
      			(
      			empresa,		num_credito,		cod_ret,
      			descripcion,	fecha_proc,			tipo
      			)
      		VALUES
      			(
      			v_empresa,		v_num_credito,		v_cod_ret,
      			v_descripcion,	pfechahoy,			"E"
      			);

		END IF
 	END FOREACH;

    ---DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE ;