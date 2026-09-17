CREATE PROCEDURE "informix".sp_valida_revision_rcda_web ( pfecha date, psuc  CHAR (04))
RETURNING 	CHAR (05)	AS cod_ret	,
			CHAR (80) 	AS mensaje	,
			CHAR (01) 	AS revisado	,
			CHAR (01)	AS servicio	;
			
--declaracion de variables de retorno
	DEFINE cod_ret          CHAR (05);
	DEFINE mensaje			CHAR (80);		
	DEFINE revisado			CHAR (01);
	DEFINE vsqlerr      	INTEGER;
	DEFINE servicio			CHAR (01);
	DEFINE  vestatus_rcda	CHAR(1);  
	
--INICIALIZACION DE VARIABLES DE RETORNO

	let	cod_ret  = '00002';
	let	mensaje	 =	'error en central sp_valida_revision_rcda';
    let	revisado = 'N';
	let servicio = 'F';
	
BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN  cod_ret, 'error en central sp_valida_revision_rcda','N','F';
        END IF;
    END EXCEPTION;
	
	
-- obtenemos el estatus del servicio de cierre diario y acumulado
	select	TRIM(estatus) 
	INTO	servicio
	from	mi_param 
	where	descripcion = 'FLAG RPT CIERRE';
	
--obtenemos el status de la sucursal 

	SELECT	TRIM(estatus)
	INTO	revisado
	FROM	mi_rptcierresucestatus 
	WHERE	fecha_rptcierre = pfecha and sucursal = psuc;  	
	IF    (dbinfo('sqlca.sqlerrd2')=1)  THEN
		SELECT {+ INDEX(mi_activarsuc_rcda idx_mi_activarsuc_rcda)} estatus_rcda INTO vestatus_rcda	FROM bdmis:mi_activarsuc_rcda WHERE sucursal = psuc;
		IF (servicio = 'V') OR (vestatus_rcda = 'V') THEN
			if ((servicio = 'V') OR (vestatus_rcda = 'V')) and revisado <> 'C' THEN
				let	cod_ret  = '00000';
				RETURN  cod_ret, 'No Revizado','N',servicio;
			ELIF ((servicio = 'V') OR (vestatus_rcda = 'V')) and revisado = 'C' THEN
				let	cod_ret  = '00000';
				RETURN  cod_ret, 'Ya Revizado',revisado,servicio;
			END IF
		ELSE
			let	cod_ret  = '00001';
			RETURN  cod_ret, 'Servicio no disponible','N',servicio;
		END IF;
	ELSE
		let	cod_ret  = '00003';
		let	mensaje	 =	'FECHA DE REPORTE DE SUCURSAL NO CORRESPONDE CON LA FECHA DE REPORTE DE CENTRAL';
		RETURN  cod_ret, mensaje,revisado,servicio;	
	END IF
	
	RETURN  cod_ret, mensaje,revisado,servicio;
	
END	
END PROCEDURE;