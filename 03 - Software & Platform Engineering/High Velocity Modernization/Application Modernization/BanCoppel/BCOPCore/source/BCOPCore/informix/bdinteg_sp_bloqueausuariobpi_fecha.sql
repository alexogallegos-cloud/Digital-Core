CREATE PROCEDURE "informix".sp_bloqueausuariobpi_fecha(pfecha date)
RETURNING VARCHAR(6),VARCHAR(80),INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
define dfecha date;
define cTipo  varchar(5);
define iDias  integer;
define iBloq  integer;
define iEje  integer;
define iNum  integer;
define iCont  integer;


--RealizÃÂ³: Manuel Osuna Valencia
--Fecha: 06/07/2010
--SolicitÃÂ³: Ismael Hernandez
--Actividad: Cambia de estatus del perfil a los usuarios que no cumplan las directivas de la tabla de parametros

Begin
	 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	      LET P_COD_RET    = SQL_ERR;
	      LET P_MENSAJE  = ERROR_INFO;
	      RETURN P_COD_RET, P_MENSAJE,iCont;
	 END EXCEPTION;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';
	LET iCont = 0;

	select limit 1
		case when id_param = '07' and (valor is null or valor = "" ) then 'Falta Parametro 07' 
		     when id_param = '08' and (valor is null or valor = "" ) then 'Falta Parametro 08' 
		     when id_param = '09' and (valor is null or valor = "" ) then 'Falta Parametro 09' 
		     when id_param = '10' and (valor is null or valor = "" ) then 'Falta Parametro 10' 
		     when id_param = '11' and (valor is null or valor = "" ) then 'Falta Parametro 11' 
		     when id_param = '10' and (select count(*) from bdibpi:bpi_auxparam where id_param = id_param) =0 then 'No existen status en bpi_auxparam' 	
	      	     else "0"
		end into  P_MENSAJE
	from bdibpi:bpi_param  where id_param in ('07','08','09','10','11')
	group by 1;

	IF (P_MENSAJE == "0") THEN 

		
		select valor into cTipo  from bdibpi:bpi_param 	where id_param  = "07" and current between f_inicio and f_fin;
		select 
			sum(case when id_param = '08' then valor::int end),
			sum(case when id_param = '09' then valor::int end),			
			sum(case when id_param = '11' and cTipo = "D"  then 1  
				 when id_param = '11' and cTipo = "S"  and (date(current) - date(f_fin) = 7) then 1  
			         when id_param = '11' and cTipo = "M"  and (date(f_fin + Interval(1) month to month) = date(current)) then 1 
			         else 0	
        	            end) into iDias,iBloq,iEje
	       from bdibpi:bpi_param  where id_param in ('08','09','10','11');
		
	       IF (iEje == 1) THEN

				LET P_MENSAJE = 'PROCESO EXITOSO';
			
				--select fecha_ant into dfecha from bdinteg:si_fechas;
		
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)
				and nvl(f_ultimo_acceso,null) is null						
				and (date(pfecha) - date(f_registro)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and nvl(f_ultimo_acceso,null) is null	
					and (date(pfecha) - date(f_registro)) >= iDias;						

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
			
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)			
				and (date(pfecha) - date(f_ultimo_acceso)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and (date(pfecha) - date(f_ultimo_acceso)) >= iDias;						

					

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
				update bdibpi:bpi_param set f_inicio = current,f_fin = current where id_param = '11';

			ELSE
				LET P_MENSAJE = 'HOY NO TOCA ACTUALIZAR REGISTROS';		

			END IF;	

		
	ELSE
		LET P_COD_RET = '00001';		
	END IF;
	
	RETURN P_COD_RET,P_MENSAJE,iCont;
END;
END PROCEDURE;