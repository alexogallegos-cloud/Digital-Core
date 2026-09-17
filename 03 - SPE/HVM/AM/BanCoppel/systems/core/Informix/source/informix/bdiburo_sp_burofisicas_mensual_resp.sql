create procedure "informix".sp_burofisicas_mensual_resp()
       returning char(5);

 define vfecha_reporte char(8);

   define vcodret                   char(5);
   define vsql                      char(1500);
   define vsql2                     char(2204);
   define iSqlErr                   integer;
   define vfecha_hoy                date;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vflag                     char(1);
   define vflag_sql                 char(1);
   define vflag_filetmp             char(1);
   define vflag_file                char(1);
   define vflag_zip                 char(1);
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
let cnomarchivo = '';


--SET DEBUG FILE TO "burofisicas_respaldo.out";
--TRACE ON; 

 select pri_dia_mes - 1
      into vfecha_hoy
      from bdinteg:si_fechas
     where empresa = '001';

   
   let vanio = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vanio;


--REVOLVENTES
 --EXTRACCIÓN BR_BUROFISICAS

SELECT valor 
  INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 129;

IF vflag = 0 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '1'
  WHERE cod_param = 129;
 commit;

LET vflag = '1';

END IF;

 --EXTRACCIÓN BR_BUROFISICAS_DESCRIBE
IF vflag = 1 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql";
  SYSTEM vsql;
 
 begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 129;
 commit;
 
LET vflag = '2';

END IF;



 --EXTRACCIÓN BR_BUROFISICAS_CONCILIA
IF vflag = 2 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_concilia_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_concilia'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '3'
  WHERE cod_param = 129;
 commit; 

LET vflag = '3';

END IF;


--NO REVOLVENTES
 --EXTRACCIÓN BR_BUROFISICAS_CNR

IF vflag = 3 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_cnr_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '4'
  WHERE cod_param = 129;
 commit; 

LET vflag = '4';

END IF;


 --EXTRACCIÓN BR_BUROFISICAS_DESCRIBE_CNR
IF vflag = 4 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo ='/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_cnr_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '5'
  WHERE cod_param = 129;
 commit;
 
LET vflag = '5';

END IF;

 --EXTRACCIÓN BR_BUROFISICAS_CONCILIA_CNR
IF vflag = 5 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_concilia_cnr_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_concilia_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql";
  SYSTEM vsql;  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '0'
  WHERE cod_param = 129;
 commit;
 
END IF;

  return vcodret;

END;
end procedure;