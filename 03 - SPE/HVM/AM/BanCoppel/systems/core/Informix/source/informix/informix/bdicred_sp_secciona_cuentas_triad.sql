CREATE PROCEDURE "informix".sp_secciona_cuentas_triad(pEmpresa CHAR(3))
    RETURNING 
	        CHAR(06)  AS resultado,
			CHAR(80) AS mensaje;


DEFINE CodRet		CHAR(06);
DEFINE cCod_ret_2   CHAR(6);
DEFINE cMensajeRet	CHAR(80);
DEFINE sql_err		SMALLINT;
DEFINE isam_err		SMALLINT;
DEFINE error_info	CHAR(64);

DEFINE FechaHoy		DATE;
DEFINE FechaAnt		DATE;

DEFINE vErrores     INTEGER;
DEFINE cSql         CHAR(200);
DEFINE pprocesos     SMALLINT;
DEFINE pcuenta       INTEGER;
DEFINE pcuenta_aux3  INTEGER;
DEFINE pcontador     SMALLINT;
DEFINE cred_ini      CHAR(20);
DEFINE cred_fin      CHAR(20);
DEFINE prango        CHAR(50);
DEFINE pparametro    CHAR(3);
DEFINE vstatus_proc  CHAR(1);
DEFINE iParam_califica   INTEGER;
DEFINE pNumCredIni_temp  CHAR(25);
DEFINE iDia_corte        INTEGER; 
DEFINE vFechaDiaAnt      DATE;
DEFINE cProceso          CHAR(4);
DEFINE dFechaCorte       DATE;
DEFINE dFechaCorte_ant   DATE;

 --SET DEBUG FILE TO "/ifxsif01/macf/sp_secciona_cuentas_triad.out";
 --TRACE ON;
 --temporal solo para pruebas   TRACE OFF;

LET CodRet		     = '000000';
LET cMensajeRet	     = 'PROC. GENERA UNIVERSO CTAS TRIAD EXITOSO';
LET sql_err          = 0;
LET isam_err         = 0;
LET error_info       = '';
LET FechaHoy         = date(1);
LET FechaAnt         = date(1);
LET vErrores         = 0;
LET pprocesos        = 0;
LET pcuenta          = 0;
LET pcuenta_aux3     = 0;
LET pcontador        = 0;
LET cred_ini         = ''; 
LET cred_fin         = '';
LET prango           = '';
LET pparametro       = '';
LET vstatus_proc     = '';
LET iParam_califica  = 0;
LET pNumCredIni_temp = '';
LET iDia_corte       = 0;
LET vFechaDiaAnt     = date(1);
LET cProceso         = '0092';
LET cCod_ret_2       = '';
LET dFechaCorte      = date(1);
LET dFechaCorte_ant  = date(1);


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
 ON EXCEPTION 
    SET sql_err, isam_err, error_info
	LET CodRet = sql_err;
	LET cMensajeRet = isam_err || ' ' || cred_ini;
    
	--let cMensaje = pEjecucion || '-' || trim(cCodRet) || ' ' || cNumCredCob;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, CodRet, trim(cMensajeRet), '02') RETURNING cCod_ret_2;
	
	
	RETURN CodRet,cMensajeRet;
 END EXCEPTION;

 CALL bdicobranza:sp_inserta_bitacora_cob_2(pEmpresa, cProceso, CodRet, cMensajeRet, '01') RETURNING cCod_ret_2; 

--      let FechaHoy = today;
--temporal solo para pruebas
      --let FechaHoy = mdy('04','30','2018');
