CREATE PROCEDURE "informix".sp_solicitudes_reposiciones_tarjetas()
RETURNING VARCHAR(5), VARCHAR(255);  

--*************************************************************************************************************************************^***
 -- DESCRIPCIÓN: Reporte de solicitudes y reposiciones de tarjetas personalizadas.                                                                          *
 -- AUTOR : Esmeralda J. Figueroa Acosta                                                                                                  *
 -- FECHA : 08/Agosto/2017                                                                                                          *
 -- BD: intercard                                                                                                                         *
--*****************************************************************************************************************************************
	
 
-- VARIABLES PARA EL CONTROL DE ERRORES

	DEFINE  vsql_err             INTEGER;
	DEFINE  visam_err           INTEGER;
	DEFINE  verror_info          VARCHAR(80);
	DEFINE  p_cod_ret            VARCHAR(6);
	DEFINE  p_mensaje            VARCHAR(80);
	
-- VARIABLES DE OPERACIÓN(FECHAS)

	DEFINE vultimo_dia_mes 		DATE;
	DEFINE vprimer_dia_mes 		DATE;
	DEFINE vfecha_hoy              DATE;
	DEFINE vsql						CHAR(1000);					

    --SET DEBUG FILE TO "/informix/Esmeralda/SpSolicitudes/trace.out";
    --TRACE ON;	

BEGIN
		ON EXCEPTION SET vsql_err, visam_err, verror_info
			LET p_cod_ret    = vsql_err;
			LET p_mensaje  = verror_info;
			
			RETURN 	p_cod_ret,p_mensaje;
			
		END EXCEPTION; 
		
		
		-- OBTENER FECHA ACTUAL
		SET ISOLATION TO DIRTY READ;
		SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas;	

		-- OBTENER EL ULTIMO DÍA DEL MES ANTERIOR A LA EJECUCIÓN
		LET vultimo_dia_mes = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
		-- OBTENER EL PRIMER DÍA DEL MES ANTERIOR A LA EJECUCIÓN
		LET vprimer_dia_mes = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
		                                      
		LET vsql	=	'';
		LET vsql	=	'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/rpt_solicitudes_reposiciones_'||SUBSTR(vfecha_hoy,4,2)||SUBSTR(vfecha_hoy,1,2)||SUBSTR(vfecha_hoy,7,4)||'.unl' ||
		'	SELECT ' ||
		'	DATE(fecha_generacion) as fecha, ' ||
		'	clave_sucursal as sucursal, ' ||
		'	SUBSTRING(numtarjeta from 1 for 6) as bin, ' ||
		'	SUBSTRING(numtarjeta from 7 for 2) as subbin, ' ||
		'	numlote as lote, numguia as guia, ' ||
		'	tipomaquila, id_diseno as iddiseno, count(*) ' ||
		'FROM intercard:detalle_maquila ' ||
		'WHERE ' ||
		'	fecha_generacion::DATE >= ''"'||vprimer_dia_mes||'"'' AND '||                     
		'	fecha_generacion::DATE <= ''"'||vultimo_dia_mes||'"'' AND '||                                       
		'	tipomaquila in (''"'||'E'||'"'',''"'||'N'||'"'',''"'||'S'||'"'') AND' ||
		'	SUBSTRING(numtarjeta from 1 for 6) = ''"'||'416916'||'"'' AND '||
		'	SUBSTRING(numtarjeta from 7 for 2) in(''"'||'03'||'"'',''"'||'05'||'"'',''"'||'05'||'"'')' ||
		'GROUP BY 1,2,3,4,5,6,7,8 ' ||
		'ORDER BY 1,2,3,4,5,6,7,8; ">/resplogifx/rpt_solicitudes_reposiciones_base.sql ';
				           
		SYSTEM vsql;
		LET vsql	=	'';
		LET vsql	=	'dbaccess intercard /resplogifx/rpt_solicitudes_reposiciones_base.sql';
		SYSTEM vsql;
		LET vsql	=	'rm /resplogifx/rpt_solicitudes_reposiciones_base.sql';
		SYSTEM vsql;	
		
		
		LET	p_cod_ret 	=	'00000';
		LET p_mensaje	=	'Reporte generado exitosamente';
	    RETURN p_cod_ret,p_mensaje; 
END;  
END PROCEDURE;