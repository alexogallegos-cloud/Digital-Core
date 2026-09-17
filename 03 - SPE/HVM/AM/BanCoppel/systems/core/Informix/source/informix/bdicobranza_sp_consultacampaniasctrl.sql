CREATE PROCEDURE "informix".sp_consultacampaniasctrl(pEmpresa CHAR(3), pTipoCampania SMALLINT, pNumParam INTEGER, pGrupoParam CHAR(10))
RETURNING
	CHAR(6) AS COD_RET, ---cod_ret
	CHAR(100) AS DESCRIPCION, ---descripcion
    CHAR(100) AS VALOR_ALFAB,
    DECIMAL(18,2) AS VALOR_NUM;
	
	---DECLARACIONES
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cErrorInfo           CHAR(80);
    DEFINE cCodRet              CHAR(6);
    DEFINE cMensajeRet          CHAR(100);
    DEFINE iRows                INTEGER;
    DEFINE cValorAlfabetico     CHAR(100);
    DEFINE dValorNumerico       DECIMAL(18,2);
	DEFINE cDescripcion			CHAR(100);

	---INICIALIZACIONES
    LET iSqlErr                 = 0;
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";
    LET cCodRet                 = "000000";
    LET cMensajeRet             = "PROCESO EXITOSO";
    LET iRows                   = 0;
    LET cValorAlfabetico        = "";
    LET dValorNumerico          = 0.0;
	LET cDescripcion			= "";

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN TRIM(NVL(cCodRet,"")), TRIM(NVL(cDescripcion,"")), TRIM(NVL(cValorAlfabetico,"")), NVL(dValorNumerico,0.0) ;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	/*SET DEBUG FILE TO "/respaldosbd/josue/sp_ConsultaCampaniasCtrl.out";
	TRACE ON;*/
	
		-- SE VALIDA QUE NO VENGAN PARAMETROS NULOS
    IF pEmpresa = "" OR  pTipoCampania = 0 OR pGrupoParam = "" THEN
        LET cCodRet = "000001";
        LET cMensajeRet = "INVALIDOS PARAMETROS DE ENTRADA";
        RETURN TRIM(NVL(cCodRet,"")), TRIM(NVL(cDescripcion,"")), TRIM(NVL(cValorAlfabetico,"")), NVL(dValorNumerico,0.0) ;
   
    ELSE 
		FOREACH 
			SELECT NVL(descripcion,""), NVL(valor_alfabetico,""), NVL(valor_numerico,0)
			INTO cDescripcion, cValorAlfabetico, dValorNumerico
			FROM  "informix".cb_param_campania
			WHERE empresa = pEmpresa
			AND tipo_campania = DECODE(pTipoCampania,0,tipo_campania,pTipoCampania)
			AND num_parametro = DECODE(pNumParam,0,num_parametro,pNumParam)
			AND grupo_parametro = DECODE(pGrupoParam,'',grupo_parametro,pGrupoParam)
			
			
			RETURN TRIM(NVL(cCodRet,"")), TRIM(NVL(cDescripcion,"")), TRIM(NVL(cValorAlfabetico,"")), NVL(dValorNumerico,0.0) WITH RESUME;
		END FOREACH 
	END IF
    LET iRows = dbinfo("sqlca.sqlerrd2");
    
    IF iRows = 0 THEN
        LET cCodRet = "000002";
        LET cMensajeRet = "NO HAY DATOS CON LOS PARAMETROS RECIBIDOS";
        RETURN TRIM(NVL(cCodRet,"")), TRIM(NVL(cDescripcion,"")), TRIM(NVL(cValorAlfabetico,"")), NVL(dValorNumerico,0.0) ;
    END IF
	        
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta con información standar para las aplicaciones de Cobranzas', 
'AUTOR: Josue R. Zazueta ',
'FECHA: Noviembre 30 del 2012',
'VERSION: 20121130.1141';

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