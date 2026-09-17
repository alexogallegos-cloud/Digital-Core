CREATE PROCEDURE "informix".sp_solicitudessos_latinia(
					p_numcte char(20),
					p_tipo_sol char(20),
					p_nombre_inc char(104),
					p_numcte2 char(20),
					p_fecha_nac_inc date, 
					p_nombre_corr char(104),
					p_fecha_nac_corr date,
					p_sucursal char(4))
	
	--**************************************************************************************************
    -- Realizo  : Briseida Ayala Inzunza
    -- Proyecto : Latinia registro de eventos.
    -- Actividad: Se registran los eventos para solicitar la corrección de datos y fusión de expedientes 
	--			  por correo electrónico.
    --**************************************************************************************************

	-- Definicion de variables
  	DEFINE v_codRet1 char(5);
  	DEFINE v_codRet2 char(5);
	DEFINE v_tipo char(20);	
	DEFINE v_fecha_nac_inc char(10);
	DEFINE v_fecha_nac_corr char(10);
	
	-- Valor Inicial de variable de retorno
	LET v_codRet1='11111';
	LET v_codRet2='11111';

	BEGIN
	
	--Validando que los datos recibidos existan en la tabla
		SELECT tipo_sol,fecha_nac_inc,fecha_nac_corr
		into v_tipo, v_fecha_nac_inc, v_fecha_nac_corr
		from table ( multiset(
		select first 1 tipo_sol, cast(fecha_nac_inc as char(10)) as fecha_nac_inc, cast(fecha_nac_corr as char(10)) as fecha_nac_corr
		from bdinteg:"informix".si_bitacora_solicitudessos
		where tipo_sol=p_tipo_sol
		and numcte=p_numcte
		--and numcte2=p_numcte2
		and nombre_inc=p_nombre_inc
		and nombre_corr=p_nombre_corr
		order by folio_sol desc));
		
		
		--Se cambia formato de fecha a DD/MM/AAAA
		LET v_fecha_nac_inc = LPAD(DAY(v_fecha_nac_inc),2,'0')||'/'||LPAD(MONTH(v_fecha_nac_inc),2,'0')||'/'||YEAR(v_fecha_nac_inc);
		LET v_fecha_nac_corr = LPAD(DAY(v_fecha_nac_corr),2,'0')||'/'||LPAD(MONTH(v_fecha_nac_corr),2,'0')||'/'||YEAR(v_fecha_nac_corr);
		
		-- Valida que tipo de solicitud es
			IF v_tipo='Corrección de datos' THEN  
								
				execute procedure bdimnsj:"informix".sp_registra_evento_prod(1,'CTE_CDATS',
				'CTE_CCDT', 'GRUPO_HUELIN','XXXXXXXXXXX','','1',
				p_sucursal, v_fecha_nac_inc, '',		
				v_fecha_nac_corr, p_numcte, p_nombre_inc, '', '', '', p_nombre_corr, '',
				'', 1, 0, 0, 0, 0,current,current ) INTO v_codRet1;
				
			ELIF v_tipo='Fusión de expediente' THEN 
				
				execute procedure bdimnsj:"informix".sp_registra_evento_prod(1,'CTE_CDATS',
				'CTE_FSEX', 'GRUPO_HUELIN', 'XXXXXXXXXXX','', '1', p_sucursal, v_fecha_nac_corr,
				p_numcte2, '', v_fecha_nac_inc,p_nombre_corr, p_numcte, '', '', p_nombre_inc,
				'', 
				'', 1, 0, 0, 0, 0,current,current )INTO v_codRet1;	
				
			END IF;
		END;
 END PROCEDURE;