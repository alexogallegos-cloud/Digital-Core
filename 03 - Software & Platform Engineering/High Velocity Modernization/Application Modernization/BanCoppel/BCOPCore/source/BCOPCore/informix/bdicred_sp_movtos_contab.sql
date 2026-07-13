CREATE PROCEDURE "informix".sp_movtos_contab(p_empresa  CHAR(3))
--EXECUTE PROCEDURE sp_movtos_contab_prueba('001');

   RETURNING CHAR(5)      -- Codigo de Retorno

   DEFINE v_codret               CHAR(3);
   DEFINE sql_err                SMALLINT;
   DEFINE v_sql                  CHAR(1000);
   DEFINE isam_err               SMALLINT;
   DEFINE error_info             CHAR (40);
   DEFINE wdir                   CHAR(500);
   DEFINE v_sistema              CHAR(02);
   DEFINE v_num_credito          CHAR(20);
   DEFINE v_fecha_mov            DATE;
   DEFINE v_monto                DECIMAL(18,2);
   DEFINE v_codigo_fun           CHAR(03);
   DEFINE v_codigo_ref           INTEGER;
   DEFINE v_numero               CHAR(04);
   DEFINE v_descripcion          CHAR(50);
   DEFINE v_secuencia            INTEGER;
   DEFINE v_cuentac              CHAR(20);
   DEFINE v_cuentaa              CHAR(20);
   DEFINE v_ano_wk               CHAR(04);
   DEFINE v_fecha                CHAR(06);
   DEFINE v_sepa                 CHAR(2);
   DEFINE v_ruta                 CHAR(26);

   LET v_sql                  = '';
   LET v_codret               = "000";
   LET v_sistema              = '';
   LET v_num_credito          = '';
   LET v_fecha_mov            = '';
   LET v_monto                = 0;
   LET v_codigo_fun           = '';
   LET v_codigo_ref           = 0;
   LET v_numero               = '';
   LET v_descripcion          = '';
   LET v_secuencia            = 0;
   LET v_cuentac              = '';
   LET v_cuentaa              = '';
   LET v_sepa                 = '\|';
   LET v_ruta                 = '';
   --LET v_ano_wk               = YEAR(TODAY);
   --LET v_ano_wk               = v_ano_wk[3,4];
   --LET v_fecha                = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
   LET v_fecha				  = '';

	--SET DEBUG FILE TO "/ids10_uc9/raul/pisa/sp_movtos_contab.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	set lock mode to wait 3;

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "ErrContabmvtos.err";
      TRACE v_num_credito||" * "||sql_err||" * "||isam_err||" * "||error_info;
		IF sql_err <> 0  THEN
			 LET v_codret = sql_err;
			 let v_codret = v_codret;
			 ROLLBACK WORK;
			 --BEGIN WORK;
			 RETURN v_codret;
		END IF
   END EXCEPTION;
   
   -- Recupera la fecha anterior con la que se va a generar el archivo
   SELECT LPAD(DAY(fecha_ant),2,0)||LPAD(MONTH(fecha_ant),2,0)||NVL(SUBSTR(YEAR(fecha_ant), 3, 2),'')
   INTO v_fecha
   FROM sd_fechas
   WHERE empresa = p_Empresa;

   SELECT TRIM(valor)
   INTO v_ruta
   FROM sd_param
   WHERE empresa = p_empresa and cod_param ='47';
   
	--** Borra Archivo Por Si Fue Ya Creado  **--
    BEGIN
	
		ON EXCEPTION IN (-668) SET sql_err
			LET v_codret = "000";
			LET wdir = wdir;
		END EXCEPTION WITH RESUME;

        LET wdir = 'rm ' || TRIM(v_ruta) || TRIM (v_fecha) || '_movimientos_contables_dia.txt';
        SYSTEM wdir;
		
    END ;
	
    LET v_sql =
	'echo '||'sistema'||v_sepa||'num_credito'||v_sepa||'fecha_mov'||v_sepa||'monto'||v_sepa||'codigo_fun'||v_sepa||'codigo_ref'||v_sepa||'numero'||v_sepa||'descripcion'||v_sepa||'secuencia'||v_sepa||'cuentac'||v_sepa||'cuentaa'||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_movimientos_contables_dia.txt';
    SYSTEM v_sql;
	
	FOREACH
  
	---- Se modifica la busqueda a la del nuevo esquema de reestructura RaÃºl RamÃ­rez
    SELECT {+INDEX (bdinteg:si_prodtran idx01_prodtran)}
		c.sistema, num_credito, a.fecha_mov, monto,
		b.codigo_fun, b.codigo_ref, numero,
		c.descripcion, nvl(d.secuencia,""),
		nvl(trim(c_ccmayor)||'-'||trim(c_ccsub)||'-'||trim(c_ccsubsub)||'-'||trim(c_ccsssub)||'-'||trim(c_ccssssub)||'-'||trim(c_sector),""),
		nvl(trim(a_ccmayor)||'-'||trim(a_ccsub)||'-'||trim(a_ccsubsub)||'-'||trim(a_ccsssub)||'-'||trim(a_ccssssub)||'-'||trim(a_sector),"")
    INTO  v_sistema, v_num_credito, v_fecha_mov,
		v_monto,   v_codigo_fun,  v_codigo_ref,
		v_numero,  v_descripcion, v_secuencia,
		v_cuentac, v_cuentaa
    FROM   sd_movhiscrd a, sd_transfun b,
		bdinteg:si_transacc c,
		bdinteg:si_prodtran d
    WHERE  a.codigo_fun = b.codigo_fun
		AND   a.codigo_ref = b.codigo_ref
		AND   numero = transacc
		AND   transaccion = transacc
		AND   d.sistema = c.sistema
		AND   a.empresa = p_empresa
		AND   d.producto = '6011'
		--Se modifica para solo consultar lo del dia anterior
		AND   a.fecha_mov >= (TODAY - 1 UNITS DAY)
	ORDER BY a.num_credito, a.fecha_mov

    --** Crea Archivo Plano Local **--
	LET v_sql =
	'echo '||v_sistema||v_sepa||v_num_credito||v_sepa||v_fecha_mov||v_sepa||v_monto||v_sepa||v_codigo_fun||v_sepa||v_codigo_ref||v_sepa||v_numero||v_sepa||v_descripcion||v_sepa||v_secuencia||v_sepa||v_cuentac||v_sepa||v_cuentaa||v_sepa||' >>'||TRIM(v_ruta)||TRIM(v_fecha)||'_movimientos_contables_dia.txt';

    SYSTEM v_sql;

	END FOREACH;

END
RETURN v_codret;
END PROCEDURE;