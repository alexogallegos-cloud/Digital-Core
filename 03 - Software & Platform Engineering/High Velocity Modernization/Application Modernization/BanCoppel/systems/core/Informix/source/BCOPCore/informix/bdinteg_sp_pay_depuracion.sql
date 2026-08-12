CREATE PROCEDURE "informix".sp_pay_depuracion()
RETURNING VARCHAR(10), VARCHAR(255);


	DEFINE vcod_ret         		VARCHAR(10); 
	DEFINE sql_err          		INTEGER;
	DEFINE isam_err         		INTEGER;
	DEFINE error_info       		CHAR(40);
	
	DEFINE vdia_cte					INTEGER;
	DEFINE vdif_cte					INTEGER;
	DEFINE vfec_depuracion_cte		DATE;
	DEFINE vfecha_hoy				DATE;
	
	DEFINE vdia_dir					INTEGER;
	DEFINE vdif_dir					INTEGER;
	DEFINE vfec_depuracion_dir		DATE;

	DEFINE vdia_cta					INTEGER;
	DEFINE vdif_cta					INTEGER;
	DEFINE vfec_depuracion_cta		DATE;

	DEFINE vdia_tar					INTEGER;
	DEFINE vdif_tar					INTEGER;
	DEFINE vfec_depuracion_tar 		DATE;
	
	
	--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' ' ||error_info;
			
           END IF;
       END EXCEPTION;
	   
	--set debug file to "/tmp/sp_pay_depuracion";
	--TRACE ON;	   
	 
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	
	
	LET vfecha_hoy = '';
	LET vdia_cte = 0;				
	LET vdif_cte = 0;				
	LET vfec_depuracion_cte = '';	
				
	
	LET vdia_dir = 0;				
	LET vdif_dir = 0;				
	LET vfec_depuracion_dir = '';	
	
	LET vdia_cta = 0;				
	LET vdif_cta = 0;				
	LET vfec_depuracion_cta = '';
	
	LET vdia_tar = 0;
	LET vdif_tar = 0;
	LET vfec_depuracion_tar = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	   
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cte, vdia_cte
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 1;
		
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_dir, vdia_dir
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 2;

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cta, vdia_cta
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 3;	

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_tar, vdia_tar
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 4;	

	LET vfecha_hoy = TODAY;
	
	LET vdif_cte = vfecha_hoy - vfec_depuracion_cte;
	LET vdif_dir = vfecha_hoy - vfec_depuracion_dir;
	LET vdif_cta = vfecha_hoy - vfec_depuracion_cta;
	LET vdif_tar = vfecha_hoy - vfec_depuracion_tar;
	
	-- Depuracion de Cliente
	IF( vdif_cte = vdia_cte ) THEN
	
		TRUNCATE bdinteg:info_clientes_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 1;
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion 
		   SET ind_dep = '0'
		 WHERE id_tabla = 1;
	END IF			

	-- Depuracion de Direccion
	IF(vdif_dir = vdia_dir ) THEN
	
		TRUNCATE bdinteg:info_direccion_pyt;
	
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 2;
				
	ELSE 
			UPDATE bdinteg:si_pyt_depuracion 
			  SET ind_dep = '0'
			WHERE id_tabla = 2;
	END IF	
	
	--Depuracion de Cuenta
	IF(vdif_cta = vdia_cta) THEN

		TRUNCATE bdinteg:info_cuenta_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		 WHERE id_tabla = 3;
				
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion SET ind_dep = '0'
				WHERE id_tabla = 3;
				
	END IF

	-- Depuracion de Tarjeta
	IF( vdif_tar = vdia_tar ) THEN
		-- Pendiente
	END IF			
	
	RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;