CREATE PROCEDURE "informix".instcteint(
         pnumcte               char(20),
         pstatus_cte           char(2),
         psucursal             char(4),
         pejecutivo            char(8),
         ptpo_persona          char(2),
         ptipo_cliente         char(1),
         papell_paterno        char(15),
         papell_materno        char(15),
         pnombre1              char(15),
         pnombre2              char(15),
         prazon_social         char(40),
         prfc                  char(13),
         psector               char(2),
         psegmento             char(3),
         pactividad_princ      char(3),
         pgrupo                char(3),
         psubgrupo             char(3),
         presidencia           char(1),
         pfecha_alta           date)

   DEFINE wnumcte    CHAR(20);
   DEFINE wnrows     SMALLINT;

   SELECT
      numcte
   INTO
      wnumcte
   FROM
      bdinteg:si_cliente
   WHERE
      numcte = pnumcte;

   LET wnrows = dbinfo("sqlca.sqlerrd2");
   IF (wnrows = 0) THEN
      INSERT INTO
         bdinteg:si_cliente
      VALUES
         (
         pnumcte         ,
         pstatus_cte     ,
         psucursal       ,
         pejecutivo      ,
         ptpo_persona    ,
         ptipo_cliente   ,
         papell_paterno  ,
         papell_materno  ,
         pnombre1        ,
         pnombre2        ,
         prazon_social   ,
         prfc            ,
         psector         ,
         psegmento       ,
         pactividad_princ,
         pgrupo   ,
         psubgrupo,
         presidencia,
         pfecha_alta);
   END IF;

END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".inscatalog(
              pempresa              char(3),                     
              pccmayor              char(4),                     
              pccsub                char(2),                     
              pccsubsub             char(2),                     
              pccssubsub            char(2),                     
              pccsssubsub           char(2),                     
              psector               char(2),                     
              pnombre               char(50),                    
              pnaturaleza_cta       char(1),                     
              ptipo_cuenta          char(1),                     
              psectoriza_cta        char(1),                     
              pflujo_efectivo       char(1),                     
              pcta_restringida      char(1),                     
              pauxiliar             char(1),                     
              pregion_suc           char(1),                     
              pmoneda               char(1),                     
              prubro1               char(3),                     
              prubro2               char(3),                     
              prubro3               char(3),                     
              pcancelacion          char(1),                     
              pfecha_cancelacion    date   )

   DEFINE nrows    SMALLINT;
    

   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      bdinteg:si_catalog
   WHERE
      empresa = pempresa
   AND ccmayor = pccmayor
   AND ccsub = pccsub
   AND ccsubsub = pccsubsub
   AND ccssubsub = pccssubsub
   AND ccsssubsub = ccsssubsub
   AND sector = psector;

   IF(nrows = 0) THEN
      INSERT INTO
         bdinteg:si_catalog
      VALUES (
              pempresa,                     
              pccmayor,                     
              pccsub  ,                     
              pccsubsub,                     
              pccssubsub,                     
              pccsssubsub,                     
              psector    ,                     
              pnombre    ,                    
              pnaturaleza_cta,                     
              ptipo_cuenta   ,                     
              psectoriza_cta ,                     
              pflujo_efectivo,                     
              pcta_restringida,                     
              pauxiliar       ,                     
              pregion_suc     ,                     
              pmoneda         ,                     
              prubro1         ,                     
              prubro2         ,                     
              prubro3         ,                     
              pcancelacion    ,                     
              pfecha_cancelacion  );
   END IF;
      

END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".tabla_dual ()
define existe int;

let existe = 0;
select count(*) into existe from systables
where tabname = "dual";

if (existe = 0)
then 
create table "informix".dual
  (
    dual char(1)
  )  ;

insert into dual values("X");
end if;

end procedure;