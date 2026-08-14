CREATE PROCEDURE "informix".ugenera_layoutedocuenta_comple(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;

DEFINE v_sql        CHAR(5000);
DEFINE v_sql1       CHAR(1000);
DEFINE v_sql2       CHAR(1000);
DEFINE v_sql3       CHAR(1000);
DEFINE v_sql4       CHAR(800);
DEFINE v_sql5       CHAR(800);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;

DEFINE sPaso       SMALLINT;

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET sPaso       = 0;
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;

-- SET DEBUG FILE TO "/pisax/leo/situacionesples/ugenera_layoutedocuenta.out";
-- TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 09/09/2009
--Autor: Roque Enrique Solis Campaña
-- Nodificacion: Se modifico la forma de armar la tabla temporal  sd_paso_cred
--                     Separando los querys.
 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            SELECT COUNT(tabid)
              INTO sPaso
              FROM systables 
             WHERE tabname= 'sd_paso_cred';

            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_cred;
            END IF;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

	-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';

SELECT COUNT(tabid)
  INTO sPaso
  FROM systables 
 WHERE tabname= 'sd_paso_cred';

IF NVL(sPaso,0) > 0 THEN
    DROP TABLE "informix".sd_paso_cred;
END IF;

    CREATE TABLE "informix".sd_paso_cred 
    (
        num_credito CHAR(20)
     );

select numcred 
 from bdisitesp:se_ctessitespcred a,
      bdisitesp:se_situacionaccion b
where a.situacion = b.situacion
  and a.causa     = b.causa
  and idaccion = 5
  and instruccion = '0'
union all
select num_credito
from bdicred:sd_maecred 
where empresa  ='001'
and numcte in (
select numcte
 from bdisitesp:se_ctessitespcte a,
      bdisitesp:se_situacionaccion b
where a.situacion = b.situacion
  and a.causa     = b.causa
  and idaccion = 5
  and instruccion = '0')
group by 1
into temp paso_sitesp with no log;

insert into "informix".sd_paso_cred
select * from paso_sitesp group by 1;


create unique index inx_sd_paso_cred on "informix".sd_paso_cred(num_credito);
UPDATE STATISTICS medium FOR TABLE "informix".sd_paso_cred;    
                       
	-----------------MENSAJES---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
         LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( replace ( replace( si_paga, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta a '||
            ' WHERE a.fecha_emision ='''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred) '||   
            ' union all '||+
            ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( b.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( replace ( replace( si_paga, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta_2010 b '||
            ' WHERE b.fecha_emision ='''||pperiodo||''' AND b.num_credito not in (select num_credito from "informix".sd_paso_cred) '||   
            ' ORDER BY num_credito,secuencia,nlinea"'||
            ' > query.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'Archivo500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;


	-----------------PIE DE PAGINA---------------------------------------------------
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( tasa_anual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( cat, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( tasa_mora,0),'||
            ' nvl ( tasa_mensual_mora,0) FROM sd_pie_edocta a '||
            ' WHERE fecha_emision ='''||pperiodo||''' AND a.num_credito not in (select num_credito from "informix".sd_paso_cred)  "' ||
            ' > query.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'Archivo600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

  END;
  RETURN cod_ret;

END PROCEDURE;