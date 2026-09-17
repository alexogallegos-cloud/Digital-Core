CREATE PROCEDURE "informix".sp_sorteorec_reporte()
       RETURNING char(6),integer;
--EXECUTE PROCEDURE "informix".sp_sorteorec_reporte();
--declaracion de variables
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE vnumcuentaq                  CHAR(20);
DEFINE vnumboletosp					integer;
--tabla
DEFINE vnum_folio					char(16);
DEFINE vnum_folioc					char(16);
DEFINE vnum_cliente					char(9);
DEFINE vimp_importe					decimal(14,2);
--
DEFINE vnum_sorteo				INTEGER;
DEFINE vstatus_aclaracion		INTEGER; 
DEFINE vNumcteParticipa			INTEGER;
DEFINE vProd					INTEGER;
DEFINE vnum_producto			char(4);
DEFINE vfecha_inicio			date;
DEFINE vfecha_final             date; 
DEFINE vfecha_finalmes			date; 
DEFINE vfecha_mov				date; 
--boleto adicional
DEFINE vcontadicional 			integer; 
DEFINE vmto_boleto              smallint;
DEFINE vmto_boletoa             smallint;
DEFINE vmax_boletocte			smallint;
define vsec_primercomp			integer;
DEFINE vnum_tienda					char(5); 

    --SET DEBUG FILE TO "/resplogifx/archivoscartera/mpeinado/Enero2019/sp_sorteorec_reporte.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET vnumcuentaq      = '';
	  LET vnumboletosp  = 0;
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';


	LET vnum_folio					="";
	LET vnum_folioc					="";
	LET vnum_cliente				="";
	LET vimp_importe				=0;
	LET vmto_boleto					=0;
	LET vmto_boletoa				=0;
	LET vmax_boletocte				=0;
	--
	LET vnum_sorteo					=0;
	LET vstatus_aclaracion			=0;
	LET vNumcteParticipa			=0;
	LET vProd						=0;
	LET vnum_producto				="";
	LET vfecha_inicio				= DATE(1);
	LET vfecha_final				= DATE(1);
	let vfecha_finalmes				= DATE(1);
	LET vfecha_mov					= DATE(1);
	let vsec_primercomp				=0;
	LET vnum_tienda					=""; 
	
	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret,vnum_sorteo;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

--obtengo la fecha 
select ult_hab_mes
into vfecha_finalmes
from bdicred:sd_fechas
where empresa = '001';

--obetener sorteo o fecha sorteo
select first 1 num_sorteo
	into vnum_sorteo
from sd_sorteo_recompensa
where fecha_sorteo = vfecha_finalmes;

--cantidad de monto para boletos
select valor 
	into vmto_boleto
    from  bdicred:sd_param
