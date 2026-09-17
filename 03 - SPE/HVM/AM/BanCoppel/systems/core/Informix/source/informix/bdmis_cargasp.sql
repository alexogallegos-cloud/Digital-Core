CREATE PROCEDURE "informix".cargasp()

DEFINE vnum_sucursal    CHAR    (4)   ;
DEFINE vtipo_suc        VARCHAR (1)   ;
DEFINE vsql             CHAR    (200)   ;

-- set debug file to 'CCO_qeq.out';
--trace on;

create table "informix".tpasotipsuc 
  (         
			num_sucursal  char(4),
			tipo_suc varchar(1)

  ) extent size 32 next size 32 lock mode page;
  

let vnum_sucursal='';
let vtipo_suc ='';
--load from carga.unl insert into tpasotipsuc;

			let vsql=  'echo "load from carga.unl insert into tpasotipsuc;">cargadtiposuc.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdmis cargadtiposuc.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  cargadtiposuc.sql';
			system vsql;

FOREACH 
		select tp.num_sucursal,tp.tipo_suc 
		into vnum_sucursal,vtipo_suc
		from bdmis:mi_sucursalesinfo si,tpasotipsuc tp
		where tp.num_sucursal = si.num_sucursal
		

		update bdmis:mi_sucursalesinfo Set tipo_suc = vtipo_suc where num_sucursal = vnum_sucursal;

END FOREACH;

drop table "informix".tpasotipsuc;

end procedure 
;