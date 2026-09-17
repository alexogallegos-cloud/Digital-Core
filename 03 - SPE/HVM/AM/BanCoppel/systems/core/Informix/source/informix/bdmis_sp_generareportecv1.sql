CREATE PROCEDURE "informix".sp_generareportecv1()
RETURNING varchar(6), varchar(80);

/**************************************************************************/
/* Fecha: 28/Enero/2008                                                   */
/* SPL: "informix".sp_generaReporteCV()                                   */
/* Actividad: Se encarga de generar datos para la tabla                   */
/* mi_carteravencidatota de donde se tomarán los datos para el reporte    */
/* de cartera vencida generado por el MIS                                 */
/* Realizado por: José Angel López Adams                                  */
/**************************************************************************/
/*Modificado por Manuel Osuna para Nuevos Campos requeridos para el
reporte asi como validaciones de los saldos 05/12/2008
*/
/**************************************************************************/
/*MODIFICADO POR JACQUELINE DOMINGUEZ PARA QUE VALIDE SI YA SE CONCLUYO EL 
  CIERRE DE CREDITO, SE PUEDE ENVIAR A EJECUCION EL PROCESO AUNQUE NO SE 
  HAYA REALIZADO EL CAMBIO DE FECHA DE CREDITO, ADEMAS CAMBIA LA 
  FECHA_ACTUAL Y LA FECHA_ANTERIOR DE bdmis:mi_fechas PARA QUE SE ESTE 
  REPORTE SE PUEDA VISUALIZAR AUNQ NO SE EJECUTE EL RCD. 05/10/2010
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  cCodRet                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  c_mensaje                   varchar(80);

DEFINE  iExiste                     integer;
DEFINE  cFecha                      char(10);
DEFINE  CierreCred                  char(10); -- (S)e hizo cierre , (N)o hay cierre


/*Variables para formateo de pFecha*/
DEFINE  cFechahoy              char(10);
DEFINE  dFechatime             Date;
DEFINE v_iAnio                 INTEGER;
DEFINE v_iMes                  INTEGER;
DEFINE v_idia                  CHAR(2);
DEFINE v_idiac                 CHAR(2);
DEFINE v_iMesc                 CHAR(2);
DEFINE  dFecha1                char(10);
DEFINE  dFecha                 Date;
DEFINE  vcontrol_asoc          CHAR(20);
DEFINE  vstatus_proc           CHAR(1);
DEFINE v_idiaa                 CHAR(2);
DEFINE v_idiaac                CHAR(2);
DEFINE  dFechaa1               char(10);
DEFINE v_iMesa                 INTEGER;
DEFINE v_iMesca                CHAR(2);
DEFINE  dFechatimea            Date;
DEFINE v_iAnioa                INTEGER;
DEFINE  dFechaa1p              char(10);
DEFINE  cFechahoymis           char(10);
DEFINE  cFechamis              char(10);
DEFINE  v_maxfechacv           Date;
--DEFINE v_difdias                 INTEGER; 
DEFINE v_difdias                char(10);
/***********************************/
/*Variables para validacion de fechas a considerar de proceso 29-12-2011*/
DEFINE  dFechaserv             Date;        -- Fecha del servidor
DEFINE  dFechasif              Date;        -- Fecha del Sistema SIF
DEFINE  dFechaproc             Date;        -- Fecha determinada de proceso
DEFINE  dFechaulproc           Date;        -- Fecha de ultima ejecucion del proceso
DEFINE  dFechasigproc          Date;        -- Fecha de siguiente ejecucion del proceso
/* 
**********************************
-- ** HLA ** Variables para cambio de fecha sin afectación a campo diavisa (hasta que lgomez lo retire)
DEFINE	bempresa			char(3);
DEFINE	bfecha_hoy			date;
DEFINE	bfecha_ant			date;
DEFINE	bprox_fecha			date;
DEFINE	bpri_dia_mes		date;
DEFINE	bpri_hab_mes		date;
DEFINE	bult_dia_mes		date;
DEFINE	bult_hab_mes		date;
/**********************************
*/


  --  SET DEBUG FILE TO "/home/informix/jydg/sp_generareportecv1.out";
  --  TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;

    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';
    LEt iExiste = 0;
    LET vcontrol_asoc = '';
    LET vstatus_proc  = '';

	SET ISOLATION TO DIRTY READ;

--Dia Actual    
    let dFechatime = today;
    --let dFechatime = '01/01/2011';
    --'01/02/2011', '12/31/2010';
    let dFechatime = dFechatime;
