CREATE PROCEDURE "informix".sp_descarga_movhisedocta(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;
DEFINE v_sql        CHAR(5000);
DEFINE v_sql1       CHAR(2000);
DEFINE v_sql2       CHAR(2000);
DEFINE v_sql3       CHAR(2000);
DEFINE v_sql4       CHAR(800);
DEFINE v_sql5       CHAR(800);
DEFINE v_sql6       CHAR(10000);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_periodo_tc_ini   		  DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   		  DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   	  DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		    INTEGER;		--dias_periodo_tc
DEFINE v_cod_ret_otro			    CHAR(5);
DEFINE	vNumCredito		CHAR(20);
DEFINE	vsecuencia	SMALLINT;
DEFINE	Vnum_solpres	CHAR(20);


LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET v_sql6      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		  = 0;	--dias_periodo_tc
LET v_cod_ret_otro = "000";
LET vNumCredito = '';
LET vsecuencia	=0;
LET Vnum_solpres = '';

set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 09/09/2009
-- Autor: Faviola MartÃÂÃÂÃÂÃÂ­nez JuÃÂÃÂÃÂÃÂ¡rez
-- Nodificacion: InformaciÃÂÃÂÃÂÃÂ³n Base para la generaciÃÂÃÂÃÂÃÂ³n de los Estados de Cuenta
-- Separando los querys.
 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;            
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";
   
   --SET DEBUG FILE TO "/informix/Rebeca/sp_descarga_movhisedocta.out";
   --SET DEBUG FILE TO "/informix/jesus/cat/sp_descarga_movhisedocta.out";
   --TRACE ON;
   
   SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '039';
   --let v_ruta = '/informix/Rebeca/'; --v_ruta || 'cobranza/';
   EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
   
   LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
   LET v_periodo_tc_fin = pperiodo;	
-----------------DESCARGA  MUESTRAS-------------------------------------------------------------
 	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descargame.unl ';
	 LET v_sql2 = ' select * '||
                  ' from bdicred:sd_muestra_edocta '|| 
				  ' where  fecha_corte = '''||to_char(pperiodo,'%m-%d-%Y')|| ''' " >' ||trim(v_ruta)|| 'queryme.sql ';                                    
	 LET v_sql = v_sql1||v_sql2; 

	 system v_sql;
	 
	 LET v_sql = "dbaccess bdicred " ||trim(v_ruta)|| "queryme.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descargame.unl'||" >"||v_ruta||'descargame1.unl';
      SYSTEM v_sql; 

      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descargame.unl';
      SYSTEM v_sql; 

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargame1.unl'||" > " || trim(v_ruta||'EdoctaMuestra.unl');
      SYSTEM v_sql;

	  --COMPRIME ARCHIVO GENERADO
	  /*LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'EdoctaMuestra'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'.unl ';
      SYSTEM v_sql;*/
	  
      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descargame1.unl';
      SYSTEM v_sql; 
	  
	  let v_sql = '';
      LET v_sql = "rm "||v_ruta||'queryme.sql';
      SYSTEM v_sql;  

    LET v_sql3= "";

-----------------DESCARGA INSERTOS-------------------------------------------------------------
     LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descargain.unl ';
	 LET v_sql2 = ' select * '||
                  ' from bdicred:sd_marcaje '|| 
				  ' where  fecha_emision = '''||to_char(pperiodo,'%m-%d-%Y')|| ''' " > '||v_ruta|| 'queryin.sql ';                                    
	 
	 LET v_sql = v_sql1||v_sql2; --||v_sql3;

     system v_sql;
	 LET v_sql = "dbaccess bdicred "||v_ruta||"queryin.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descargain.unl'||" >"||v_ruta||'descargain1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descargain.unl';
      SYSTEM v_sql; 

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargain1.unl'||" > " ||v_ruta||'EdoctaInsertos.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descargain1.unl';
      SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'queryin.sql';
      
	  SYSTEM v_sql; 

	  /*LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'EdoctaInsertos'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'.unl ';
      SYSTEM v_sql;*/


-----------------DESCARGA MOVHISEDOCTA-------------------------------------------------------------
		
	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descargamov.unl ';
	 LET v_sql2 = ' select  *  from bdicred:sd_movhisedocta '|| ' " > ' ||v_ruta||'querymov.sql ';                                    
				  --' where  fecha_emision = '''||to_char(pperiodo,'%m-%d-%Y')
	 
	 LET v_sql = v_sql1||v_sql2; --||v_sql3;

     system v_sql;
	 LET v_sql = "dbaccess bdicred " ||v_ruta|| "querymov.sql";
	 system v_sql;

     LET v_sql = '';
     LET v_sql = "sed 's/|$//g' "||v_ruta||'descargamov.unl'||" >"||v_ruta||'descargamov1.unl';
     SYSTEM v_sql;

     LET v_sql = '';
     LET v_sql = "rm "||v_ruta||'descargamov.unl ';
     
     SYSTEM v_sql; 

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargamov1.unl'||" > " ||v_ruta||'EdoctaMovis.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descargamov1.unl';
      SYSTEM v_sql;
	  
	  LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'querymov.sql';
      
	  SYSTEM v_sql; 
END;
RETURN cod_ret;

END PROCEDURE;