--	  let FechaHoy = mdy('03','31','2019');
--temporal solo para pruebas


  SELECT fecha_hoy, fecha_ant
    INTO FechaHoy, FechaAnt
    FROM sd_fechas
   WHERE empresa = pEmpresa;
	   
	  IF FechaAnt IS NULL THEN
         LET CodRet = "110";
		 LET cMensajeRet = 'Fecha ant NULL';
		 RETURN CodRet,cMensajeRet;
      END IF; 
    
 
 --LET FechaHoy = MDY(9,2,2020);
 --LET FechaHoy = today -1;
 LET FechaHoy = FechaAnt;
 
 LET iParam_califica = 830;
 
 LET iDia_corte = DAY(FechaHoy);
 LET vFechaDiaAnt =  date(FechaHoy - 1 units day); 
 
 LET dFechaCorte     =  lpad(month(FechaHoy),2,0) || "/" || lpad(day(FechaHoy),2,0) || "/" || year(FechaHoy);
 LET dFechaCorte_ant =  date(dFechaCorte - 1 units month);
 
 --LET cfecha_dia = year(dtFechaIniMes) || lpad(month(dtFechaIniMes),2,0) || lpad(day(dtFechaIniMes),2,0);
 
 
	SELECT a.num_credito num_cred
	FROM bdicred:sd_maecred a 
	   JOIN bdicred:sd_maesdos c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
									AND c.monto_financiado > 0  -- PM MAYOR A CERO
	   JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
	WHERE a.num_producto <> '7800'   
	--AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin  
	--AND a.status_cred = 'AA'
	AND a.status_cred in ('AA','E1') 
	AND (c.monto_vencido + c.mto_venc_trasp) = 0
	AND d.dia_corte = iDia_corte 
	--AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
	INTO TEMP paso_cob WITH NO LOG;

	create unique index inx_paso_cob on paso_cob(num_cred);
	update statistics medium for table paso_cob;
	
   INSERT INTO paso_cob		
	SELECT a.num_credito
	  FROM bdicred:sd_maecred a
		   JOIN bdicred:sd_maecredanexo d ON a.empresa = d.empresa AND a.num_credito = d.num_credito
		   JOIN bdicred:sd_maesdos c ON a.num_credito = c.num_credito       --- IFRS MACF
	 WHERE a.num_producto <> '7800' --AND a.status_cred in('BA','BT') --VENCIDOS
	    AND a.status_cred in ('BA','BT','E1','E2','E3') 
		AND (c.monto_vencido + c.mto_venc_trasp) > 0
	   --AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin
	   AND a.num_credito NOT IN(SELECT num_cred from paso_cob);
	   --AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy);

	INSERT INTO paso_cob 
	SELECT a.num_credito
	  FROM bdicred:sd_maecred a 
		   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
		   JOIN bdicobranza:cb_triad_salida f ON f.num_credito = a.num_credito 
		   JOIN bdicred:sd_maesdos c ON a.num_credito = c.num_credito       --- IFRS MACF
	 WHERE a.num_producto <> '7800' --AND a.status_cred = 'AA' --VIGENTES 
	   AND a.status_cred in ('AA','E1') 
	   AND (c.monto_vencido + c.mto_venc_trasp) = 0
	   AND a.num_credito NOT IN(SELECT num_cred from paso_cob)
	   --AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
	   --AND a.num_credito >= pNumCredIni AND a.num_credito < pNumCredFin 
	   AND d.prox_fecha_pago+f.out_coll_next_call_days = Fechahoy;  --VIGENTES EN EL CAMPO OUT-COLL-NEXT-CALL-DAYS*

	INSERT INTO paso_cob 
	SELECT a.num_credito
	  FROM bdicred:sd_maecred a
		   JOIN bdicred:sd_maecredanexo d ON d.empresa = a.empresa AND d.num_credito = a.num_credito 
		        AND d.fecha_ult_pago = vFechaDiaAnt --PAGO UN DIA ANTERIOR
		   JOIN bdicred:sd_maesdoshist e ON e.empresa = a.empresa AND e.num_credito = a.num_credito 
						--AND e.fecha = (mdy(month(Fechahoy),d.dia_corte,year(Fechahoy)) -1 units month)
						  AND e.fecha = dFechaCorte_ant
						AND (e.monto_vencido+e.mto_venc_trasp) > 0
		   JOIN bdicred:sd_maesdos b ON b.num_credito = a.num_credito 
	 WHERE a.num_producto <> '7800' --AND a.status_cred = 'AA' --VIGENTES
	   AND a.status_cred in ('AA','E1') 
	   AND (b.monto_vencido + b.mto_venc_trasp) = 0
	   AND a.num_credito NOT IN(SELECT num_cred from paso_cob);
	   --AND a.num_credito NOT IN(SELECT ti_co_account_id from bdicobranza:cb_triad_cobranza WHERE fecha_proceso = vFechahoy)
	   --AND a.num_credito >= pNumCredIni AND a.num_credito  < pNumCredFin;
		
 update statistics medium for table paso_cob;		

-- INI    REALIZA SEGMENTACION DE CREDITOS
SELECT NVL(valor::INTEGER,0)
  INTO pprocesos
  FROM bdicred:sd_param
 WHERE cod_param = iParam_califica::varchar(3) ;
 
 /*SELECT ROUND(COUNT(*) / pprocesos,0)
  INTO pcuenta
  FROM bdicred:sd_maecredanexo 
 WHERE empresa = pEmpresa 
   AND fecha_proceso = FechaHoy;*/
   
   SELECT ROUND(count(*)/ pprocesos,0)
     INTO pcuenta
	 FROM paso_cob;
 
	LET pcuenta_aux3 = pcuenta;

	FOR pcontador = 1 TO  pprocesos
	   FOREACH
		   SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_cred,'')
			 INTO cred_fin
			 FROM paso_cob
			  ORDER BY num_cred
	   END FOREACH

		IF pcontador = 1 THEN
			LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
			LET cred_ini = cred_fin;
			LET pparametro = '831';

		ELSE
			IF pcontador = pprocesos THEN
				LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
			ELSE    
				LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
				LET cred_ini = cred_fin;
			END IF;

			LET pparametro = (pparametro::integer + 1)::varchar(3); 

		END IF;

			LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;
	   
		   UPDATE bdicred:sd_param 
			  SET valor = prango
			WHERE empresa = pEmpresa
			  AND cod_param = pparametro;
			
			  
	END FOR;  

 CALL bdicobranza:sp_inserta_bitacora_cob_2(pEmpresa, cProceso, CodRet, '', '03') RETURNING cCod_ret_2;  	

 RETURN CodRet,cMensajeRet;

END
 
END PROCEDURE
DOCUMENT
'Descripción: Procedimiento seccionar cuentas del TRIAD ',
'para los procesos de layout arch entrada TRIAD',
'AUTOR : MACF',
'FECHA : 2020-08-26',
'VERSION: 1.0.0',
'BD    : BDICRED'
;

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