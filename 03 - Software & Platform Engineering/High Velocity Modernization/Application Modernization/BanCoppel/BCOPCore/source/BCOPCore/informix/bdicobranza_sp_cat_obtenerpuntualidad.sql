CREATE PROCEDURE "informix".sp_cat_obtenerpuntualidad()
 returning char(5);

define v_codret char(5);
define v_sqlerr integer;
define v_isamerr integer;
define vfecha_corte_mesant date;
define vmonth_corte_mesant integer;
define vyear_corte_mesant integer;
define vmax_fechacierre date;
define vnum_credito char(20);
define vpuntualidad char(1); 
define vdia date;
define vhora char(8);
define cMensaje char(80);
define pUsuario char(8);
define pEmpresa char(3);
define vConta smallint;
define vporcentaje_reserva decimal(18,2);
define cGRADORIESGO_B1 decimal(3,2);
define vtipo_cobranza  CHAR(1);
define vfecha_insert date;
DEFINE vday				INTEGER;
DEFINE vnum_prod		CHAR(4);
DEFINE vbandera			CHAR(1);

let v_codret            = "00000";
let v_sqlerr            = 0;
let v_isamerr           = 0; 
let vfecha_corte_mesant = '01-01-1900';
let vmonth_corte_mesant = 0;
let vyear_corte_mesant  = 0;
let vmax_fechacierre     = '01-01-1900';
let vnum_credito        = "";
let vpuntualidad        = "";
let vdia                = '01-01-1900';
let vhora               = "";
let cMensaje            = 'PROCESO EXITOSO';
let pUsuario            = user;
let pEmpresa            = '001';
let vConta              = 0;
let vporcentaje_reserva = 0.00;
let cGRADORIESGO_B1     = 2.68;
LET vday 				= 0;
LET vnum_prod 			= '';
LET vbandera 			= '';

--SET DEBUG FILE TO "sp_cat_obtenerpuntualidad.out";
--TRACE ON;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   SELECT CURRENT::DATE INTO vdia from bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
   SELECT CURRENT::DATETIME HOUR TO SECOND INTO vhora from bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

	BEGIN WORK;
		INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
			VALUES('Obtener puntualidad', '11111', 'PROCESO INICIALIZADO', pUsuario, vdia, vhora);
	COMMIT WORK;
      
/*   select limit 1 fecha_insert 
     into  vfecha_corte_mesant 
     from bdicobranza:cb_cat_directorio_cte;
   
   let vmonth_corte_mesant = month(vfecha_corte_mesant);
   let vyear_corte_mesant = year(vfecha_corte_mesant);
   
   --INSERT INTO cb_bitacora_cob (proceso, cod_ret, mensaje, fecha_insert) values('Obtener puntualidad', vmonth_corte_mesant, vyear_corte_mesant,vdia);
   
   if vmonth_corte_mesant > 1 and vmonth_corte_mesant <= 12 then  --del mes 2 al 12 
      let vmonth_corte_mesant = vmonth_corte_mesant - 1;
   else
      let vmonth_corte_mesant = 12; 
   end if; */
   
 /*  select min(fecha_cierre)
   into vmax_fechacierre
   from bdicred:sd_hist_reserva
   where ( month(fecha_cierre) = vmonth_corte_mesant and year(fecha_cierre) = vyear_corte_mesant );

	IF DAY(vtoday) < 20 THEN
		LET vday = 18;
	ELIF DAY(vtoday) > 19 THEN
		LET vday = 20;
	END IF;*/

	SELECT MAX(fecha_insert) INTO vmax_fechacierre
		FROM bdicobranza:cb_cat_directorio_cte
		WHERE empresa = pEmpresa AND  tipo_cobranza = 'A';

	LET vday = DAY(vmax_fechacierre);

	FOREACH WITH HOLD
		SELECT valor_alfabetico INTO vnum_prod
		FROM "informix".cb_param_campania 
		WHERE empresa = pEmpresa AND tipo_campania = 61
		AND grupo_parametro = 'A'
		AND valor_numerico = vday
	
		IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

		SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pEmpresa AND valor = vnum_prod;

		IF vbandera IS NULL THEN LET vbandera = ''; END IF;

		IF vbandera = 'N' OR vbandera = '' THEN
			LET vbandera = '';
			CONTINUE FOREACH;
		END IF;

		SELECT MAX(fecha_insert) INTO vmax_fechacierre
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE empresa = pEmpresa AND  tipo_cobranza = 'A' AND num_producto = vnum_prod;

