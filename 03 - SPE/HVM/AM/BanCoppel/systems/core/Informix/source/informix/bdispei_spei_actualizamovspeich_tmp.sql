CREATE PROCEDURE "informix".spei_actualizamovspeich_tmp()
returning char(5),char(100);
define vsql_err integer;
define visam_err integer;
define vcodret char (10);
define vcodret2 char (100);
define vestadoctrl char(1);
define vsql char(150);
define vmes Char(2);
define vdia Char(2);
define vanio char(4);
define vfechaarch char(8);
define vstmt char(150);
define vfecha  date;
define vclave varchar(30);
define vmedio integer;
define vusuario varchar(50);
define vusaut varchar(50);
define vuscan varchar(50);
define vhora_cap datetime year to second;
define vhoraliq datetime year to second;
define vhora_dev datetime year to second;

let vcodret='000';
let vcodret2='';
let vsql_err=0;
let visam_err=0;
let vestadoctrl='';
let vsql='';
let vmes='';
let vdia='';
let vanio='';
let vfechaarch='';
let vstmt='';
let vfecha='01011990';
let vclave='';
let vmedio=0;
let vusuario='';
let vusaut='';
let vuscan='';
let vhora_cap='';
let vhoraliq='';
let vhora_dev='';


Begin
on exception set vsql_err, visam_err
	IF vsql_err<>0 then
		let vcodret=vsql_err;
		let vcodret2=visam_err;
		return  vcodret,vcodret2;
	End if;
end exception;
--SET debug file to '/resplogifx/conciliachq/pasemovspeichact.out';
--trace on;
set isolation to dirty read;
set lock mode to wait 3;
	   
	   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames
                WHERE partnum > 0 AND tabname = 'tblhistpagoactuali_temp') THEN
        DROP TABLE bdispei:"informix".tblhistpagoactuali_temp;
       END IF;
	   
	   create raw table "informix".tblhistpagoactuali_temp 
       (
		dtfechacaptura date,
		vchrclaverastreo varchar(30),
		medioentrega integer,
		usuario varchar(50),
		usuario_aut varchar(50),
		usuario_can varchar(50),
		hora_liq  datetime year to second,
		hora_dev  datetime year to second,
		hora_cap  datetime year to second
		)extent size 2250 next size 225 lock mode row;
		create index idx_tblhistpago_tempact on "informix".tblhistpagoactuali_temp(dtfechacaptura,vchrclaverastreo) using btree;
  
		let vsql='';
		let vsql='echo "load from /resplogifx/conciliachq/DetSPEICH20150807.txt insert into tblhistpagoactuali_temp;" > /resplogifx/conciliachq/query.sql';
		system vsql;
		let vstmt='';
		let vstmt='dbaccess bdispei /resplogifx/conciliachq/query.sql';
		system vstmt;
  
		FOREACH	WITH HOLD
			SELECT dtfechacaptura,vchrclaverastreo,medioentrega,usuario,usuario_aut,usuario_can,hora_cap,hora_liq,hora_dev
			INTO vfecha,vclave,vmedio,vusuario,vusaut,vuscan,vhora_cap,vhoraliq,vhora_dev
			from tblhistpagoactuali_temp
			
				UPDATE tblhistpago SET  medioentrega=vmedio, usuario=vusuario, usuario_aut=vusaut,usuario_can=vuscan,
				hora_liq=vhoraliq, hora_dev=vhora_dev,hora_cap=vhora_cap
				WHERE dtfechacaptura=dtfechacaptura
				AND vchrclaverastreo=vclave;
		END FOREACH	

		return vcodret, 'Exitoso';	

END;

END PROCEDURE;