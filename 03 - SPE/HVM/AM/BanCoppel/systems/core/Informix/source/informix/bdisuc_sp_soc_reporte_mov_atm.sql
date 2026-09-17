CREATE PROCEDURE "informix".sp_soc_reporte_mov_atm(vfechadesde date, 
												   vfechaal date, 
												   vmovimiento char(15))

RETURNING CHAR(6) as codret ,CHAR(50) as mensaje ,CHAR(4) as cc,CHAR(40) as nombre,CHAR(15) as movimiento,
          DATE as fecha, CHAR(4) as proveedor, CHAR(40) as caja_gen, CHAR(8) as usuario,CHAR(45) as nombre_usuario;  

DEFINE  SQL_ERR      	 INTEGER;
DEFINE  ISAM_ERR     	 INTEGER;
DEFINE  ERROR_INFO   	 VARCHAR(80);
DEFINE  vcodret 	 	 CHAR(6);
DEFINE  mensaje 	 	 CHAR(50);
DEFINE  vcc 		 	 CHAR(4);  --sucursal
DEFINE  vnomatm   	 	 CHAR(40); --nombre del atm
DEFINE  vfecha   		 DATE;  --fecha del movimiento
DEFINE  pmovimiento 	 CHAR(15);  --tipo de movimiento: Alta, Modificacion
DEFINE  vcodigo_proveedor CHAR(4);   --codigo del proveedor
DEFINE  vnomcajagen       CHAR(40); --nombre de la caja general
DEFINE  vusuario          CHAR(8); --numero de empleado
DEFINE  vnomusuario       CHAR(45);  --nombre del empleado


LET vcodret='';
LET mensaje='';
LET vcc ='';
LET vnomatm='';
LET pmovimiento='';
LET vfecha='';
LET vcodigo_proveedor='';
LET vnomcajagen='';
LET vusuario='';
LET vnomusuario='';
                        
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje,vcc, vnomatm, pmovimiento, vfecha,  vcodigo_proveedor, vnomcajagen, vusuario, vnomusuario;
   END EXCEPTION;
  

set isolation to dirty read;



	IF vmovimiento ='TODOS' THEN
		
		foreach
			select ssb.cc_atm, sis.nombre, ssb.accion, ssb.fecha_movimiento,  ssp.cod_proveedor, ssp.descripcion, ssb.usuario, sie.nombre
				into vcc,vnomatm, pmovimiento, vfecha,  vcodigo_proveedor, vnomcajagen, vusuario, vnomusuario
			from bdisuc:"informix".ss_bitacora_atm ssb, bdinteg:"informix".si_sucursales sis, bdisuc:"informix".ss_proveedores ssp, bdinteg:"informix".si_ejecut sie
			where ssb.fecha_movimiento >=vfechadesde and ssb.fecha_movimiento <=vfechaal
			and ssb.cc_atm=sis.sucursal
			and ssb.cc_cajageneral=ssp.plaza
			and ssb.usuario= sie.ejecutivo
			order by ssb.fecha_movimiento, ssb.accion, ssb.cc_atm
			
			RETURN vcodret, mensaje,vcc, vnomatm, pmovimiento, vfecha,  vcodigo_proveedor, vnomcajagen, vusuario, vnomusuario WITH RESUME;
			
		End foreach;
		
	ELSE

		foreach
			select ssb.cc_atm, sis.nombre, ssb.accion, ssb.fecha_movimiento,  ssp.cod_proveedor, ssp.descripcion, ssb.usuario, sie.nombre
				into vcc,vnomatm, pmovimiento, vfecha,  vcodigo_proveedor, vnomcajagen, vusuario, vnomusuario
			from bdisuc:"informix".ss_bitacora_atm ssb, bdinteg:"informix".si_sucursales sis, bdisuc:"informix".ss_proveedores ssp, bdinteg:"informix".si_ejecut sie
			where ssb.fecha_movimiento >=vfechadesde and ssb.fecha_movimiento <=vfechaal
			and ssb.accion=vmovimiento
			and ssb.cc_atm=sis.sucursal
			and ssb.cc_cajageneral=ssp.plaza
			and ssb.usuario= sie.ejecutivo
			order by ssb.fecha_movimiento, ssb.accion, ssb.cc_atm
			
			RETURN vcodret, mensaje,vcc, vnomatm, pmovimiento, vfecha,  vcodigo_proveedor, vnomcajagen, vusuario, vnomusuario WITH RESUME;
		End foreach;	
		
	end if;
end;						
END PROCEDURE;