--Dia Anterior
    let dFechatimea = dFechatime-1;
    let dFechatimea = dFechatimea;
--Fechas del MIS
    let cFechahoymis = '';
    let cFechamis    = '';
--Fecha Máxima Procesada de la Cartera Vencida del MIS
    let v_maxfechacv   = '';
-- Guarda la diferencia de dias que hay entre lo ya procesado en CV y la fecha a procesar
    let v_difdias = 0;
   
   /*Formateo de pFecha*/
    LET v_iAnio = 0;
    LET v_iMes = 0;
    LET v_idia = 0;
    LET v_iMesc = '01';
    LET v_iMesa = 0;
    LET v_iMesca = '01';

	/***********************************/
	/*Determinacion de la fecha de proceso (29-12-2011)*/
	let dFechaserv = today;
	select max(fecha) into dFechaulproc from mi_CarteraVencidaTotal;
	SELECT fecha_hoy INTO  dFechasif FROM bdinteg:si_fechas;
	if   (dFechaserv <= dFechasif) then
	     SELECT fecha_ant INTO  dFechaproc FROM bdinteg:si_fechas;
		 SELECT fecha_hoy INTO  dFechasigproc FROM bdinteg:si_fechas;
	else
	     SELECT fecha_hoy INTO  dFechaproc FROM bdinteg:si_fechas;
		 SELECT prox_fecha INTO  dFechasigproc FROM bdinteg:si_fechas;
	end if;
	
	/*Verifica si es valida la ejecucion del proceso (29-12-2011)*/
	select ((dFechaproc - dFechaulproc) units day) into v_difdias from bdmis:mi_fechas;
	
	if   v_difdias = 0 then 
	        LET vcodret = '--1';
            LET p_mensaje = 'FECHA YA PROCESADA ';
    else
         select trim(control_asoc) into vcontrol_asoc from bdinteg:sx_plejec_det where nombre_programa = 'provisionlineacred';
		 select trim(status_proc) into vstatus_proc   from bdicred:sd_contproc  where empresa = '001'  AND trim(proceso) = vcontrol_asoc AND fecha = dFechaproc; 
         if (vstatus_proc <> 'F') then
		    LET vcodret = '005';
            LET p_mensaje = 'FALTA CIERRE CREDITO ';
	     else
            let cFecha = dFechaproc;
		 end if;
    end if;
	
	/***********************************/
	
