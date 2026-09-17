CREATE PROCEDURE "informix".sp_concreing_param_consulta (psCodigo VARCHAR(50))

RETURNING VARCHAR(3) AS Codigo, VARCHAR(50) AS Descripcion, VARCHAR(90) AS Valor;

--****************************************************************************************************
-- DESCRIPCION: Obtiene la informacion correspondiente del codigo del parametro indicado para las opciones de consulta
-- AUTOR : Ricardo Reséndiz Martinez
-- FECHA : 25/08/2015
-- BD: BdiTrajeta
-- SISTEMA : Reingenieria de la Conciliación migracion al SOC
-- MODIFICADO :

--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsCodigo VARCHAR(50);
DEFINE vsDescripcion VARCHAR(50);
DEFINE vsValor VARCHAR(90);



DEFINE visqlerr INTEGER ;
DEFINE viErrores INTEGER ;


/* INICIALIZACION DE VARIABLES */

LET vsCodigo = '';
LET vsDescripcion = '';
LET vsValor = '';


LET visqlerr = 0 ;
LET viErrores = 0 ;


BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN 
				'', 
				('ERROR ' || visqlerr), 
				'';

	END EXCEPTION;
	
--SET DEBUG FILE TO '/informix/HomeInformix/rrm/opcconsulta.out';
--TRACE ON;

	if replace(psCodigo,' ','') = '111' then     --  Para recuperar opciones de devolución en el combo
	
		foreach cusor1 with hold for
				SELECT codigo, descripcion
					INTO vsCodigo, vsDescripcion
				FROM bditarjeta:"informix".td_opciones_consulta 
					WHERE codigo in ('001', '002', '003', '004', '005')
				group by 2,1
				order by 1,2
				
				RETURN NVL(vsCodigo, ''), NVL(vsDescripcion, ''), NVL(vsValor, '') WITH RESUME;
				
				
		end foreach;
	
	elif replace(psCodigo,' ','') = '222' then  -- Para recuperar parametros de consulta tipo de conciliacion administrativa
		foreach cusor1 with hold for
				SELECT codigo, descripcion
					INTO vsCodigo, vsDescripcion
				FROM bditarjeta:"informix".td_opciones_consulta 
					WHERE codigo in ('010', '011', '012', '013', '014', '015', '016', '017')
				group by 2,1
				order by 1,2
				
				RETURN NVL(vsCodigo, ''), NVL(vsDescripcion, ''), NVL(vsValor, '') WITH RESUME;
	
				
		end foreach;
	
	elif replace (pscodigo, ' ', '') = '333' then  -- Para recuperar catalogo de archivos origen 
	
		foreach cusor1 with hold for
				select archivo_origen || ' - ' || descripcion
					into vsDescripcion
				from bditarjeta:"informix".td_archivo_origen 
					where transferir_win_aix <> 'F'
				order by orden_proceso
				
				RETURN NVL(vsCodigo, ''), NVL(vsDescripcion, ''), NVL(vsValor, '') WITH RESUME;
			
		end foreach;
	
	elif replace (pscodigo, ' ', '') = '444' then  -- Para recuperar catalogo de tipos de conciliacion 
	
		foreach cusor1 with hold for
				select tipo_conciliacion ,  desc_conciliacion 
					into vsDescripcion , vsValor
				from bditarjeta:"informix".td_tipo_conciliacion 
					order by tipo_conciliacion
				
				RETURN NVL(vsCodigo, ''), NVL(vsDescripcion, ''), NVL(vsValor, '') WITH RESUME;
			
		end foreach;
	else

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LA INFORMACION DEL PARAMETRO
		SELECT FIRST 1  Valor
		INTO  vsValor
		FROM BdiTarjeta:"informix".td_opciones_consulta
		WHERE descripcion = psCodigo;
	
		RETURN  '', '', NVL(vsValor, '');
		
	end if;	
	
	if vsCodigo is null then 
		let vsCodigo = '999';
		let vsDescripcion = 'No existe parametro de consulta' ;
	end if ; 
		
		
	

END

END PROCEDURE
DOCUMENT
'AUTOR: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE LA INFORMACION CORRESPONDIENTE DEL CODIGO DEL PARAMATERO INDICADO PARA LAS OPCIONES DE CONSULTA.',
'Fecha: 2015/08/25',
'Version: 20150825.1030',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_conarchivodetalle_con2_totales(
														cTipo char(1),
														cTipoCon varchar(3),
														cNombreArchivo varchar(23),
														cNumEmpl varchar(9)
													)
RETURNING VARCHAR(6) as Cod_ret, INTEGER AS no_registros;


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE vNoRegistros INTEGER;
	
	LET vNoRegistros = 0;	

	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('9','Error en sp_conarchivodetalle_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;

     RETURN P_COD_RET, vNoRegistros;	
								
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Detalle de Archivos de ConciliaciÃ³n
--************************************************************
-- Modificado: Juan Fco. Ponce Damian 
-- fecha : 06/09/2013
-- DescripciÃ³n: Se modificaron todos las consultas para retornar el Monto de Cash Back.
--************************************************************
-- Modificado: L.I.A. Ricardo Resendiz Martinez
-- fecha : 18/09/2015
-- DescripciÃ³n: Se modifica consulta para que busque por la clave del tipo de conciliaciÃ³n. Se redujeron de 60 a 3 el cTipoCon
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   IF (cTipo == 'A') THEN --Todos los Registros
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion 	
		WHERE nombrearchivo = trim(cNombreArchivo);
													
		RETURN P_COD_RET, vNoRegistros;	
		
	ELIF (cTipo == 'B') THEN --Error de Integridad
		
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion 	
		WHERE nombrearchivo = trim(cNombreArchivo) AND integridad = 'F';
													
		RETURN P_COD_RET, vNoRegistros;	
		
	ELIF (cTipo == 'C') THEN --Error de Integridad

		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND 
			  --tipo_conciliacion = (select tipo_conciliacion from bditarjeta:td_tipo_conciliacion  where desc_conciliacion =trim (cTipoCon))			
			  tipo_conciliacion = cTipoCon;
			  
		RETURN P_COD_RET, vNoRegistros;	

	ELIF (cTipo == 'D') THEN --Error de Integridad
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'F' AND integridad = 'V' AND conciliacion = 'V';
							
		RETURN P_COD_RET, vNoRegistros;	
			
	ELIF (cTipo == 'E') THEN --Error de Integridad
			
		SELECT COUNT(*)					
		INTO vNoRegistros
		FROM bditarjeta:"informix".td_movimientos_conciliacion
		WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'V'; 
							
		RETURN P_COD_RET, vNoRegistros;	
			
	END IF;

      
END;
END PROCEDURE;