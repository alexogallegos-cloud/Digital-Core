create procedure "informix".valsuc(pempresa char(3),
                            psucursal char(4),poper char(1))

                            returning char(5),char(3),char(40),char(40),char(40),
                                      char(14),char(14),char(40),char(40),char(3),
                                      char(3),char(2),char(3),char(6);

   define vcodret     	char(5);
   define vsucursal 	char(4);   
   define vexiste 	char(2);
   define vsqlerr 	integer;
   define vempresa 	char(3);
   define vnombre	char(40);
   define vdirecion1	char(40);
   define vdireccion2	char(40);
   define vtelefono1	char(14);
   define vtelefono2	char(14);
   define vgerente	char(40);
   define vsubger	char(40);
   define vplaza	char(3);
   define vpais		char(3);
   define vestado	char(2);
   define vciudad	char(3);
   define vcodigo	char(6);      


   let vcodret = "000";
   let vsqlerr = 0;   
   let vsucursal = "";
   let vempresa = "";
   let vnombre = "";
   let vdirecion1 = "";
   let vdireccion2 = "";
   let vtelefono1 = "";
   let vtelefono2 = "";
   let vgerente = "";
   let vsubger = "";
   let vplaza = "";
   let vpais = "";
   let vestado = "";
   let vciudad = "";
   let vcodigo = "";


   begin

   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo;
 
      end if;
   end exception;

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/cesar/valsuc.out";
--trace on;


IF poper = 1 THEN
   select tpo_sucursal into vexiste
   from si_sucursales where sucursal = psucursal;

   IF vexiste is null THEN
      let vcodret = "102";
      return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo;
   ELSE
      IF vexiste <> "99" THEN     
         let vcodret = "98";
         return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo;
 
      END IF 
   END IF
   
   IF vexiste = "99" THEN
      SELECT {+INDEX(bdinteg:si_localidades idx_silocalidades)}
             suc.empresa,suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2,ptf.tel1,ptf.tel2,suc.gerente,suc.subger,suc.plaza,ptf.cve_pais,
             ptf.cve_estado,ptf.cve_ciudad,ptf.id_ptf
      INSERT INTO vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo
      FROM si_ptf ptf
      JOIN si_sucursales suc ON ptf.id_ptf = suc.sucursal  AND ptf.tipo = suc.tipo      
      JOIN si_localidades loc ON (ptf.cve_estado = loc.cve_estado AND ptf.cve_localidad = loc.cve_localidad_cnbv AND ptf.cve_col = loc.cve_col)
      WHERE sucursal = psucursal
      AND ptf.tipo <> 'C';
      /*SELECT empresa,nombre,direccion1,direccion2,telefono1,telefono2,gerente,subger,plaza,pais,
             estado,ciudad,sucursal
      INSERT INTO vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo
      FROM si_sucursales      
      WHERE sucursal = psucursal;*/
      return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo;
   end if;

ELSE

   IF poper = 0 THEN
       IF EXISTS (SELECT sucursal from si_sucursales WHERE sucursal = psucursal) THEN
          UPDATE si_sucursales SET tpo_sucursal = 'S'  WHERE sucursal = psucursal;
          return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo; 
       ELSE
          let vcodret = '102';
          return vcodret,vempresa,vnombre,vdirecion1,vdireccion2,vtelefono1,vtelefono2,vgerente,vsubger,vplaza,vpais,
                  vestado,vciudad,vcodigo;

       END IF;

   END IF
END IF

end
end procedure;