/* Se deshabilita secuencia de codigo original de validacion de proceso  (29-12-2011)	
	
--Fecha actual
    LET v_iAnio = YEAR(dFechatime);
    LET v_iMes = LPAD(MONTH(dFechatime),2,0);
    LET v_idia = LPAD(DAY(dFechatime),2,0);
--Fecha anterior
    LET v_iAnioa = YEAR(dFechatimea);
    LET v_iMesa = LPAD(MONTH(dFechatimea),2,0);
    LET v_idiaa = LPAD(DAY(dFechatimea),2,0);

--Formato de Fecha actual
    if v_iMes < 10 then 
        LET v_iMesc= 0||v_iMes;
    else 
        LET v_iMesc= v_iMes;
    end if;

    if length(v_idia) < 2 then 
        LET v_idiac= 0||v_idia;
    else 
        LET v_idiac= v_idia;
    end if;

-- Formato Para el dia anterior
    if v_iMesa < 10 then 
        LET v_iMesca= 0||v_iMesa;
    else 
        LET v_iMesca= v_iMesa;
    end if;

    if length(v_idiaa) < 2 then 
        LET v_idiaac= 0||v_idiaa;
    else 
        LET v_idiaac= v_idiaa;
    end if;

-- Se utiliza formato de fecha de acuerdo a la tabla  
      LET dFecha1 = v_iMesc||'/'||v_idiac||'/'||v_iAnio;      -- FECHA DEL DIA DEL SERVIDOR
      LET dFechaa1 = v_iMesca||'/'||v_idiaac||'/'||v_iAnioa;    -- FECHA DEL DIA ANTERIOR DEL SERVIDOR
      LET dFechaa1p = v_iMesca||v_idiaac||v_iAnioa;             -- FECHA DEL DIA ANTERIOR DEL SERVIDOR  solo cambia el formato sin /

--    if ((v_iMesc = 12 and v_idiac = 25) or (v_iMesca = 12 and v_idiaac = 25) /*or (v_iMesc = 01 and v_idiac = 02) or (v_iMesca = 01 and v_idiaac = 01)* /) THEN
--        LET vcodret = '006';
--        LET p_mensaje = 'NO SE PROCESA DIA INHABIL ';
         
--    else
        if  ((month(dfechaa1) = 01 and day(dfechaa1) = 01))  then
           select max(fecha) into v_maxfechacv from mi_CarteraVencidaTotal;
           LET cFecha = dFecha1;
           select ((cFecha - v_maxfechacv) units day) into v_difdias from bdmis:mi_fechas; 
                if v_difdias > 1 then 
                    SELECT fecha_ant INTO  cFechamis FROM bdmis:mi_fechas; 

                    LET cFecha = cFechamis ;
                    LET dfechaa1 = cFecha;
                end if;
        --Fecha para buscar el cierre
            LET v_iAnioa = YEAR(dfechaa1);
            LET v_iMesa = LPAD(MONTH(dfechaa1),2,0);
            LET v_idiaa = LPAD(DAY(dfechaa1),2,0);

                if v_iMesa < 10 then 
                    LET v_iMesca= 0||v_iMesa;
                else 
                    LET v_iMesca= v_iMesa;
                end if;

                if length(v_idiaa) < 2 then 
                    LET v_idiaac= 0||v_idiaa;
                else 
                    LET v_idiaac= v_idiaa;
                end if;

        LET dFechaa1p = v_iMesca||v_idiaac||v_iAnioa;             -- FECHA DEL DIA ANTERIOR DEL SERVIDOR  solo cambia el formato sin /

        select trim(status_proc) into vstatus_proc 
        from bdicred:sd_contproc where empresa = '001'  AND trim(proceso) = vcontrol_asoc AND fecha = dFechaa1p; 
        --'CierreCred'
        end if;
--    end if; 

if vcodret = '000' or ( vcodret = '006' and (month(dFechaa1p) = 01 and day(dFechaa1p) = 01)) then
    select trim(control_asoc) into vcontrol_asoc 
    from bdinteg:sx_plejec_det where nombre_programa = 'provisionlineacred';
    LET vcontrol_asoc = vcontrol_asoc;

    select trim(status_proc) into vstatus_proc 
    from bdicred:sd_contproc where empresa = '001'  AND trim(proceso) = vcontrol_asoc AND fecha = dFechaa1p; 
    --'CierreCred'
    LET vstatus_proc  = vstatus_proc;

    SELECT fecha_hoy, fecha_ant INTO cFechahoy, cFecha FROM bdicred:sd_fechas; 
    SELECT fecha_hoy, fecha_ant INTO cFechahoymis, cFechamis FROM bdmis:mi_fechas; 

      LET dFecha1   = dFecha1;          -- FECHA DEL DIA DEL SERVIDOR
      LET dFechaa1  = dFechaa1;         -- FECHA DEL DIA ANTERIOR DEL SERVIDOR
      LET cFechahoy = cFechahoy;        -- FECHA CREDITO DEL DIA ACTUAL
      LET cFecha    = cFecha;           -- FECHA CREDITO DEL DIA ANTERIOR
      LET cFechahoymis = cFechahoymis;  -- FECHA MIS DEL DIA ACTUAL
      LET cFechamis    = cFechamis;     -- FECHA MIS DEL DIA ANTERIOR
   

    if (vstatus_proc = 'F') then 
            if ( dFecha1 = cFechahoy )  then 
                let cFecha = dFechaa1 ;
            else
                let cFecha = dFecha1; 
                -- Se realiza el cambio de fechas para que se pueda consultar
                if cFechahoymis <> dFecha1 then 
                    update bdmis:mi_fechas set fecha_hoy = dFecha1, fecha_ant = dFechaa1;
                end if;
            end if;
    else
        LET vcodret = '005';
        LET p_mensaje = 'FALTA CIERRE CREDITO ';
    end if;

end if;

if vcodret = '000' or ( vcodret = '006' and (month(cFecha) = 01 and day(cFecha) = 01)) then 
    select max(fecha) into v_maxfechacv from mi_CarteraVencidaTotal;
    select ((cFecha - v_maxfechacv) units day) into v_difdias from bdmis:mi_fechas; 
--    let = ((cFecha - v_maxfechacv) units day);
    if v_difdias > 1 then 
        LET cFecha = dfechaa1 ;
        LET vstatus_proc  = vstatus_proc;
        if cFecha > v_maxfechacv then 
            LET vcodret = '000';
        else
            LET vcodret = '--1';
            LET p_mensaje = 'Fecha ya Procesada '  ;
        END IF;
    end if;


    if ((month(cFecha) = 12 and day(cFecha) = 25) or ((month(cFecha) = 01 and day(cFecha) = 01))) THEN
            LET vcodret = '006';
            LET p_mensaje = 'DIA INHABIL NO SE PROCESA ' ;
    end if;
end if;

Termina deshabilitación de codigo de validacion de fechas (29-12-2011) */

 if vcodret = '000' then 
	IF NOT EXISTS(SELECT numpagos FROM bdmis:mi_CarteraVencidaTotal WHERE fecha = cFecha) THEN

		INSERT INTO mi_CarteraVencidaTotal (ident,numpagos, numcreditos, capitalvigente, capitaltransitorio,
        capitalvdoexigible, capitalvdonoexigible,interesdelperiodo,interesvencido,interesmoratorios,fecha)
		select  ident,pagoven as numpagos,count(pagoven) as numcreditos ,
		sum(sdo_capital) as capitalvigente,
		sum(monto_vencido) as capitaltransitorio,
		sum(mto_venc_trasp) as capitalvdoexigible,
		sum(cap_tras_no_venci) as capitalvdonoexigible,
		sum(sdo_no_exig) as interesdelperiodo,
		sum(int_tra_no_exig) as interesvencido,
		sum(mora) as interesmoratorios,cFecha
		from table ( multiset (
		SELECT a.numcte, a.num_credito,
				(SELECT count(*) FROM bdicred:sd_amortiza_credito g WHERE g.empresa=a.empresa AND g.num_credito=a.num_credito AND capital_status IN ('7','2','6')) as pagoven,
				(SELECT  nvl(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag),0)
				FROM bdicred:sd_amortiza_credito g WHERE g.empresa=a.empresa AND g.num_credito=a.num_credito AND capital_status IN ('7','2','6')) as mora,
				case when sdo_cap_insoluto < 0 then '<0'
							when sdo_cap_insoluto = 0 then '=0'
							when sdo_cap_insoluto > 0 then '>0'
				end ident ,
				sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci,sdo_no_exig,int_tra_no_exig,
				monto_financiado   FROM bdicred:sd_maecred a
                                inner join bdicred:sd_maesdos b  on (b.empresa = a.empresa  and b.num_credito = a.num_credito)
                                inner join bdicred:sd_maecredanexo c on (c.empresa=a.empresa and c.num_credito=a.num_credito)
                                where a.empresa='001' and a.num_credito>0 and a.status_cred not in ('CV')
								and a.campo_trab3 <> 'BAJA'
        and (cod_caract_2 is null or cod_caract_2 NOT IN ('BC1','BC2'))
		))
		group by 1,pagoven;

	ELSE
		LET vcodret = '--1';
		LET p_mensaje = 'Fecha ya Procesada ' ;

	END IF;
 end if;
 
