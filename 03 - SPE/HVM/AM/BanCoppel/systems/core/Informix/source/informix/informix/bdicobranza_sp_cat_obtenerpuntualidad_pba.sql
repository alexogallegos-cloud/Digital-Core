CREATE PROCEDURE "informix".sp_cat_obtenerpuntualidad_pba()
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

--SET DEBUG FILE TO "/ids10_uc9/macf/sp_cat_obtenerpuntualidad.out";
--TRACE ON;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;
   
   SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
   SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

   INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES('Obtener puntualidad', '11111', 'PROCESO INICIALIZADO', pUsuario, vdia, vhora);
      
   select limit 1 fecha_insert 
     into  vfecha_corte_mesant 
     from bdicobranza:cb_cat_directorio_cte;
   
   let vmonth_corte_mesant = month(vfecha_corte_mesant);
   let vyear_corte_mesant = year(vfecha_corte_mesant);
   
   --INSERT INTO cb_bitacora_cob (proceso, cod_ret, mensaje, fecha_insert) values('Obtener puntualidad', vmonth_corte_mesant, vyear_corte_mesant,vdia);
   
   if vmonth_corte_mesant > 1 and vmonth_corte_mesant <= 12 then  --del mes 2 al 12 
      let vmonth_corte_mesant = vmonth_corte_mesant - 1;
   else
      let vmonth_corte_mesant = 12; 
   end if; 
   
   select min(fecha_cierre)
   into vmax_fechacierre
   from bdicred:sd_hist_reserva
   where ( month(fecha_cierre) = vmonth_corte_mesant and year(fecha_cierre) = vyear_corte_mesant );
   
   select num_credito, porcentaje_reserva
    from  bdicred:sd_hist_reserva
   where  empresa = pEmpresa
     and  fecha_cierre = vmax_fechacierre
     and  grado_riesgo is not null
    into temp sel_hist_reserva with no log;
    create unique index inx_sel_hist_reserva on sel_hist_reserva(num_credito);
    UPDATE STATISTICS medium FOR TABLE sel_hist_reserva;    
          
   --INSERT INTO cb_bitacora_cob (proceso, fecha_insert) values('Obtener puntualidad', vmax_fechacorte);
  SET LOCK MODE TO WAIT 3;
   foreach
         select {+ INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_numcred)} num_credito
           into vnum_credito
           from bdicobranza:cb_cat_directorio_cte
         
         select porcentaje_reserva into vporcentaje_reserva
           from sel_hist_reserva
          where num_credito = vnum_credito;  
        
        if  vporcentaje_reserva = cGRADORIESGO_B1 then
            let vpuntualidad = 'A';
        else
            select limit 1 puntualidad into vpuntualidad 
              from bdicred:sd_grado_riesgo 
             where tipo = '1'
               and ( vporcentaje_reserva >= porcentaje_min  and vporcentaje_reserva <= porcentaje_max);
        end if;
           
         update bdicobranza:cb_cat_directorio_cte
           set puntualidad = vpuntualidad
         where num_credito = vnum_credito;
         
         --let vConta = vConta + 1;
         --if vConta = 20 then
         --   exit foreach;
         --end if;
                 
   end foreach;

   drop table sel_hist_reserva;

   SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
   SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
   
   INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('Obtener puntualidad', v_codret, cMensaje, pUsuario, vdia, vhora);
   
  RETURN v_codret;
END;

END PROCEDURE;