create procedure "informix".sp_burofisicas_cortos_resp()
       returning char(5);

 define vfecha_reporte char(8);

   define vcodret                   char(5);
   define vsql                      char(1500);
   define vsql2                    CHAR(2204);
   define iSqlErr                   integer;
   define vfecha_hoy     date;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vflag                     char(1);
   define cnomarchivo               char(100);

BEGIN

   on exception set iSqlErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   LET vsql = '';
   LET vsql2 = '';
   let vdia  = '';
   let vmes  = '';
   let vanio = '';


--SET DEBUG FILE TO "burofisicas_respaldo.out";
--TRACE ON; 


/*
IF WEEKDAY (today) = 1 THEN
 LET vfecha_hoy = today;
ELIF WEEKDAY (today) = 2 THEN
 LET vfecha_hoy = today-1;
END IF;
*/

 LET vfecha_hoy = today;
   
   let vanio = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vanio;

SELECT valor 
  INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 130;

-- Extracción br_burofisicas_cortos

IF vflag = 0 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_cortos_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_cortos'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '1'
  WHERE cod_param = 130;
 commit;
 
 LET vflag = '1';


END IF;

 --EXTRACCIÓN BR_BUROFISICAS_DESCRIBE
IF vflag = 1 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_cortos_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe_cortos'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos.sql";
  SYSTEM vsql;  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 130;
 commit;
 
 LET vflag = '2';
 
END IF;

 --EXTRACCIÓN BR_BUROFISICAS_CORTOS_CNR

IF vflag = 2 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_cortos_cnr_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_cortos_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cortos_cnr.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '3'
  WHERE cod_param = 130;
 commit;
 
 LET vflag = '3';


END IF;


--EXTRACCIÓN BR_BUROFISICAS_DESCRIBE_CORTOS_CNR

IF vflag = 3 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_cortos_cnr_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe_cortos_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cortos_cnr.sql";
  SYSTEM vsql;  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '0'
  WHERE cod_param = 130;
 commit;
 
END IF;

  return vcodret;


END;
end procedure;