/***********************************/
/*  Cambio de logica para actualizar fecha de Mis (29-12-2011) */    
 
/*      Anula logica para actualizar fecha de Mis (29-12-2011)
 IF vcodret = '000' THEN
   UPDATE bdmis:mi_fechas
   SET fecha_hoy = today,
       fecha_ant = today -1,
       prox_fecha = today + 1;
END IF;
*/ 

-- Nueva logica para actualizar fecha MIS (29-12-2011) 
IF vcodret = '000' THEN
   UPDATE bdmis:mi_fechas
   SET fecha_hoy = dFechasigproc,
       fecha_ant = dFechaproc,
       prox_fecha = dFechasigproc;

/*
	select empresa,fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes
	into bempresa, bfecha_hoy, bfecha_ant, bprox_fecha, bpri_dia_mes, bpri_hab_mes, bult_dia_mes, bult_hab_mes
	from bdinteg:si_fechas;
	
	update bdmis:mi_fechas set
	empresa = bempresa, fecha_hoy = bfecha_hoy, fecha_ant = bfecha_ant,
	prox_fecha = bprox_fecha, pri_dia_mes = bpri_dia_mes, pri_hab_mes = bpri_hab_mes,
	ult_dia_mes = bult_dia_mes, ult_hab_mes = bult_hab_mes where empresa = '001';
*/
END IF;
/***********************************/

RETURN vcodret, p_mensaje;
END;
END PROCEDURE;