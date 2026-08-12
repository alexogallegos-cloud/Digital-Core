CREATE PROCEDURE "informix".sp_busca_totalero(pnumcredito char(20), pfechacortec char(10), pfechacorte date ) 
  
RETURNING char(6), char(1);

DEFINE cMensaje CHAR(1);
DEFINE vdia, vmes       CHAR(2);
DEFINE cfecha_armada    CHAR(300);
DEFINE v_empresa        CHAR(3);
DEFINE cproceso, vanio, vanioant, vanio_actual  CHAR(4);
DEFINE cCod_ret, vvcCod_ret            CHAR(6);
DEFINE cfecha_dia                      CHAR(8);
DEFINE vfechafin_mesanterior           CHAR(10);
DEFINE cfecha_corte, cfecha_corte_2    CHAR(10);

DEFINE error_info  			               CHAR(80);
DEFINE cRuta                           CHAR(100);
DEFINE cCadena                         CHAR(500);

DEFINE vMesTope, i        INTEGER;

DEFINE sql_err				    INTEGER;
DEFINE isam_err				    INTEGER;
DEFINE vRegistros         INTEGER;

DEFINE dtFechaHoy		       DATE;
DEFINE dfecha_corte        DATE;
DEFINE dfecha_ant1, dfecha_ant2, dfecha_ant3, dfecha_ant4, dfecha_ant5, dfecha_ant6  DATE;
DEFINE dfecha_ant7, dfecha_ant8, dfecha_ant9, dfecha_ant10, dfecha_ant11  DATE;
DEFINE cConsulta		  	CHAR(500);   
DEFINE cSql          		CHAR(1024);
DEFINE vnumcredito      CHAR(20);
DEFINE vnumcredito2      CHAR(20);

LET cCod_ret            = '000000';
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = '';
LET cMensaje            = '0';
LET v_empresa           = '001';
LET cproceso            = '0625';
LET dtFechaHoy	        = DATE(1);
 
LET vfechafin_mesanterior = '';
LET vdia       = '';           LET vmes = '';                    LET vanio = ''; 
LET vanioant = '';
LET dfecha_corte = DATE(1);  
LET dfecha_ant1 = DATE(1); LET dfecha_ant2 = DATE(1); LET dfecha_ant3 = DATE(1); LET dfecha_ant4 = DATE(1);
LET dfecha_ant5 = DATE(1); LET dfecha_ant6 = DATE(1); LET dfecha_ant7 = DATE(1); LET dfecha_ant8 = DATE(1);
LET dfecha_ant9 = DATE(1); LET dfecha_ant10 = DATE(1); LET dfecha_ant11 = DATE(1);
LET cfecha_corte = '';         LET cfecha_corte_2 = '';
LET cRuta = '';                  
LET cfecha_dia = '';           LET cCadena    = '';              LET vMesTope   = 0;
LET i = 0;                      
LET cConsulta = "";  LET cSql = "";
LET cfecha_armada = '';  LET vnumcredito = ''; LET vnumcredito2 = '';

  --SET DEBUG FILE TO '/informix/macf/sp_busca_totalero.trc';
  --TRACE ON;

 BEGIN
        
        ON EXCEPTION SET sql_err, isam_err, error_info
          LET cCod_ret = sql_err;
          LET cMensaje = error_info;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCod_ret, cMensaje, '02')
          RETURNING vvcCod_ret;
          RETURN cCod_ret, '1';
    END EXCEPTION;
      
    LET dfecha_ant1 = pfechacorte - i UNITS MONTH;
    LET dfecha_ant2 = pfechacorte - 2 UNITS MONTH;
    LET dfecha_ant3 = pfechacorte - 3 UNITS MONTH;
    LET dfecha_ant4 = pfechacorte - 4 UNITS MONTH;
    LET dfecha_ant5 = pfechacorte - 5 UNITS MONTH;
    LET dfecha_ant6 = pfechacorte - 6 UNITS MONTH;
    LET dfecha_ant7 = pfechacorte - 7 UNITS MONTH;
    LET dfecha_ant8 = pfechacorte - 8 UNITS MONTH;
    LET dfecha_ant9 = pfechacorte - 9 UNITS MONTH;
    LET dfecha_ant10 = pfechacorte - 10 UNITS MONTH;
    LET dfecha_ant11 = pfechacorte - 11 UNITS MONTH;

    SELECT limit 1 num_credito INTO vnumcredito
      FROM bdicred:sd_movhis WHERE empresa = v_empresa
       AND (fecha_mov = pfechacorte or fecha_mov = dfecha_ant1 or fecha_mov = dfecha_ant2 
        OR  fecha_mov = dfecha_ant3 or fecha_mov = dfecha_ant4 or fecha_mov = dfecha_ant5 
        OR  fecha_mov = dfecha_ant6 or fecha_mov = dfecha_ant7 or fecha_mov = dfecha_ant8
        OR  fecha_mov = dfecha_ant9 or fecha_mov = dfecha_ant10 or fecha_mov = dfecha_ant11)
       AND num_credito = pnumcredito 
       AND codigo_fun= '605' AND codigo_ref in(2,3)
       AND reversado = 'N';

       --LET sRegistros=dbinfo("sqlca.sqlerrd2");
      IF  nvl(vnumcredito,'') <> '' then
           LET cMensaje = 'N';
       ELSE
           LET cMensaje = 'S';
       END IF;          
             
      RETURN cCod_ret, cMensaje;
 END

END PROCEDURE;