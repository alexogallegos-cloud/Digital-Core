CREATE PROCEDURE "informix".sp_reportemensual_saldocierre() 

returning char(3), char(20);

define vfechainicial char(10);
define vfechafinal char(10);
define vsql char(3000);
define fecha char (6); 
define v_mensaje char (40);
define v_retorno char(3);


 
	let vfechainicial='';
	let vfechafinal='';
	
	
	set isolation to dirty read; 
	SELECT pri_dia_mes,ult_dia_mes
	into vfechainicial, vfechafinal
	FROM bdinteg:si_fechas;
	
	let fecha = SUBSTR(vfechafinal,1,2) ||SUBSTR(vfechafinal,7,4);


	let vsql = 'echo "Fecha|Sucursal|Saldo Total" > /resplogifx/conciliachq/sdo_cierre_'||fecha||'.txt';
	system vsql;
	let vsql=  'echo "UNLOAD TO /resplogifx/conciliachq/query_consulta.txt select fecha,sucursal,saldo_total from bdisuc:ss_saldossuc where fecha between '''||vfechainicial||''' and '''||vfechafinal||''' and sucursal < 2000 order by fecha,sucursal;"> /resplogifx/conciliachq/sdo_cierre.sql'; 
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess bdisuc /resplogifx/conciliachq/sdo_cierre.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/conciliachq/sdo_cierre.sql';
	system vsql;
	let vsql ='';	
	let vsql = "sed 's/|$//g' /resplogifx/conciliachq/query_consulta.txt >> /resplogifx/conciliachq/sdo_cierre_"||fecha||".txt";
	system vsql;
	let vsql ='rm  /resplogifx/conciliachq/query_consulta.txt';
	system vsql;
	let vsql ='';
	
	let v_retorno='000';
	let v_mensaje ='PROCESO EXITOSO';
	
	return v_retorno, v_mensaje with resume;
		
END PROCEDURE;