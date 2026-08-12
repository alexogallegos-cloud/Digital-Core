create procedure "informix".sprpsaldos(pempresa char(3))
returning char(20),char(4),char(3),char(4),char(20),money(14,2),
          money(14,2),money (14,2),money(14,2),money(14,2),char(50),char(60),
          char(50),char(2),char(3),char(50),char(30),char(4),
          char(40),char(30);

DEFINE vcodret     char(5);
DEFINE vsqlerr     integer;
define vcuenta char(20);
define vsucursal char(4);
define vplaza char(3);
define vproducto char(4);
define vnum_cte char(20);
define vsdo_retenido money(14,2);
define vsdo_bloq money(14,2);
define vsdo_cong money (14,2);
define vsdo_sbc money (14,2);
define vsdo_actual money(14,2);
define vnombre char(50);
define vnombrecli char(60);
define vnombreprod char(50);
define vdivisa char(2);
define vempresa char(3);
define vrazon_social char(50);
define vnombreplaza char(30);
define vregional char(4);
define vdescripcion char(40);
define vnombrereg char(30);
define vinstruccion char(500);
define vruta  char(50);

BEGIN
   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
           DROP table tempo; 
           return vcodret,'','','','',0,
                  0,0,0,0,'','', '','','','','',
                  '','','';
	end if
   end exception;


let vcuenta = "";
let vsucursal = "";
let vplaza = "";
let vproducto = "";
let vnum_cte = "";
let vsdo_retenido = 0;
let vsdo_bloq = 0;
let vsdo_sbc = 0;
let vsdo_cong = 0;
let vsdo_actual = 0;
let vnombre = "";
let vnombrecli = "";
let vproducto = "";
let vnombreprod = "";
let vdivisa = "";
let vempresa = "";
let vrazon_social = "";
let vnombreplaza = "";
let vregional = "";
let vdescripcion = "";
let vnombrereg = "";

   --set debug file to "sprpsaldos.out";
   --trace on;
   
   create table tempo
     (
    vcuenta char(20),
    vsucursal  char(4),
    vplaza char(3),
    vproducto char(4),
    vnum_cte char(20),
    vsdo_retenido  money(14,2),
    vsdo_bloq  money(14,2),
    vsdo_cong  money(14,2),
    vsdo_sbc  money(14,2),
    vsdo_actual  money(14,2),
    vnombre char(50),
    vnombrecli char(60),
    vnombreprod char(50),
    vdivisa char(2),
    vempresa char(3),
    vrazon_social char(50),
    vnombreplaza char(30),
    vregional char(30),
    vdescripcion char(40),
    vnombrereg char(30)
     );
foreach

SELECT 
    sc_maechq.cuenta, sc_maechq.sucursal, sc_maechq.plaza, sc_maechq.producto,
    sc_maechq.num_cte, sc_maechq.sdo_retenido, sc_maechq.sdo_cong, 
    sc_maechq.sdo_actual,si_sucursales.nombre,si_cliente.nombre1||" "||si_cliente.apell_paterno||" "||si_cliente.apell_materno,
    sc_producto.nombre, sc_producto.divisa,
    si_empresas.empresa, si_empresas.razon_social,
    si_plazas.nombre, si_plazas.regional,
    si_divisas.descripcion,
    si_regional.nombre
INTO 
    vcuenta,vsucursal,vplaza,vproducto,vnum_cte,vsdo_retenido,
    vsdo_cong,vsdo_actual,vnombre,vnombrecli,vnombreprod,vdivisa,
    vempresa,vrazon_social,vnombreplaza,vregional,vdescripcion,vnombrereg 
FROM
    sc_maechq sc_maechq,bdinteg:si_cliente si_cliente,
    bdinteg:si_divisas si_divisas, sc_producto sc_producto,
    si_empresas,si_sucursales si_sucursales,
    bdinteg:si_plazas si_plazas, bdinteg:si_regional si_regional
WHERE
    sc_maechq.num_cte = si_cliente.numcte AND
    sc_maechq.empresa = sc_producto.empresa AND      
    sc_maechq.producto = sc_producto.producto AND
    sc_maechq.empresa = si_empresas.empresa AND
    sc_maechq.empresa = si_sucursales.empresa AND      
    sc_maechq.sucursal = si_sucursales.sucursal AND
    sc_producto.empresa = si_divisas.empresa AND     
    sc_producto.divisa = si_divisas.divisa AND
    si_sucursales.empresa = si_plazas.empresa AND      
    si_sucursales.plaza = si_plazas.plaza  AND
    si_plazas.empresa = si_regional.empresa AND 
    si_plazas.regional = si_regional.regional  

    ORDER BY
       sc_producto.divisa ASC,
       sc_maechq.sucursal ASC,
       sc_producto.producto ASC,
       sc_maechq.cuenta ASC

    SELECT sum(monto) INTO vsdo_sbc
    FROM sc_docret  
    WHERE cuenta = vcuenta and sc_docret.transacc = "0250" 
    AND sc_docret.cancelado = "T";
    
    LET vsdo_bloq = vsdo_retenido - vsdo_sbc;

    insert into tempo  values(vcuenta,vsucursal,vplaza,vproducto,vnum_cte,vsdo_retenido,
           vsdo_bloq,vsdo_cong,vsdo_sbc,vsdo_actual,vnombre,vnombrecli,
           vnombreprod,vdivisa,vempresa,vrazon_social,vnombreplaza,
           vregional,vdescripcion,vnombrereg);
{
    return vcuenta,vsucursal,vplaza,vproducto,vnum_cte,vsdo_retenido,
           vsdo_bloq,vsdo_cong,vsdo_sbc,vsdo_actual,vnombre,vnombrecli,
           vnombreprod,vdivisa,vempresa,vrazon_social,vnombreplaza,
           vregional,vdescripcion,vnombrereg with resume;
}
end foreach

      let vruta = "/tmp/sprpsaldos.csv";
      let vruta = trim(vruta);

      let vinstruccion = 'echo " SET '||
                    'ISOLATION DIRTY READ; '||
                    'UNLOAD TO ' || vruta ||
                    'SELECT * FROM tempo;'||
                    '"' || ' > query.sql';


      let vinstruccion = vinstruccion;
      SYSTEM vinstruccion;
      LET vinstruccion = "dbaccess bdicheq query.sql";
      SYSTEM vinstruccion;
      DROP TABLE tempo;
END
     return '000','','','','',0, 0,0,0,0,'','', '','','','','', '','','';
end procedure
;