where cod_param = '071' and empresa = '001';
 
            
FOREACH WITH HOLD

	select num_producto,fecha_inicio,fecha_final
		into vnum_producto,vfecha_inicio,vfecha_final
	from sd_sorteo_recompensa
	where num_sorteo = vnum_sorteo
	
		--temporal con maecred y descartar de una vez los del grupo
		select a.num_credito num_credito,a.numcte numcte, a.sucursal sucursal  
		from bdicred:sd_maecred a
		INNER JOIN bdicred:sd_maesdos maes ON (maes.num_credito = a.num_credito)
		--left join bdinteg:"informix".si_empleado_cliente_coppel b on (a.numcte = b.numcte and b.status = '1')
		--left join bdicheq:"informix".sc_maechq c on (a.empresa = c.empresa and a.numcte = c.num_cte and c.producto = '1300')
		where a.empresa = '001'
		and a.status_cred IN ('AA','E1')
		AND (maes.monto_vencido + maes.mto_venc_trasp) = 0
		and a.num_producto = vnum_producto
		--and b.numcte is null 
		into temp temp_posibleparticipante with no log;
		
		create index inx_temp_posibleparticipante on temp_posibleparticipante(num_credito);
		update statistics medium for table temp_posibleparticipante;
	
	FOREACH WITH HOLD
	
		select DISTINCT a.num_credito,b.numcte,b.sucursal
		into vnumcuentaq,vnum_cliente,vnum_tienda
		from bdicred:sd_movhis a,
		temp_posibleparticipante b
		where a.num_credito = b.num_credito
		and a.codigo_fun = '002'
		and a.codigo_ref in (37,57,937,938)
		and a.fecha_mov between vfecha_inicio and vfecha_final
		and a.monto >= vmto_boleto
		and a.reversado='N'
		
		--obtener primer folio participante
		select MIN(secuencia)
		into vsec_primercomp
		from bdicred:sd_movhis 
		where codigo_fun = '002'
		and codigo_ref in (37,57,937,938)
		and fecha_mov between vfecha_inicio and vfecha_final
		and monto >= vmto_boleto
		and num_credito = vnumcuentaq
		and reversado='N';
		--Order by secuencia;
		
		select monto,folio_suc,fecha_mov
		into vimp_importe,vnum_folio,vfecha_mov
		from bdicred:sd_movhis 
		where empresa = '001' 
		AND num_credito = vnumcuentaq
		AND secuencia = vsec_primercomp; 
		
			--descartar empleados del grupo coppel
			SELECT COUNT(numcte)
				INTO vNumcteParticipa
			FROM bdinteg:"informix".si_empleado_cliente_coppel
			WHERE numcte = vnum_cliente
			AND status = '1';

			IF vNumcteParticipa > 0 THEN
				continue foreach;
			END IF;		
		--descartar que no tenga cuenta nomina
			SELECT COUNT(producto)
			INTO vProd
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte = vnum_cliente AND producto = '1300' AND empresa = '001';

			IF vProd > 0 THEN
				continue foreach;
			END IF;
		
		--descartar que el movimiento este en aclaración
			SELECT count(acl.folio_csuac)
				into vstatus_aclaracion
			FROM bdiaclaracion:acl_aclaracion acl
			inner join bdiaclaracion:acl_movimiento am on (acl.pky_aclaracion=am.fky_aclaracion and am.duplicado= 0 and am.fky_padre is null)
			WHERE am.folio_suc = vnum_folio 
			and acl.fky_estatus_aclaracion = 2;

				
			if vstatus_aclaracion >= 1 then
				continue foreach;
			end if;
			
			--inserta primer boleto
			execute PROCEDURE bdicred:"informix".sp_genera_boleto(vnum_cliente,vnumcuentaq,vimp_importe,vnum_folio,vnum_tienda)
			into cCod_ret;
				
			--monto boleto adicional
			select valor 
				into vmto_boletoa
			from bdicred:sd_param
			where cod_param = '072' and empresa = '001';
			
			--maximo boletos por cliente
			select valor 
				into vmax_boletocte
			from  bdicred:sd_param
			where cod_param = '073' and empresa = '001';
			
			let vcontadicional = 0;
				--Genera boletos adicionales
				FOREACH WITH HOLD
					
					select b.numcte,a.monto,a.folio_suc
					into vnum_cliente,vimp_importe,vnum_folioc
					from bdicred:sd_movhis a
					inner join temp_posibleparticipante b on (a.num_credito = b.num_credito)
					where a.empresa = '001'
					and a.codigo_fun ='002'
					and a.codigo_ref in (37,57,937,938)
					and a.fecha_mov between vfecha_mov and vfecha_final
					and a.monto >= vmto_boletoa
					and a.num_credito = vnumcuentaq
					and a.folio_suc <> vnum_folio
					and a.reversado='N'
					order by fecha_mov
					
					--descartar que el movimiento este en aclaración
					SELECT count(acl.folio_csuac)
						into vstatus_aclaracion
					FROM bdiaclaracion:acl_aclaracion acl
					inner join bdiaclaracion:acl_movimiento am on (acl.pky_aclaracion=am.fky_aclaracion and am.duplicado= 0 and am.fky_padre is null)
					WHERE am.folio_suc = vnum_folio 
					and acl.fky_estatus_aclaracion = 2;

						
					if vstatus_aclaracion >= 1 then
						continue foreach;
					end if;
					
					--validar si hay mas de 1000
					select max(num_secuencia)
						into vnumboletosp
					from bdicred:sd_sorteotec_reporte
					where num_credito = vnumcuentaq
					and fec_fecha between vfecha_inicio and vfecha_final;
					
					LET vnumboletosp  = nvl(vnumboletosp,0);
					
					IF vnumboletosp >= vmax_boletocte THEN
						continue foreach;
					END IF;
					
					--inserta boletos adicionales
					EXECUTE PROCEDURE sp_genera_boleto(vnum_cliente,vnumcuentaq,vimp_importe,vnum_folioc,vnum_tienda)
					into cCod_ret;
					
					let vcontadicional = vcontadicional + 1;
					
					if vcontadicional = 3 then
					
						--validar si hay mas de 1000
						select max(num_secuencia)
							into vnumboletosp
						from bdicred:sd_sorteotec_reporte
						where num_credito = vnumcuentaq
						and fec_fecha between vfecha_inicio and vfecha_final;
						
						LET vnumboletosp  = nvl(vnumboletosp,0);
						
						IF vnumboletosp >= vmax_boletocte THEN
							continue foreach;
						END IF;
						
						--boleto adicional por tres transacciones
						EXECUTE PROCEDURE sp_genera_boleto(vnum_cliente,vnumcuentaq,vimp_importe,vnum_folioc,vnum_tienda)
						into cCod_ret;
						let vcontadicional = 0;					
					end if;
				
				END FOREACH; 
	END FOREACH; 	
	drop table temp_posibleparticipante;		
END FOREACH; 


     RETURN cCod_ret,vnum_sorteo;
	END;
	
END PROCEDURE;