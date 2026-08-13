CREATE PROCEDURE "informix".sp_calif_maecred(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);

DEFINE cBegin            CHAR(1);
DEFINE vcontador_insert  INTEGER;
DEFINE dtFechaCorte  DATE;
DEFINE dtFechaUltMes DATE;

DEFINE cNumCredito 	 CHAR(20);
DEFINE cGradoRiesgo                  CHAR(2);

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          ROLLBACK WORK;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
    --TRACE ON;

    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '000000';
    LET cMensajeRet= 'El proceso de CORRECCION DE LA CALIFICACION se realizó correctamente';
    LET cBegin= 'F';
    LET vcontador_insert= 0;
    LET dtFechaCorte = date(1);
    LET dtFechaUltMes = date(1);
    let cGradoRiesgo = '';
    LET cNumCredito 		= 	'';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    FOREACH WITH HOLD
       SELECT num_credito, grado_riesgo
         INTO cNumCredito, cGradoRiesgo
         from bdicred:sd_hist_reserva
          where empresa = '001'
          and fecha_CIERRE = mdy('03','31','2012')

          begin work;
            update bdicred:sd_maecred SET calificacion_riesgo = cGradoRiesgo where empresa = '001' AND num_credito = cNumCredito;
          commit work;
    END FOREACH;


    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'AUTOR : ',
'FECHA : ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_corrige_calificacion(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);

DEFINE cBegin            CHAR(1);
DEFINE vcontador_insert  INTEGER;
DEFINE dtFechaCorte  DATE;
DEFINE dtFechaUltMes DATE;

DEFINE cNumCredito 	 CHAR(20);

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          ROLLBACK WORK;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
    --TRACE ON;

    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '000000';
    LET cMensajeRet= 'El proceso de CORRECCION DE LA CALIFICACION se realizó correctamente';
    LET cBegin= 'F';
    LET vcontador_insert= 0;
    LET dtFechaCorte = date(1);
    LET dtFechaUltMes = date(1);

    LET 	cNumCredito 		= 	'';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
       SELECT num_credito
         INTO cNumCredito
         from bdicred:sd_maesdoscont
          where empresa = '001'
          and fecha = mdy('03','31','2012')
          and sdo_cap_insoluto <> sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci

          begin work;
            delete from bdicred:sd_hist_reserva where empresa = '001' AND num_credito = cNumCredito AND fecha_CIERRE = mdy('03','31','2012');
            delete from bdicred:sd_maesdoscont  where empresa = '001' AND num_credito = cNumCredito AND fecha = mdy('03','31','2012');
          commit work;
    END FOREACH;


    FOREACH WITH HOLD
       SELECT num_credito
         INTO cNumCredito
         from bdicred:sd_hist_reserva
          where empresa = '001'
          and fecha_CIERRE = mdy('03','31','2012')
          AND antecedente_buro IN ('X','0') 
          AND reserva_buro > 0

          begin work;
            update bdicred:sd_hist_reserva SET reserva_buro = 0, reserva_buro_gradual = 0 where empresa = '001' AND num_credito = cNumCredito AND fecha_CIERRE = mdy('03','31','2012');
          commit work;
    END FOREACH;

    UPDATE statistics medium FOR TABLE bdicred:sd_hist_reserva;
    UPDATE statistics medium FOR TABLE bdicred:sd_maesdoscont;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'AUTOR : ',
'FECHA : ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtenercuentascolocacion(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20))

	RETURNING 	CHAR(6) AS retorno, CHAR(3) AS empresa, CHAR(20) AS numcredito, CHAR(20) AS numcliente,
				CHAR(1) AS identificador;

	--VARIABLES DE ERROR DEL SP
    DEFINE cVarDataErr			VARCHAR(255);
    DEFINE iSqlErr				INTEGER;
    DEFINE iSamErr				INTEGER;

	--DECLARACIÓN DE VARIABLES DE USO DEL SP
	DEFINE v_sValRetorno		CHAR(6);
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sNumcredito		CHAR(20);
	DEFINE v_sNumCliente		CHAR(20);
	DEFINE v_sIdentificador		CHAR(1);

	-----------------------------------------------------------------------
	--Creado por: Vladimir Félix Gálvez
	--Fecha de Creación: 07-Agosto-2009
	--Caso de uso asociado: 
	--Obtiene las cuentas de credito de los clientes.
	--Debug del Procedure
	--SET DEBUG FILE TO "/tmp/vladi/sp_obtenercuentascolocacion.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno 		= '000001';
	LET v_sEmpresa			= '';
	LET v_sNumcredito		= '';
	LET v_sNumCliente		= '';
	LET v_sIdentificador	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno,'','','','';
			END IF;
		END EXCEPTION;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumCliente, '') = '' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;

		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
		--Consultar la información del catalogo de nomina de las empresas.
		FOREACH
			SELECT empresa, num_credito, numcte, 'C'
			INTO v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador
			FROM bdicred:sd_maecred 
			WHERE empresa = p_sEmpresa
			AND numcte = p_sNumCliente
			

			LET v_sValRetorno = '000000';
			RETURN  v_sValRetorno, v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador WITH RESUME;

		END FOREACH;
	END;
END PROCEDURE;