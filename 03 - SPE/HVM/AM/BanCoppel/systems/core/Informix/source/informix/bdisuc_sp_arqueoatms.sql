CREATE PROCEDURE "informix".sp_arqueoatms( ptipo smallint,psucursal  CHAR(4),
                                   pfechames integer, pfechadia integer,pfechaano integer)
--execute PROCEDURE sp_arqueoatms(0,'002',04,02,2014);

--drop procedure sp_arqueoatms (  smallint,  CHAR(4),  integer,  integer, integer)

RETURNING CHAR(5) as rvcodret,
char(4) as psucursal,
char(100) as   vatmnombre,
char(100)   as vcg,
money(14,2) as vsaldanterior,
money(14,2) as ventradadia,
money(14,2) as vsalidadia,
money(14,2) as vsaldofindia,
integer     as vden1000,
integer     as vden500,
integer     as vden200,
integer     as vden100,
integer     as vden50,
integer     as vmont1000,
integer     as vmont500,
integer     as vmont200,
integer     as vmont100,
integer     as vmont50,
date        as vfecha ;

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vnumatm          CHAR(4);
DEFINE vnombreatm       CHAR(40);
define vcg char(100);

define psucur2  char(100);
define vfecha		char(8)		;

define vcc  char(4);
define vatmnombre char(100);
--define vplaza char(4);
define vsaldanterior money(14,2);
define ventradadia money(14,2);
define vsalidadia money(14,2);
define vsaldofindia money(14,2);
define vden1000  integer;
define vden500	 integer;
define vden200   integer;
define vden100   integer;
define vden50    integer;
define vmont1000 integer;
define vmont500  integer;
define vmont200  integer;
define vmont100  integer;
define vmont50   integer;
define rvcodret char(5);

let vfecha = '01/01/1900';
LET vcodret    = "000";
LET vnumatm    = "";
LET vnombreatm = "";

let rvcodret ="000";
let vcc  ='';
let vatmnombre ='';
let vcg ='';
let vsaldanterior ='0.00';
let ventradadia ='0.00';
let vsalidadia ='0.00';
let vsaldofindia  ='0.00';
let vden1000 =0;
let vden500	 =0;
let vden200  =0;
let vden100  =0;
let vden50  =0;
let vmont1000  =0;
let vmont500  =0;
let vmont200  =0;
let vmont100  =0;
let vmont50  =0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN rvcodret,vcc,vatmnombre,vcg, vsaldanterior,ventradadia,vsalidadia,vsaldofindia,vden1000,vden500,vden200,vden100,vden50,vmont1000,vmont500,vmont200,vmont100,vmont50,vfecha;

   END IF;
END EXCEPTION;

--SET debug file to "sp_arqueoatms.out";
--trace on;
let psucur2=psucursal;

let vfecha = lpad(pfechames,2,'0') ||  lpad(pfechadia,2,'0') ||pfechaano  ;
/*
    IF vfecha = '' or  psucursal = '0' or psucursal = '' then
          LET vcodret = "110";
    END IF;
	*/


if ptipo = 0 then
  FOREACH
	SELECT trim(suc.sucursal),trim(suc.nombre),trim(cg.descripcion)
	into  vcc,vatmnombre,vcg
	FROM bdinteg:si_sucursales suc, bdinteg:si_plazas_cajagen cg
	where tpo_sucursal ='C' and cg.codigo_plaza= trim(psucursal) and suc.plaza_cajagen= trim(psucursal)
	and trim(suc.sucursal) in (select trim(cc) from bdisuc:ss_relacionccid)
	--order by 1

	select cv.totalant,
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0037','0039') and fecha_operacion =vfecha and sucursal = vcc ) as entradeldia,
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0038','0040') and fecha_operacion =vfecha and sucursal = vcc ) as salidadeldia,
	 (((select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0037','0039') and fecha_operacion =vfecha and sucursal = vcc ) + cv.totalant) -
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0038','0040') and fecha_operacion =vfecha and sucursal = vcc ) )  as saldofindia,
	'0'as billete1000, nvl(cv.billete500act,0)  as billete500,nvl(cv.billete200act,0)  as billete200,nvl(cv.billete100act,0) as billete100,
	nvl(cv.billete50act,0) as billete50,'0'as billete1000act ,nvl(cv.billete500act * 500,0) as billete500act,nvl(cv.billete200act * 200,0) as billete200act,nvl(cv.billete100act * 100,0) as billete100act,nvl(cv.billete50act * 50,0) as billete50act
	into vsaldanterior,ventradadia,vsalidadia,vsaldofindia,vden1000,vden500,vden200,vden100,vden50,vmont1000,vmont500,vmont200,vmont100,vmont50
	from bdisuc:ss_corteadminview cv where trim (atm)= vcc and  fecha =vfecha;


	return rvcodret,vcc,vatmnombre,vcg, nvl(vsaldanterior,0),nvl(ventradadia,0),nvl(vsalidadia,0),nvl(vsaldofindia,0),nvl(vden1000,0),nvl(vden500,0),nvl(vden200,0),nvl(vden100,0),nvl(vden50,0),nvl(vmont1000,0),nvl(vmont500,0),nvl(vmont200,0),nvl(vmont100,0),nvl(vmont50,0),vfecha WITH RESUME;

  end foreach;

ELIF ptipo= 1 THEN

	SELECT trim(suc.sucursal),trim(suc.nombre),trim(cg.descripcion)
	into  vcc,vatmnombre,vcg
	FROM bdinteg:si_sucursales suc, bdinteg:si_plazas_cajagen cg
	where tpo_sucursal ='C' and sucursal= trim(psucursal)
    and trim(suc.plaza_cajagen)=trim (cg.codigo_plaza) 
	and trim(suc.sucursal) in (select trim(cc) from bdisuc:ss_relacionccid);


  
	select cv.totalant,
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0037','0039') and fecha_operacion =vfecha and sucursal = vcc ) as entradeldia,
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0038','0040') and fecha_operacion =vfecha and sucursal = vcc ) as salidadeldia,
	 (((select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0037','0039') and fecha_operacion =vfecha and sucursal = vcc ) + cv.totalant) -
	(select nvl(sum (monto),0) from ss_operaciones    where  cod_trans in ('0038','0040') and fecha_operacion =vfecha and sucursal = vcc ) )  as saldofindia,
	'0'as billete1000, nvl(cv.billete500act,0)  as billete500,nvl(cv.billete200act,0)  as billete200,nvl(cv.billete100act,0) as billete100,
	nvl(cv.billete50act,0) as billete50,'0'as billete1000act ,nvl(cv.billete500act * 500,0) as billete500act,nvl(cv.billete200act * 200,0) as billete200act,nvl(cv.billete100act * 100,0) as billete100act,nvl(cv.billete50act * 50,0) as billete50act
	into vsaldanterior,ventradadia,vsalidadia,vsaldofindia,vden1000,vden500,vden200,vden100,vden50,vmont1000,vmont500,vmont200,vmont100,vmont50
	from bdisuc:ss_corteadminview cv where trim (atm)= trim(psucursal) and  fecha =vfecha;


	return rvcodret,psucursal,vatmnombre,vcg, nvl(vsaldanterior,0),nvl(ventradadia,0),nvl(vsalidadia,0),nvl(vsaldofindia,0),nvl(vden1000,0),nvl(vden500,0),nvl(vden200,0),nvl(vden100,0),nvl(vden50,0),nvl(vmont1000,0),nvl(vmont500,0),nvl(vmont200,0),nvl(vmont100,0),nvl(vmont50,0),vfecha WITH RESUME;


end if;


END;
END PROCEDURE;