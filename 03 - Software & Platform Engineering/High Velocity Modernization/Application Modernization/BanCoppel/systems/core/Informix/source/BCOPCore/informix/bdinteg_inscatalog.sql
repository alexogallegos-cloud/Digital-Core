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