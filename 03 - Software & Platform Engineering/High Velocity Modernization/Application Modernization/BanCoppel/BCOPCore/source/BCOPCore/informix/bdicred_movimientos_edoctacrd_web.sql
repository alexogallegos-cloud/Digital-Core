CREATE PROCEDURE "informix".movimientos_edoctacrd_web(cEmpresa CHAR(3), cNumCredito CHAR(20), dFechaEmision DATE,
                                              sNumRegistros SMALLINT)

    RETURNING CHAR(5), DATE, CHAR(20), SMALLINT, SMALLINT, DATE, CHAR(50),DECIMAL(14,2), DECIMAL(14,2);


    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE cNumeroCredito CHAR(20);
    DEFINE v_maximo SMALLINT;
    DEFINE v_contador SMALLINT;
    DEFINE v_fecha_mov_aux DATE;
------------------------------------------------
    DEFINE v_concepto        CHAR(50);
    DEFINE v_cargos          DECIMAL(14,2);
    DEFINE v_abonos          DECIMAL(14,2);
    DEFINE v_monto_det       DECIMAL(14,2);
    DEFINE v_naturaleza      CHAR (1);
    DEFINE v_cod_ref         INTEGER;
    DEFINE v_cod_fun         CHAR(3);
    DEFINE v_descripcion_det CHAR(255);
    DEFINE v_num_pago_am     INTEGER;
    DEFINE v_plazo           INTEGER;  
    DEFINE v_num_producto    CHAR(3);
    DEFINE vfechacentral     DATE;
    DEFINE v_periodo_tc_ini  DATE;		
    DEFINE v_periodo_tc_fin  DATE;		
    DEFINE v_cod_ret_otro	 CHAR(5);
    DEFINE v_periodo_anterior DATE;
    DEFINE v_dias_periodo_tc INTEGER;



    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr          = 0;
    LET cCodRet          = '00000';
