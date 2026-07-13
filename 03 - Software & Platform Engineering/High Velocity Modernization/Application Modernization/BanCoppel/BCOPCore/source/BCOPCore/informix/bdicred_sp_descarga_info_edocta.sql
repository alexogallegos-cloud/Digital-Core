create procedure "informix".sp_descarga_info_edocta()
RETURNING CHAR(5);

DEFINE v_ruta             VARCHAR(255);
DEFINE v_ruta_cfd         VARCHAR(255);
DEFINE cod_ret            CHAR(5);
DEFINE sql_err            INTEGER;
DEFINE v_sql              CHAR(1000);
DEFINE v_sql1             CHAR(200);
DEFINE v_sql2             CHAR(700);
DEFINE dFecha_hoy         DATE;
DEFINE v_periodo_tc_ini   DATE;	  		--periodo_tc_ini
DEFINE cEmpresa           CHAR(3);


LET v_ruta            = "";
LET v_sql             = "";
LET v_sql1            = "";
LET v_sql2            = "";
LET v_periodo_tc_ini  = " ";	--periodo_tc_ini
LET dFecha_hoy        = date(1);
LET cEmpresa          = '001';
LET cod_ret           = "00000";
   
set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 27/11/2014
-- Autor: Marco A. Campos
-- Descripción: Descargar ciertos campos en un archivo .unl para cargarlos en una tabla y que sea leída en el sp_rep_regulatorios_irb_compl 

--  SET DEBUG FILE TO 'sp_descarga_info_edocta.out';
--  TRACE ON;

 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;            
            RETURN cod_ret;
        END IF
   END EXCEPTION;


   
   -- /RESPALDOS/infoedocta/ 
   SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = cEmpresa AND cod_param = '039';
   
   select fecha_hoy into dFecha_hoy
     from bdicred:"informix".sd_fechas
    where empresa = '001';

--Temporal solo para pruebas
	--let dFecha_hoy = today;
--Temporal solo para pruebas

   LET v_periodo_tc_ini = lpad(month(dFecha_hoy),2,0) ||  '/20/' || year(dFecha_hoy) ;

--Temporal solo para pruebas
	--let v_periodo_tc_ini = v_periodo_tc_ini - 1 units month;
--let v_periodo_tc_ini = mdy('10','20','2017'); 
--Temporal solo para pruebas

   
	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'edocta_muestra.unl ';
	 LET v_sql2 = ' SELECT a.fecha_emision, a.num_credito, a.sdo_pagar, a.sdo_debe, a.interes_pago_total_tc, a.sdo_disponible, a.menos_abonos, a.mas_compras, ' ||
	                      'a.mas_disp_efectivo, a.mas_intereses, a.saldo_total, b.tasa_anual, a.interes_ven_tc, a.interes_tc, b.saldo_promedio, ' ||
                          'a.capital_tc,a.iva_interes_tc,a.capital_ven_tc,a.iva_interes_ven_tc,a.moratorios_tc,a.iva_moratorios_tc,a.saldo_corte,a.comisionxcobrar ' ||
                  ' FROM bdicred@pld_tcp:sd_encabezado2_edocta a, bdicred@pld_tcp:sd_pie_edocta b ' || 
--                  ' FROM bdicred:sd_encabezado2_edocta a, bdicred:sd_pie_edocta b ' || --Pruebas
				          ' where a.fecha_emision = b.fecha_emision ' ||
				            ' and a.fecha_emision = ''' || v_periodo_tc_ini || '''' ||
				            ' and a.num_credito = b.num_credito ' || '" >' ||trim(v_ruta)|| 'queryme.sql ';
    
    LET v_sql = trim(v_sql1) || ' ' || trim(v_sql2); 

   system trim(v_sql);

   LET v_sql = '';
	 LET v_sql = "dbaccess bdicred " ||trim(v_ruta)|| "queryme.sql";
	 system trim(v_sql);

   LET v_sql = '';
   LET v_sql = "rm "|| trim(v_ruta) ||'queryme.sql';
   SYSTEM trim(v_sql);

 

  END;
  RETURN cod_ret;

END PROCEDURE;