CREATE PROCEDURE "informix".sp_reporte_tarjetas_pba()
RETURNING 	CHAR (06) as cod_ret,
			CHAR (80) AS mensaje;
			
--variables de retorno
	DEFINE cod_ret CHAR(06);
	DEFINE mensaje CHAR(80);
	
 --variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);			
	DEFINE	vpaso			INTEGER;	
	
--variables de proceso

	DEFINE vcont 			INTEGER;
	DEFINE vmax				datetime year to fraction(3)  ;
	
	
	--variables para datos
	                                                          
	DEFINE vbin              	char(6)                       ;
	DEFINE vcodstatustarjeta 	varchar(3)                    ;
	DEFINE vcodstatusasignada	varchar(3)                    ;
	DEFINE vtipo             	char(1)                       ;
	DEFINE vfechaexp         	varchar(4)                    ;
	DEFINE vproducto         	char(1)                       ;
	DEFINE vmarca            	char(1)                       ;
	DEFINE vtitular          	char(1)                       ;
	DEFINE vcantidad         	INTEGER                       ;
	DEFINE vfecha_ejecucion  	date                          ;
	DEFINE vfecha_exp			char(04)					  ;
	DEFINE vfecha_exp_min		char(04)					  ;
	DEFINE vfecha_exp_max		char(04)					  ;
	
--SET DEBUG FILE TO "/informix/frg/Rpts_Productos/sp_reporte_tarjetas.out";
--TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = SQL_ERR || ' ' || ISAM_ERR ||' en paso '|| vpaso ||' '|| ERROR_INFO ;
      RETURN cod_ret, mensaje;
	END EXCEPTION;

	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	
	let vcont  = 0;
	
	set isolation to dirty read;
	
	SELECT {+INDEX(intercard:tarjeta idx_tarjeta2)} min(fechaexp),max(fechaexp)
	INTO vfecha_exp_min, vfecha_exp_max
	FROM intercard:tarjeta;	
	 
	let vpaso = 1;
	let vfecha_exp = lpad(substr( year(date(current)) ,3,2) ,2,'0' ) || lpad(month(date(current)),2,'0') ; 
	SELECT {+INDEX(reporte_tarjetas idx_reporte_tarjetas)} MAX(fecha_ejecucion) INTO vmax FROM reporte_tarjetas;
	
	
	IF vmax IS NOT NULL THEN
		
	 LET vfecha_exp_min = vfecha_exp;
	
	END IF
	
		foreach cursor1 WITH HOLD 
		
		for
		
				select distinct (b.bin),

					   t.codstatustarjeta,

					   t.codstatusasignada,

					  (CASE WHEN tipotar.chip = 'F' THEN 'B'

							WHEN tipotar.chip = 'V' THEN 'C'

							END) as tipo,          

					   t.fechaexp,

					   b.creditodebito as producto,      

					  (CASE WHEN SUBSTR(b.bin,1,1) = 4 THEN 'V'

							WHEN SUBSTR(b.bin,1,1) = 5 THEN 'M' END) as marca,

					  (CASE WHEN t.titular = 'T' THEN 'T'

							WHEN t.titular = 'A' THEN 'A'

							ELSE 'N' END) as titular,      

					   count(*) as cantidad,

					   date(current) as fecha_ejecucion
					   	INTO 	vbin              
							   , vcodstatustarjeta 
							   , vcodstatusasignada
							   , vtipo             
							   , vfechaexp         
							   , vproducto         							     
							   , vmarca            
							   , vtitular          
							   , vcantidad 
							   , vfecha_ejecucion
					   
							from intercard:bines as b, intercard:tarjeta as t, intercard:tipotarjeta as tipotar, intercard:lote as lt

							where b.bin = SUBSTR(t.numtarjeta,1,6)

							and t.fechaexp BETWEEN vfecha_exp_min AND vfecha_exp_max 

							  and tipotar.clave_tipotarjeta=lt.clave_tipotarjeta   

							  and t.numerolote=lt.numerolote

						group by 1,2,3,4,5,6,7,8

						order by 1,2,3,4,5,6,7,8
						
						
				     let vmarca = vmarca;
					 
				if vcont= 0 THEN
					
					BEGIN WORK;
					
				end IF
		
				let vpaso = 3;
				INSERT INTO reporte_tarjetas (bin, codstatustarjeta, codstatusasignada, tipo, fechaexp, producto, marca, titular, cantidad, fecha_ejecucion)
				VALUES( vbin, vcodstatustarjeta, vcodstatusasignada, vtipo, vfechaexp, vproducto, vmarca, vtitular, vcantidad, vfecha_ejecucion);

				let vcont = vcont + 1;      
		
				if vcont= 1000 THEN
					
					let vcont=0;            
					COMMIT WORK;
					
					
				end IF		
				
		
			end foreach;

			if vcont <> 0 THEN
					
					COMMIT WORK;
					
			end IF			
		
	
	
	  RETURN cod_ret, mensaje;	
END
END PROCEDURE;