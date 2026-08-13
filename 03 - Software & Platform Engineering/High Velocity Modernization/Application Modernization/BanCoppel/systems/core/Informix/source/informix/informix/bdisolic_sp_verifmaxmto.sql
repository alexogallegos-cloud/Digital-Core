CREATE PROCEDURE "informix".sp_verifmaxmto(
                pempresa   CHAR(3),
                pnumcte    CHAR(20),
                preqlin    CHAR(1),
                pnumprod   CHAR(4))

   RETURNING CHAR(6), CHAR(80), CHAR(20), MONEY(14,2);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE wnumlin             CHAR(20);
   DEFINE wmtomax             MONEY(14,2);
   DEFINE wrechq              MONEY(14,2);
   DEFINE wrecinv             MONEY(14,2);
   DEFINE wreciprocidad       MONEY(15,2);
   DEFINE wfactrec            DECIMAL(6,3);
   DEFINE wsdolin             MONEY(14,2);
   DEFINE wstatuslin          CHAR(2);
   --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
   DEFINE mSdoActual    money(14,2);
   DEFINE mSdoRetenido  money(14,2);
   DEFINE mSdoCong      money(14,2);
   DEFINE mSaldoSbc     money(14,2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_VerifMaxMto.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN cod_ret, p_mensaje, wnumlin, wmtomax;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET wnumlin = ' ';
   LET wmtomax = 0;
   --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    LET mSdoActual    = 0.00;
    LET mSdoRetenido  = 0.00;
    LET mSdoCong      = 0.00;
    LET mSaldoSbc     = 0.00;	

   --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
   SELECT
      sdo_actual, sdo_cong, sdo_retenido, saldo_sbc
   INTO
      mSdoActual, mSdoCong, mSdoRetenido, mSaldoSbc
   FROM
     bdicheq:sc_maechq
   WHERE
      num_cte = pnumcte
   AND
      status_cta = '1';
   
   --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
   EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
   INTO cCodRetConsSdo,cMensajeRetConsSdo,wrechq;

   SELECT
      NVL(SUM(capital - sdo_retenido - sdo_cong),0)
   INTO
      wrecinv
   FROM
      bdinvers:sv_maeinv
   WHERE
      num_cte = pnumcte
   AND
      status_cta = '1';

   LET wreciprocidad = wrechq + wrecinv;

   SELECT
      valor
   INTO
      wfactrec
   FROM
      bdicred:sd_param
   WHERE
      cod_param = '200';

   LET wreciprocidad = wreciprocidad * wfactrec;

   IF (preqlin = '1') THEN
      SELECT
         NVL(num_linea,' '),
         linea_prod - linea_util
      INTO
         wnumlin,
         wsdolin
      FROM
         lineas:sl_ctepro
      WHERE
         numcte = pnumcte
      AND
         producto = pnumprod;

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF (nrows = 0) THEN
         LET cod_ret = "100";
         LET p_mensaje = 'Cliente no tiene Linea';
         LET wnumlin = ' ';
         LET  wmtomax = 0;
         RETURN cod_ret, p_mensaje, wnumlin, wmtomax;
      END IF;

      SELECT
         status_linea
      INTO
         wstatuslin
      FROM
         lineas:sl_ctegpo
      WHERE
         num_linea = wnumlin
      AND
         numcte = pnumcte;

      IF (wstatuslin <> 'AA') THEN
         LET cod_ret = '100';
         LET p_mensaje = 'La linea no esta Vigente';
         RETURN cod_ret, p_mensaje, wnumlin, wmtomax;
      END IF;

      IF(wsdolin < wreciprocidad) THEN
         LET wmtomax = wsdolin;
      ELSE
         LET wmtomax = wreciprocidad;
      END IF;

   END IF;
   IF(wnumlin IS NULL) THEN
      LET wnumlin = ' ';
   END IF;
   RETURN cod_ret, p_mensaje, wnumlin, wmtomax;
END PROCEDURE