/*   select cte.num_credito, nvl(re.porcentaje_reserva,0)porcentaje_reserva, cte.tipo_cobranza, cte.fecha_insert
    from bdicobranza:cb_cat_directorio_cte cte
    left outer join bdicred:sd_hist_reserva re
			on (re.empresa = cte.empresa and re.num_credito = cte.num_credito 
					and re.fecha_cierre = mdy(month(cte.fecha_insert),'01',year(cte.fecha_insert)) - 1 units day 
					and grado_riesgo is not null)
	where tipo_cobranza = 'A'
	  and fecha_insert = vmax_fechacierre 
    into temp sel_hist_reserva with no log;*/

	   select num_credito, tipo_cobranza, fecha_insert
		from bdicobranza:cb_cat_directorio_cte 
		where tipo_cobranza = 'A'
		  and fecha_insert = vmax_fechacierre 
		  AND num_producto = vnum_prod
		into temp sel_hist_reserva with no log;

		create index inx_sel_hist_reserva on sel_hist_reserva(num_credito) ONLINE;
		UPDATE STATISTICS medium FOR TABLE sel_hist_reserva;    

   --INSERT INTO cb_bitacora_cob (proceso, fecha_insert) values('Obtener puntualidad', vmax_fechacorte);

		foreach with hold

			/* select {+ INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_numcred)} num_credito
			   into vnum_credito
			   from bdicobranza:cb_cat_directorio_cte 
			 */
			 select num_credito,tipo_cobranza,fecha_insert  
			   into vnum_credito,vtipo_cobranza,vfecha_insert 
			   from sel_hist_reserva WHERE num_credito > ''

			select porcentaje_reserva
			  into vporcentaje_reserva
			  from bdicred:sd_hist_reserva 
			 where empresa = pEmpresa
			   and num_credito = vnum_credito 
			   and fecha_cierre = mdy(month(vfecha_insert),'01',year(vfecha_insert)) - 1 units day 
			   and grado_riesgo is not null;
			   
			IF vporcentaje_reserva IS NULL THEN LET vporcentaje_reserva = 0; END IF;

			if  vporcentaje_reserva = cGRADORIESGO_B1 then
				let vpuntualidad = 'A';
			else
				select limit 1 puntualidad into vpuntualidad 
				  from bdicred:sd_grado_riesgo 
				 where empresa = pEmpresa
				   and tipo = '1'
				   and ( vporcentaje_reserva >= porcentaje_min  and vporcentaje_reserva <= porcentaje_max);
			end if;

			BEGIN WORK;
				 update bdicobranza:cb_cat_directorio_cte
					set puntualidad = vpuntualidad
				  where empresa = pEmpresa
					and tipo_cobranza = vtipo_cobranza
					and fecha_insert = vfecha_insert 
					and num_credito = vnum_credito
					AND num_producto = vnum_prod;
			COMMIT WORK;

			let vpuntualidad = null;
			let vporcentaje_reserva = 0;
			 --let vConta = vConta + 1;
			 --if vConta = 20 then
			 --   exit foreach;
			 --end if;                 
		end foreach;

		drop table sel_hist_reserva;
	END FOREACH;

   SELECT CURRENT::DATE INTO vdia from bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
   SELECT CURRENT::DATETIME HOUR TO SECOND INTO vhora from bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

	BEGIN WORK;
	   INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
				VALUES('Obtener puntualidad', v_codret, cMensaje, pUsuario, vdia, vhora);
	COMMIT WORK;

  RETURN v_codret;
END;

END PROCEDURE;