--    LET dFechaDeEmision = '';
    LET cNumeroCredito   = '';
    LET v_maximo         = 0;
    LET v_contador       = 0;
    -----------------------------------------
    LET v_cargos         = 0;
    LET v_abonos         = 0;
    LET v_monto_det      = 0;
    LET v_naturaleza     = "";
    LET v_cod_ref        = 0;
    LET v_cod_fun        = "";
    LET  v_concepto      = ""; 
    LET v_descripcion_det = "";
    LET v_num_pago_am    = 0;
    LET v_fecha_mov_aux  = DATE(1); 
    LET v_plazo          = 0;
    LET v_num_producto   = "";
    LET vfechacentral    = DATE(1);
    LET v_periodo_tc_ini    = " ";		
    LET v_periodo_tc_fin    = " ";		
    LET v_cod_ret_otro      = "00000";	
    LET v_periodo_anterior  = " ";
    LET v_dias_periodo_tc 	= 0;


    --SET DEBUG FILE TO "/pisa/pisabanco/detalle_movs_edoctacrd.out";
    --TRACE ON;
    BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dFechaEmision, cNumeroCredito, v_maximo, v_contador, v_fecha_mov_aux,
                   v_concepto,v_cargos,v_abonos;
        END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT num_producto,plazo
          INTO v_num_producto,v_plazo
        FROM "informix".sd_maecredcrd
        WHERE empresa = cEmpresa
          AND num_credito = cNumCredito;
         

        SELECT fecha_hoy INTO vfechacentral
        FROM "informix".sd_fechas
		where empresa = cEmpresa;


            IF (vfechacentral <= dFechaEmision) then
                EXECUTE PROCEDURE "informix".sp_mes_siguiente(dFechaEmision,-1,DAY(dFechaEmision)) 
                INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
                LET v_periodo_tc_ini = v_periodo_anterior + 1 units day;
                LET v_periodo_tc_fin = vfechacentral;
            ELIF (vfechacentral >= dFechaEmision) then  
                let v_periodo_tc_ini = dFechaEmision + 1 units day;
                let v_periodo_tc_fin = vfechacentral;
            ELSE
                LET cCodRet = "00001";
                RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                       NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
                  WITH RESUME;
               
            END IF;


        -- GeneraciÃ³n de los Detalles de Movimientos del Estado de Cuenta
        FOREACH

            SELECT lpad(month(a.fecha_mov),2,0)||'/'||
                   lpad(day(a.fecha_mov),2,0)||'/'|| lpad(year(a.fecha_mov),4,0),
                   a.referencia,b.descripcion,a.monto,c.naturaleza,a.codigo_fun,a.codigo_ref
             INTO  v_fecha_mov_aux, v_concepto,v_descripcion_det, v_monto_det ,v_naturaleza, v_cod_fun,v_cod_ref 
            FROM "informix".sd_movhiscrd a,"informix".sd_transfun b, bdinteg:"informix".si_transacc  c
            WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
              AND c.numero = b.transacc AND c.se_emite_edocta = "S"
              AND fecha_mov >= case
              WHEN date(v_periodo_tc_ini - 1 UNITS MONTH) = (select fecha_apertura from "informix".sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
              THEN date(v_periodo_tc_ini - 1 UNITS MONTH)
              ELSE date(v_periodo_tc_ini - 1 UNITS MONTH + 1 units day) end
			  AND a.empresa = cEmpresa
              AND fecha_mov <= v_periodo_tc_fin
              AND num_credito = cNumCredito
			  AND c.sistema = "06"  ---Se agrega el campo sistema 
              AND a.reversado = "N"
              AND c.se_emite_edocta = "S"
              AND a.referencia <> 'PROV'
              AND a.num_producto = num_producto
              order by fecha_mov,secuencia,folio_suc


            IF v_naturaleza = "A" THEN
                LET v_abonos = v_monto_det;
                LET v_cargos = 0;
            ELSE
                LET v_cargos = v_monto_det;
                LET v_abonos = 0;
            END IF

            IF v_cod_fun = "222" AND v_cod_ref = 1 THEN
               LET v_descripcion_det = "";
               LET v_descripcion_det = TRIM(v_concepto) || " " || v_cargos;
               LET  v_cargos = 0;
               LET  v_abonos = 0;
            ELIF v_cod_fun = "222" AND v_cod_ref in (30,1119,1121) /*and (trim(v_concepto) = trim(v_num_pago_am::char(3)))*/ THEN
               LET v_descripcion_det = " - PAGO DE INT. VIG CON CARGO A CTA."|| Trim(v_concepto) || "/" || v_plazo;
               LET v_fecha_mov_aux = DATE(1);
            ELIF v_cod_fun = "222" AND v_cod_ref in (45,1120,1122) and (trim(v_concepto) = trim(v_num_pago_am::char(3))) THEN  
               LET v_descripcion_det = " - PAGO IVA INT. VIG CON CARGO A CTA. "|| Trim(v_concepto) || "/" || v_plazo;
               LET v_fecha_mov_aux = DATE(1);
            ELIF v_cod_fun = "001" AND v_cod_ref = 2 THEN

            ELIF v_cod_ref in (43,44) THEN

            ELSE
               LET v_fecha_mov_aux = DATE(1);
               LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
            END IF

            IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                LET v_contador = v_contador + 1;   
            ELSE
                LET v_maximo = v_maximo + 1;
                LET v_contador = 0;			    
                LET v_contador = v_contador + 1;			
            END IF;

            RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                   NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
              WITH RESUME;

            LET v_fecha_mov_aux  = date(1);
            LET v_concepto       = "";
            LET v_cargos         = 0;
            LET v_abonos         = 0;

        END FOREACH
    END;
END PROCEDURE
DOCUMENT
"Genera el Detalle de los Movimientos del Estado de Cuenta de CrÃ©dito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_ambientar_intereses_ree_pp() 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE pEmpresa         CHAR(3);

DEFINE cCod_ret         CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_credito      CHAR(12);
DEFINE vcredito_externo  CHAR(12);
DEFINE int_ven_bal      DECIMAL(16,2);

DEFINE contador_commit  INTEGER;
DEFINE total_indicador,vinteres_ree  DECIMAL(16,2);
DEFINE pfecha, pfecha_ini         DATE;

--SET DEBUG FILE TO "/RESPALDOSNEW/CUB_IFRS_Pruebas/IPCB/migracion_cony/sp_ambientar_indicador.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";

LET cCod_Ret        = '000000';

LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito     = "";
LET vcredito_externo = "";
LET int_ven_bal     = 0;


LET contador_commit = 0;
LET total_indicador = 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    LET pEmpresa = '001';
	
	select pri_dia_mes-1, pri_dia_mes - 1 units month INTO pfecha , pfecha_ini from bdicred:sd_fechas;

	
	/*
     SELECT a.num_credito, credito_externo            
            from bdicred:sd_maecredCONTcrd a inner join bdicred:sd_indicador_cred_crd b
            on a.num_credito = b.num_credito
            where  fecha = mdy('06','30','2021')
			and status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
            and (intereses_ree is null or intereses_ree = 0)
			--where fecha = mdy('09','30','2019')
		    --AND num_producto='6011'
And			num_producto='8600'
			--and a.num_credito in ('860000000023','860000000031')        
			into temp univ_ree with no log ;
			*/
		     
	SELECT a.num_credito, credito_externo-- ,intereses_ree           
	from bdicred:sd_maecredCONTcrd a  inner join bdicred:sd_indicador_cred_crd b
    on b.empresa = a.empresa and a.num_credito = b.num_credito
    where a.fecha = pfecha
	and num_producto='8600'
  --  and fecha_apertura >= pri_dia_mes and fecha_apertura <= pfecha
	into temp univ_ree with no log ;
			
    FOREACH WITH HOLD
		select *
		INTO vnum_credito, vcredito_externo
		FROM univ_ree
		--where vinteres_ree is null
		
		
		  SELECT nvl(sum(monto),0) intereses_vencidos_baja_cred -- BAJA DE LOS INTERESES DE BALANZA VENCIDO
                INTO int_ven_bal
                FROM bdicred:sd_movhiscrd
                WHERE empresa = '001' 
                    AND codigo_fun = '124' 
                    AND codigo_ref IN (5,25,962)
                    AND reversado = 'N'
                    AND num_credito = vcredito_externo; 
					
            LET total_indicador = int_ven_bal;

            BEGIN WORK;

                UPDATE bdicred:sd_indicador_cred_crd SET intereses_ree = total_indicador WHERE num_credito = vnum_credito;		
				LET contador_commit = contador_commit  + 1;
			
            COMMIT WORK;    
			
			LET total_indicador =0;
			LET int_ven_bal = 0;
			LET vinteres_ree = 0;
		
    END FOREACH;


    LET cCod_Ret = '000000';
    LET cMensajeRet = 'PROCESO CONCLUIDO, REGISTROS ACTUALIZADOS '||contador_commit;
    
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;