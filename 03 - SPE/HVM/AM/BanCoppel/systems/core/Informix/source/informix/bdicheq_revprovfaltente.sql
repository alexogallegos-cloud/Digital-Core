create procedure "informix".revprovfaltente()

define vempresa char(3);
define vcuenta  char(20);
define vfech_alt date;
define vcancelad char(1);
define vtran char(4);

 	foreach select  empresa,cuenta,fech_alt,cancelad,transacc
		  into vempresa, vcuenta,vfech_alt, vcancelad, vtran
		  from sc_movhistmp
		 where transacc in ("3276")


		update sc_movhis set cancelad ="S"
		 where empresa = vempresa
		   and cuenta = vcuenta
		   and fech_alt  ="01/02/2008"
		   and cancelad <> "S"
		   and transacc = vtran;


	end foreach

{	update sc_movhis set cancelad ="S"
	 where empresa ="001"
	   and fech_alt ="01/02/2008"
	   and cancelad <> "S"
	   and transacc ="3381";}


end procedure
;