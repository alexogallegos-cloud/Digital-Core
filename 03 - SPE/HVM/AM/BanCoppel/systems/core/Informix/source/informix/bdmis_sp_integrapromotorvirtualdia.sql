CREATE procedure "informix".sp_integrapromotorvirtualdia()
    RETURNING char(5),
          char(120);

    --##############################################################################
    --## Procedimiento       :sp_integrapromotorvirtual
    --## Version             : 1.0.0
    --## Objetivo            : Actualizar el Promotor Virtual en las tablas
    --##                       mi_rptcierresuc, mi_rptcierresucpgeneral y mi_rptcierresucacumulejecut
    --##                       llamado desde sp_replicacierrediario antes de poblar tmp_cifrascierresuc
    --## Supuestos           :
    --## Valores Entrada     : pPeriodo --> Periodo a procesar
    --## Valores Retorno     : CodRet -->   Código de Retorno.
    --## Creado por          : Luis Antonio Gómez Santiago
    --## Fecha creacion      : Febrero 2010
    --##############################################################################

    define cCodret            char(5);
    define sql_err            integer;
    DEFINE cVarDataErr        char(120);
    DEFINE iSamErr            INTEGER;

    DEFINE iFechaHoy          INTEGER;
    DEFINE iCuantos           INTEGER;

    DEFINE paso_nombre        CHAR(45);

    DEFINE v_ejecutivo        CHAR(8);
    DEFINE v_empresa          CHAR(3);
    DEFINE v_producto         CHAR(4);
    DEFINE v_sucursal         CHAR(4);
	DEFINE v_num_ctasmes	  INTEGER;
	
	DEFINE v_monto_ctasmes          	money;
	DEFINE v_p_cumpmetactasmes      	money;
	DEFINE v_meta_ctasmes           	int;
	DEFINE v_monto_incrementomes    	money;
	DEFINE v_meta_incrementomes     	money;
	DEFINE v_p_cumpsaldomes         	money;
	DEFINE v_num_abonosctascapmes   	int;
	DEFINE v_monto_abonosctascapmes 	money;
	DEFINE v_num_abonosctascredmes  	int;
	DEFINE v_monto_abonosctascredmes	money;
	DEFINE v_p_rec_vs_pagominmes    	money;
	DEFINE v_p_rec_vs_vencidomes    	money;
	DEFINE v_num_clientel_actmes    	int;
	DEFINE v_num_compagomes         	int;
	DEFINE v_num_acuerdopagomes     	int;
	DEFINE v_num_cons_edoctames     	int;
	DEFINE v_num_retirocaptames     	int;
	DEFINE v_monto_retirocaptames   	money;
	DEFINE v_num_retirocolocames    	int;
	DEFINE v_monto_retirocolocames  	money; 		

    DEFINE vsFlagEnTransaccion CHAR(1);
    DEFINE viContadorRegistros INTEGER;
    DEFINE viContadorRegistros2 INTEGER;
    define paso                smallint;
	define vaniomes				char(06);
	
    BEGIN
        on exception set sql_err
          if sql_err <> 0 then
                    let cCodret = sql_err;
                    return cCodret,'';
          end if;
        end exception;
            LET cVarDataErr = "";

 --       Set debug file to "gli_sp_integrapromotorvirtualdia_prueba_229.out";
 --       Trace on;

        let cCodret = "000";
        let paso_nombre = "PROMOTOR VIRTUAL";
		let v_num_ctasmes = 0;

    --// ********************************************************************
    --// Busca si ya existen las Temporales
    --// ********************************************************************
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSuc')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSuc;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucPGeneral')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSucPGeneral;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucAcumulEjecut')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpmi_rptcierresucacumulejecut;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCajerosSucDia')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCajerosSucDia;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmp_acumulejecut')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_acumulejecut;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmp_acumulejecutOk')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmp_acumulejecutOk;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucOk')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSucOk;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucPGeneral')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSucPGeneral;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucPGeneralbaja')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSucPGeneralbaja;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_RptCierreSucPGeneralCajeros')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_RptCierreSucPGeneralCajeros;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_AcumulEjecutCajeros')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_AcumulEjecutCajeros;
            END IF
            EXECUTE PROCEDURE sp_buscatemporal('tmpMi_CierreSucPGeneralok')
               INTO cCodret, cVarDataErr, iCuantos;
            IF cCodret = '000' THEN
               DROP TABLE tmpMi_CierreSucPGeneralok;
            END IF

            LET cCodret = '000';
            LET paso    = 1;

--optiene aniomes
		set isolation to dirty read;
		
		select distinct(aniomes) 
		into vaniomes
		from mi_rptcierresucacumulejecut;
		
--PASO 1) ELIMINA LOS REGISTROS QUE CONTENGAN LA CREACION PREVIA DE PROMOTOR VIRTUAL
          
          BEGIN WORK; 
            delete from mi_rptcierresuc
            where sucursal = substr(ejecutivo,5,4) and 
                  (nombre is null or nombre = 'PROMOTOR VIRTUAL');
          COMMIT WORK;

          BEGIN WORK; 
            delete from mi_rptcierresucpgeneral
            where sucursal = substr(ejecutivo,5,4) and
                (nombre is null or nombre = 'PROMOTOR VIRTUAL');
          COMMIT WORK;         
		
			select sucursal, ejecutivo, producto, num_ctasmes,
			monto_ctasmes, p_cumpmetactasmes, meta_ctasmes, monto_incrementomes, meta_incrementomes,
			p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes, num_abonosctascredmes,
			monto_abonosctascredmes, p_rec_vs_pagominmes, p_rec_vs_vencidomes, num_clientel_actmes,
			num_compagomes, num_acuerdopagomes, num_cons_edoctames, num_retirocaptames, monto_retirocaptames,
			num_retirocolocames,monto_retirocolocames 
			from mi_rptcierresucacumulejecut 
			where sucursal = substr(ejecutivo,5,4) and
			( nombre is null or nombre = 'PROMOTOR VIRTUAL')
			and num_ctasmes > 0
			into temp tmp_aculejecut;
		
          BEGIN WORK; 
            delete from mi_rptcierresucacumulejecut
            where sucursal = substr(ejecutivo,5,4) and
                (nombre is null or nombre = 'PROMOTOR VIRTUAL');
          COMMIT WORK;

            LET paso    = 2;

--PASO 2) CARGA EN TABLAS TEMPORALES LOS EJECUTIVOS QUE SON CAJEROS ACTIVOS DE mi_rptcierresuc, mi_rptcierresucpgeneral, mi_rptcierresucacumulejecut

          /*Carga las tablas temporales con los registros de los movimientos para los ejecutivos que son CAJEROS DE mi_rptcierresuc*/
          select a.empresa, a.sucursal,              
                      (select sc.promotor_virtual 
                         from bdmis:mi_sucursalesinfo sc
                        where sc.num_sucursal = a.sucursal) as ejecutivo,             
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 'Promotor cajero' as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, 0 as meta_ctasdia, 0 as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca  
          from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b 
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                and b.password = 'BAJA') or 
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                and b.password <> 'BAJA')
          group by 1,2,5,3,6
          INTO TEMP tmpMi_RptCajerosSucDia;
           
          /* Obtiene la información para los promotores dados de CAJEROS que estan en mi_rptcierresucpgeneral*/
          select a.empresa, a.sucursal,
               (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                 where sc.num_sucursal = a.sucursal) as ejecutivo,
                'PROMOTOR VIRTUAL' as nombre, a.fecha_cierre,
--                paso_nombre as nombre, a.fecha_cierre,
                sum(p_cumdia_capta) as p_cumdia_capta, sum(p_cumdia_coloca) as p_cumdia_coloca, sum(p_cumdia_saldo) as p_cumdia_saldo,
                sum(p_cumdia_tdc) as p_cumdia_tdc, sum(p_cumdia_general) as p_cumdia_general, sum(p_cummes_capta) as p_cummes_capta,
                sum(p_cummes_coloca) as p_cummes_coloca, sum(p_cummes_saldo) as p_cummes_saldo, sum(p_cummes_tdc) as p_cummes_tdc,
                sum(p_cummes_general) as p_cummes_general
          from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and            
                b.puesto in ('004', '002') and  -- Cajeros 
                b.password = 'BAJA') or				
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                )
          group by 1, 2, 3, 5
          INTO TEMP tmpMi_RptCierreSucPGeneralCajeros;
		  
		  

          /* Obtiene la información para los promotores dados de CAJEROS que estan en mi_rptcierresucacumulejecut*/
          select a.empresa, a.sucursal, 
                 (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                  where sc.num_sucursal = a.sucursal) as ejecutivo,
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.aniomes,  
--                 paso_nombre as nombre, a.producto, a.aniomes,  
                 sum(a.num_ctasmes) as num_ctasmes, sum(a.monto_ctasmes) as monto_ctasmes, 0 as p_cumpmetactasmes,  
                 0 as meta_ctasmes, sum(a.monto_incrementomes) as monto_incrementomes, 0 as meta_incrementomes,
                 0 as p_cumpsaldomes, sum(a.num_abonosctascapmes) as num_abonosctascapmes, sum(a.monto_abonosctascapmes) as monto_abonosctascapmes,
                 sum(a.num_abonosctascredmes) as num_abonosctascredmes, sum(a.monto_abonosctascredmes) as monto_abonosctascredmes, 
                 sum(a.p_rec_vs_pagominmes) as p_rec_vs_pagominmes, sum(a.p_rec_vs_vencidomes) as p_rec_vs_vencidomes, sum(a.num_clientel_actmes) as num_clientel_actmes,    
                 sum(a.num_compagomes) as num_compagomes, sum(a.num_acuerdopagomes) as num_acuerdopagomes, sum(a.num_cons_edoctames) as num_cons_edoctames,
                 sum(a.num_retirocaptames) as num_retirocaptames, sum(a.monto_retirocaptames) as monto_retirocaptames, sum(a.num_retirocolocames) as num_retirocolocames,
                 sum(a.monto_retirocolocames) as monto_retirocolocames
          from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and            
                b.puesto in ('004', '002') and  -- Cajeros 
                b.password = 'BAJA') or
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                )
          group by 1, 2, 3, 5, 6
          INTO TEMP tmpMi_AcumulEjecutCajeros; 

           LET paso    = 3;

--PASO 2)CARGA EN TABLAS TEMPORALES LOS REGISTROS CON MOVIMIENTOS PARA EJECUTIVO DADOS DE BAJA DE mi_rptcierresuc, mi_rptcierresucpgeneral,  mi_rptcierresucacumulejecut*/

          /*Carga las tablas temporales con los registros de los movimientos para los ejecutivos dados de BAJA de mi_rptcierresuc*/
          select a.empresa, a.sucursal,              
                      (select sc.promotor_virtual 
                         from bdmis:mi_sucursalesinfo sc
                        where sc.num_sucursal = a.sucursal) as ejecutivo,             
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, 0 as meta_ctasdia, 0 as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca  
          from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and
				b.puesto in ('001', '003') and
                b.password  = 'BAJA') or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal and 
				 b.puesto in ('001', '003')) or
                (a.ejecutivo = b.ejecutivo and
                (a.nombre is null or a.nombre = '')
				and b.puesto in ('001', '003'))
          group by 1,2,5,3,6
          INTO TEMP tmpMi_RptCierreSuc;

		  --  no ejecutivos


		  
		  
          select a.empresa, a.sucursal,              
                      (select sc.promotor_virtual 
                         from bdmis:mi_sucursalesinfo sc
                        where sc.num_sucursal = a.sucursal) as ejecutivo,             
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, 0 as meta_ctasdia, 0 as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca  
          from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b
          where 
                a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
          group by 1,2,5,3,6
          INTO TEMP tmpMi_RptCierreSuc_ejecutivos;	
		  
		  --usuario interact para solicitudes
				
				 select a.empresa, a.sucursal,              
                      (select sc.promotor_virtual 
                         from bdmis:mi_sucursalesinfo sc
                        where sc.num_sucursal = a.sucursal) as ejecutivo,             
                 'PROMOTOR VIRTUAL' as nombre, a.producto, max(a.fecha_cierre) as fecha_cierre, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, 0 as meta_ctasdia, 0 as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca  
				from bdmis:mi_rptcierresuc a
				where ejecutivo = 'interact'
				group by 1,2,5,3
				into temp tmpMi_RptCierreSuc_interact;
		  
            
          /*Carga las tablas temporales con los registros de los generales para los ejecutivos dados de BAJA de mi_rptcierresucpgeneral*/
          select a.empresa, a.sucursal,
               (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                 where sc.num_sucursal = a.sucursal) as ejecutivo,
                'PROMOTOR VIRTUAL' as nombre, a.fecha_cierre,
--                paso_nombre as nombre, a.fecha_cierre,
                sum(p_cumdia_capta) as p_cumdia_capta, sum(p_cumdia_coloca) as p_cumdia_coloca, sum(p_cumdia_saldo) as p_cumdia_saldo,
                sum(p_cumdia_tdc) as p_cumdia_tdc, sum(p_cumdia_general) as p_cumdia_general, sum(p_cummes_capta) as p_cummes_capta,
                sum(p_cummes_coloca) as p_cummes_coloca, sum(p_cummes_saldo) as p_cummes_saldo, sum(p_cummes_tdc) as p_cummes_tdc,
                sum(p_cummes_general) as p_cummes_general
          from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and  
				b.puesto in ('001', '003') and 
                b.password  = 'BAJA') or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal 
				 and b.puesto in ('001', '003')) or
                (a.ejecutivo = b.ejecutivo and
                (a.nombre is null or a.nombre = '') 
				and b.puesto in ('001', '003'))
          group by 1, 2, 3, 5
          INTO TEMP tmpMi_RptCierreSucPGeneralBaja;
		  
		  
--general no ejecutivos

          select a.empresa, a.sucursal,
               (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                 where sc.num_sucursal = a.sucursal) as ejecutivo,
                'PROMOTOR VIRTUAL' as nombre, a.fecha_cierre,
--                paso_nombre as nombre, a.fecha_cierre,
                sum(p_cumdia_capta) as p_cumdia_capta, sum(p_cumdia_coloca) as p_cumdia_coloca, sum(p_cumdia_saldo) as p_cumdia_saldo,
                sum(p_cumdia_tdc) as p_cumdia_tdc, sum(p_cumdia_general) as p_cumdia_general, sum(p_cummes_capta) as p_cummes_capta,
                sum(p_cummes_coloca) as p_cummes_coloca, sum(p_cummes_saldo) as p_cummes_saldo, sum(p_cummes_tdc) as p_cummes_tdc,
                sum(p_cummes_general) as p_cummes_general
          from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
          where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
          group by 1, 2, 3, 5
          INTO TEMP tmpMi_RptCierreSucPGeneralBaja_noejecutico;
		  
-- no ejecutivos

          select a.empresa, a.sucursal,
               (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                 where sc.num_sucursal = a.sucursal) as ejecutivo,
                'PROMOTOR VIRTUAL' as nombre, a.fecha_cierre,
--                paso_nombre as nombre, a.fecha_cierre,
                sum(p_cumdia_capta) as p_cumdia_capta, sum(p_cumdia_coloca) as p_cumdia_coloca, sum(p_cumdia_saldo) as p_cumdia_saldo,
                sum(p_cumdia_tdc) as p_cumdia_tdc, sum(p_cumdia_general) as p_cumdia_general, sum(p_cummes_capta) as p_cummes_capta,
                sum(p_cummes_coloca) as p_cummes_coloca, sum(p_cummes_saldo) as p_cummes_saldo, sum(p_cummes_tdc) as p_cummes_tdc,
                sum(p_cummes_general) as p_cummes_general
          from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
          where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
          group by 1, 2, 3, 5
          INTO TEMP tmpMi_RptCierreSucPGeneral_noejecutivo;		  
		  

         /* Carga las tablas temporales con los registros de los generales para los ejecutivos dados de BAJA de mi_rptcierresucacumulejecut */
          select a.empresa, a.sucursal, 
                 (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                  where sc.num_sucursal = a.sucursal) as ejecutivo,
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.aniomes,  
--                 paso_nombre as nombre, a.producto, a.aniomes,  
                 sum(a.num_ctasmes) as num_ctasmes, sum(a.monto_ctasmes) as monto_ctasmes, sum(a.p_cumpmetactasmes) as p_cumpmetactasmes,  
                 sum(a.meta_ctasmes) as meta_ctasmes, sum(a.monto_incrementomes) as monto_incrementomes, sum(a.meta_incrementomes) as meta_incrementomes,
                 sum(a.p_cumpsaldomes) as p_cumpsaldomes, sum(a.num_abonosctascapmes) as num_abonosctascapmes, sum(a.monto_abonosctascapmes) as monto_abonosctascapmes,
                 sum(a.num_abonosctascredmes) as num_abonosctascredmes, sum(a.monto_abonosctascredmes) as monto_abonosctascredmes, 
                 sum(a.p_rec_vs_pagominmes) as p_rec_vs_pagominmes, sum(a.p_rec_vs_vencidomes) as p_rec_vs_vencidomes, sum(a.num_clientel_actmes) as num_clientel_actmes,    
                 sum(a.num_compagomes) as num_compagomes, sum(a.num_acuerdopagomes) as num_acuerdopagomes, sum(a.num_cons_edoctames) as num_cons_edoctames,
                 sum(a.num_retirocaptames) as num_retirocaptames, sum(a.monto_retirocaptames) as monto_retirocaptames, sum(a.num_retirocolocames) as num_retirocolocames,
                 sum(a.monto_retirocolocames) as monto_retirocolocames
          from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
          where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and            
				b.puesto in ('001', '003') and 
                b.password  = 'BAJA' ) or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal and
				 b.puesto in ('001', '003')) or
                (a.ejecutivo = b.ejecutivo and
                 (a.nombre is null or a.nombre = '')
				 and b.puesto in ('001', '003'))
          group by 1, 2, 3, 5, 6
          INTO TEMP tmpMi_RptCierreSucAcumulEjecut;    

-- acumule no ejecutivos
 select a.empresa, a.sucursal, 
                 (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                  where sc.num_sucursal = a.sucursal) as ejecutivo,
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.aniomes,  
--                 paso_nombre as nombre, a.producto, a.aniomes,  
                 sum(a.num_ctasmes) as num_ctasmes, sum(a.monto_ctasmes) as monto_ctasmes, sum(a.p_cumpmetactasmes) as p_cumpmetactasmes,  
                 sum(a.meta_ctasmes) as meta_ctasmes, sum(a.monto_incrementomes) as monto_incrementomes, sum(a.meta_incrementomes) as meta_incrementomes,
                 sum(a.p_cumpsaldomes) as p_cumpsaldomes, sum(a.num_abonosctascapmes) as num_abonosctascapmes, sum(a.monto_abonosctascapmes) as monto_abonosctascapmes,
                 sum(a.num_abonosctascredmes) as num_abonosctascredmes, sum(a.monto_abonosctascredmes) as monto_abonosctascredmes, 
                 sum(a.p_rec_vs_pagominmes) as p_rec_vs_pagominmes, sum(a.p_rec_vs_vencidomes) as p_rec_vs_vencidomes, sum(a.num_clientel_actmes) as num_clientel_actmes,    
                 sum(a.num_compagomes) as num_compagomes, sum(a.num_acuerdopagomes) as num_acuerdopagomes, sum(a.num_cons_edoctames) as num_cons_edoctames,
                 sum(a.num_retirocaptames) as num_retirocaptames, sum(a.monto_retirocaptames) as monto_retirocaptames, sum(a.num_retirocolocames) as num_retirocolocames,
                 sum(a.monto_retirocolocames) as monto_retirocolocames
          from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
          where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
          group by 1, 2, 3, 5, 6
          INTO TEMP tmpMi_RptCierreSucAcumulEjecut_noejecutivo;  		  

		 --usuario interact para solicitudes en acumulado
		 
		           select a.empresa, a.sucursal, 
                 (select sc.promotor_virtual 
                  from bdmis:mi_sucursalesinfo sc
                  where sc.num_sucursal = a.sucursal) as ejecutivo,
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.aniomes,  
--                 paso_nombre as nombre, a.producto, a.aniomes,  
                 sum(a.num_ctasmes) as num_ctasmes, sum(a.monto_ctasmes) as monto_ctasmes, sum(a.p_cumpmetactasmes) as p_cumpmetactasmes,  
                 sum(a.meta_ctasmes) as meta_ctasmes, sum(a.monto_incrementomes) as monto_incrementomes, sum(a.meta_incrementomes) as meta_incrementomes,
                 sum(a.p_cumpsaldomes) as p_cumpsaldomes, sum(a.num_abonosctascapmes) as num_abonosctascapmes, sum(a.monto_abonosctascapmes) as monto_abonosctascapmes,
                 sum(a.num_abonosctascredmes) as num_abonosctascredmes, sum(a.monto_abonosctascredmes) as monto_abonosctascredmes, 
                 sum(a.p_rec_vs_pagominmes) as p_rec_vs_pagominmes, sum(a.p_rec_vs_vencidomes) as p_rec_vs_vencidomes, sum(a.num_clientel_actmes) as num_clientel_actmes,    
                 sum(a.num_compagomes) as num_compagomes, sum(a.num_acuerdopagomes) as num_acuerdopagomes, sum(a.num_cons_edoctames) as num_cons_edoctames,
                 sum(a.num_retirocaptames) as num_retirocaptames, sum(a.monto_retirocaptames) as monto_retirocaptames, sum(a.num_retirocolocames) as num_retirocolocames,
                 sum(a.monto_retirocolocames) as monto_retirocolocames
          from bdmis:mi_rptcierresucacumulejecut a
          where a.ejecutivo = 'interact'
          group by 1, 2, 3, 5, 6
          INTO TEMP tmpMi_RptCierreSucAcumulEjecut_interact;		  

--PASO 3) ELIMINA REGISTROS DE EJECUTIVOS DADOS DE BAJA O QUE YA NO SE ENCUENTRAN EN LA SUCURSAL PARA LAS TABLAS ORIGINALES mi_rptcierresuc, mi_rptcierresucpgeneral, mi_rptcierresucacumulejecut y Cajeros
       
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR    
           select a.ejecutivo, a.empresa, a.producto, a.sucursal
           into v_ejecutivo, v_empresa, v_producto, v_sucursal
           from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and 
				b.puesto in ('001', '003') and 
                b.password  = 'BAJA') or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal and 
				b.puesto in ('001', '003') ) or
                (a.ejecutivo = b.ejecutivo and
                (a.nombre is null or a.nombre = '') and 
				b.puesto in ('001', '003'))
           order by ejecutivo, empresa, producto, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresuc
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and producto = v_producto and sucursal = v_sucursal;


           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresuc;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;
           update statistics medium for table bdmis:mi_rptcierresuc;      
           LET vsFlagEnTransaccion = 'F';
        END IF;
            LET paso    = 9;
----borra no ejecutivos  bdmis:mi_rptcierresuc

      LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
 FOREACH cusor01 WITH HOLD
                      FOR       
           select a.ejecutivo, a.empresa, a.producto, a.sucursal
           into v_ejecutivo, v_empresa, v_producto, v_sucursal
           from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b
           where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
           order by ejecutivo, empresa, producto, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresuc
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and producto = v_producto and sucursal = v_sucursal;


           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresuc;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;
           update statistics medium for table bdmis:mi_rptcierresuc;      
           LET vsFlagEnTransaccion = 'F';
        END IF;
            LET paso    = 9;		
			
			
        /*BORRA LA INFORMACION DE bdmis:mi_rptcierresuc DE S */
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR       
           select a.ejecutivo, a.empresa, a.producto, a.sucursal
           into v_ejecutivo, v_empresa, v_producto, v_sucursal
           from bdmis:mi_rptcierresuc a, bdinteg:si_ejecut b 
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                and b.password = 'BAJA') or 
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
               )
           order by ejecutivo, empresa, producto, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresuc
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and producto = v_producto and sucursal = v_sucursal;          

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresuc;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;
           update statistics medium for table bdmis:mi_rptcierresuc;      
           LET vsFlagEnTransaccion = 'F';
        END IF;

        /*Borra mi_rptcierresucpgeneral BAJA*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR     
           select a.ejecutivo, a.empresa, a.sucursal
           into v_ejecutivo, v_empresa, v_sucursal
           from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and 
				b.puesto in ('001', '003') and 
                b.password  = 'BAJA') or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal and
				 b.puesto in ('001', '003')) or
                (a.ejecutivo = b.ejecutivo and
                (a.nombre is null or a.nombre = '') and 
				b.puesto in ('001', '003'))
           order by ejecutivo, empresa, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucpgeneral
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and sucursal = v_sucursal;

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucpgeneral;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
          COMMIT WORK;
          update statistics medium for table bdmis:mi_rptcierresucpgeneral;      
          LET vsFlagEnTransaccion = 'F';
        END IF;

        /*Borra mi_rptcierresucpgeneral CAJEROS*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR        
           select a.ejecutivo, a.empresa, a.sucursal
           into v_ejecutivo, v_empresa, v_sucursal
           from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                and b.password = 'BAJA') or 
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
               )            
           order by ejecutivo, empresa, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucpgeneral
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and sucursal = v_sucursal;           

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucpgeneral;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
          COMMIT WORK;
          update statistics medium for table bdmis:mi_rptcierresucpgeneral;      
          LET vsFlagEnTransaccion = 'F';
        END IF;

        /*Borra mi_rptcierresucacumulejecut BAJA*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR     
           select a.ejecutivo, a.empresa, a.producto, a.sucursal
           into v_ejecutivo, v_empresa, v_producto, v_sucursal
           from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo and
				b.puesto in ('001', '003') and
                b.password  = 'BAJA') or
                (a.ejecutivo = b.ejecutivo and 
                 a.sucursal <> b.sucursal and 
				 b.puesto in ('001', '003')) or
                (a.ejecutivo = b.ejecutivo and
                (a.nombre is null or a.nombre = '') and
				 b.puesto in ('001', '003'))
           order by ejecutivo, empresa, producto, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucacumulejecut
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and producto = v_producto and sucursal = v_sucursal;

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucacumulejecut;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;
           update statistics medium for table bdmis:mi_rptcierresucacumulejecut;      
           LET vsFlagEnTransaccion = 'F';
        END IF;   
            LET viContadorRegistros = viContadorRegistros;            

		 /*Borra no ejecutivos mi_rptcierresucacumulejecut*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR      
           select a.ejecutivo, a.empresa, a.sucursal
           into v_ejecutivo, v_empresa, v_sucursal
           from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
           where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
           order by ejecutivo, empresa, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucacumulejecut
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and sucursal = v_sucursal;

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucacumulejecut;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
          COMMIT WORK;
          update statistics medium for table bdmis:mi_rptcierresucacumulejecut;      
          LET vsFlagEnTransaccion = 'F';
        END IF;

        /*Borra no ejecutivos mi_rptcierresucpgeneral BAJA*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR     
           select a.ejecutivo, a.empresa, a.sucursal
           into v_ejecutivo, v_empresa, v_sucursal
           from bdmis:mi_rptcierresucpgeneral a, bdinteg:si_ejecut b
           where  a.ejecutivo = b.ejecutivo and
				(b.puesto not in('001','002','003','004')
				or b.puesto is null)
           order by ejecutivo, empresa, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucpgeneral
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and sucursal = v_sucursal;

           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucpgeneral;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
          COMMIT WORK;
          update statistics medium for table bdmis:mi_rptcierresucpgeneral;      
          LET vsFlagEnTransaccion = 'F';
        END IF;
		
		
		
        /*Borra mi_rptcierresucacumulejecut CAJEROS*/
        LET v_ejecutivo = "00000000";
        LET v_empresa = "000";
        LET v_producto = "0000";
        LET v_sucursal = "0000";
        LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
        LET viContadorRegistros2 = 0;
        SET ISOLATION TO DIRTY READ;
         FOREACH cusor01 WITH HOLD
                      FOR   
           select a.ejecutivo, a.empresa, a.producto, a.sucursal
           into v_ejecutivo, v_empresa, v_producto, v_sucursal
           from bdmis:mi_rptcierresucacumulejecut a, bdinteg:si_ejecut b
           where (a.sucursal  = b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                and b.password = 'BAJA') or 
				(a.sucursal  <> b.sucursal and
                a.ejecutivo = b.ejecutivo             
                and b.puesto in ('004', '002')   -- Cajeros 
                )
           order by ejecutivo, empresa, producto, sucursal

           IF(vsFlagEnTransaccion = 'F') THEN
              BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;

           DELETE FROM bdmis:mi_rptcierresucacumulejecut
           WHERE ejecutivo = v_ejecutivo and empresa = v_empresa and producto = v_producto and sucursal = v_sucursal;
 
           LET viContadorRegistros = viContadorRegistros + 1;
           LET viContadorRegistros2 = viContadorRegistros2 + 1;

           IF (viContadorRegistros2 = 60000) THEN 
               update statistics medium for table bdmis:mi_rptcierresucacumulejecut;           
               LET viContadorRegistros2 = 0;
           END IF;

           IF (viContadorRegistros = 1000) THEN
              COMMIT WORK;
              LET vsFlagEnTransaccion = 'F';
              LET viContadorRegistros = 0;
              CONTINUE FOREACH;
           END IF;
        END FOREACH;
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
           COMMIT WORK;
           update statistics medium for table bdmis:mi_rptcierresucacumulejecut;      
           LET vsFlagEnTransaccion = 'F';
        END IF;    

            LET viContadorRegistros = viContadorRegistros;

-- PASO 4) INSERTAMOS LOS REGISTROS DE LAS TABLAS TEMPORALES A LAS ORIGINALES

-- Inicia la union de todas la tablas de tmpMi_RptCierreSuc (dos)
          BEGIN WORK; 
          select a.empresa, a.sucursal,              
                 ejecutivo,             
--                  paso_nombre as nombre, a.producto, a.fecha_cierre, 
                  'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, 0 as meta_ctasdia, 0 as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca 
                 from tmpMi_RptCajerosSucDia a
                 group by a.empresa, a.sucursal, ejecutivo,
                 nombre, a.producto, a.fecha_cierre
          union
          select a.empresa, a.sucursal, ejecutivo, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, sum(meta_ctasdia) as meta_ctasdia, sum(p_cumpmetactas) as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca 
                 from tmpMi_RptCierreSuc a
                 group by a.empresa, a.sucursal, ejecutivo,             
                 nombre, a.producto, a.fecha_cierre
				 union
				 select a.empresa, a.sucursal, ejecutivo, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, sum(meta_ctasdia) as meta_ctasdia, sum(p_cumpmetactas) as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca 
                 from tmpMi_RptCierreSuc_interact a
				  group by a.empresa, a.sucursal, ejecutivo,             
                 nombre, a.producto, a.fecha_cierre
				 union
				 select a.empresa, a.sucursal, ejecutivo, 
--                 paso_nombre as nombre, a.producto, a.fecha_cierre, 
                 'PROMOTOR VIRTUAL' as nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, sum(meta_ctasdia) as meta_ctasdia, sum(p_cumpmetactas) as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, 0 as meta_incremento, 
                 0 as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca 
                 from tmpMi_RptCierreSuc_ejecutivos a
                 group by a.empresa, a.sucursal, ejecutivo,             
                 nombre, a.producto, a.fecha_cierre			 
                
          INTO TEMP tmpMi_RptCierreSucOk;   
          COMMIT WORK;

-- Se inserta la union de todas la tablas de tmpMi_RptCierreSuc (dos) a mi_rptcierresuc
          BEGIN WORK; 
          insert into bdmis:mi_rptcierresuc
          select 
                a.empresa, a.sucursal,              
                ejecutivo, 'PROMOTOR VIRTUAL' as paso_nombre, a.producto, a.fecha_cierre, 
                 sum(a.num_ctasdia) as num_ctasdia, sum(meta_ctasdia) as meta_ctasdia, sum(p_cumpmetactas) as p_cumpmetactas,
                 sum(a.monto_ctasdia) as monto_ctasdia, sum(a.monto_incrementodia) as monto_incrementodia, sum(meta_incremento) as meta_incremento, 
                 sum(p_cumpsaldo) as p_cumpsaldo, sum(a.num_abonosctascap) as num_abonosctascap, sum(a.monto_abonosctascap) as monto_abonosctascap, 
                 sum(a.num_abonosctascred) as num_abonosctascred, sum(a.monto_abonosctascred) as monto_abonosctascred, sum(a.p_rec_vs_pagomin) as p_rec_vs_pagomin,
                 sum(a.p_rec_vs_vencido) as p_rec_vs_vencido, sum(a.num_clientel_act) as num_clientel_act, sum(a.num_compago) as num_compago,
                 sum(a.num_acuerdopago) as num_acuerdopago, sum(a.num_cons_edocta) as num_cons_edocta, sum(a.num_retirocapta) as num_retirocapta, 
                 sum(a.monto_retirocapta) as monto_retirocapta, sum(a.num_retirocoloca) as num_retirocoloca, sum(a.monto_retirocoloca) as monto_retirocoloca
          from tmpMi_RptCierreSucOk a group by  a.empresa, a.sucursal,              
                ejecutivo, 4, a.producto, a.fecha_cierre;   
          COMMIT WORK;

-- Inicia la union de todas la tablas de tmpMi_RptCierreSucGeneral (tres)
          BEGIN WORK; 
           /* select * 
            from tmpMi_RptCierreSucPGeneral --No debería considearla
          union */
            select * 
            from tmpMi_RptCierreSucPGeneralCajeros
          union 
            select * 
            from tmpMi_RptCierreSucPGeneralBaja
		  union 
			select * 
            from tmpMi_RptCierreSucPGeneral_noejecutivo	
			
          INTO TEMP tmpMi_CierreSucPGeneralok; 
          COMMIT WORK;
            


-- Inicia la union de todas la tablas de acumulejecut (tres)
          BEGIN WORK; 
          /*select empresa, sucursal, ejecutivo, nombre, producto,
                 aniomes, num_ctasmes, monto_ctasmes, p_cumpmetactasmes, 
                 meta_ctasmes, monto_incrementomes, meta_incrementomes, 
                 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes, 
                 num_abonosctascredmes, monto_abonosctascredmes, p_rec_vs_pagominmes, 
                 p_rec_vs_vencidomes, num_clientel_actmes, num_compagomes, 
                 num_acuerdopagomes, num_cons_edoctames, num_retirocaptames, 
                 monto_retirocaptames, num_retirocolocames, monto_retirocolocames 
                 from tmp_acumulejecut --No debería considerarla
          union*/
          select a.empresa, a.sucursal, ejecutivo, nombre, a.producto, 
                 a.aniomes, num_ctasmes, monto_ctasmes, p_cumpmetactasmes,  
                 meta_ctasmes, monto_incrementomes, meta_incrementomes,
                 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes,
                 num_abonosctascredmes, monto_abonosctascredmes, p_rec_vs_pagominmes, 
                 p_rec_vs_vencidomes, num_clientel_actmes, num_compagomes,   
                 num_acuerdopagomes, num_cons_edoctames, num_retirocaptames,
                 monto_retirocaptames, num_retirocolocames, monto_retirocolocames
                 from tmpMi_RptCierreSucAcumulEjecut a
          union
          select a.empresa, a.sucursal, 
                 ejecutivo,
                 nombre, a.producto, a.aniomes,  
                 num_ctasmes, monto_ctasmes, p_cumpmetactasmes,  
                 meta_ctasmes, monto_incrementomes, meta_incrementomes,
                 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes,
                 num_abonosctascredmes, monto_abonosctascredmes, 
                 p_rec_vs_pagominmes, p_rec_vs_vencidomes, num_clientel_actmes,    
                 num_compagomes, num_acuerdopagomes, num_cons_edoctames,
                 num_retirocaptames, monto_retirocaptames, num_retirocolocames,
                 monto_retirocolocames
          from tmpMi_AcumulEjecutCajeros a
		  union
		  select a.empresa, a.sucursal, ejecutivo, nombre, a.producto, 
                 a.aniomes, num_ctasmes, monto_ctasmes, p_cumpmetactasmes,  
                 meta_ctasmes, monto_incrementomes, meta_incrementomes,
                 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes,
                 num_abonosctascredmes, monto_abonosctascredmes, p_rec_vs_pagominmes, 
                 p_rec_vs_vencidomes, num_clientel_actmes, num_compagomes,   
                 num_acuerdopagomes, num_cons_edoctames, num_retirocaptames,
                 monto_retirocaptames, num_retirocolocames, monto_retirocolocames
		  from tmpMi_RptCierreSucAcumulEjecut_interact a
		  union
		 select a.empresa, a.sucursal, ejecutivo, nombre, a.producto, 
                 a.aniomes, num_ctasmes, monto_ctasmes, p_cumpmetactasmes,  
                 meta_ctasmes, monto_incrementomes, meta_incrementomes,
                 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes,
                 num_abonosctascredmes, monto_abonosctascredmes, p_rec_vs_pagominmes, 
                 p_rec_vs_vencidomes, num_clientel_actmes, num_compagomes,   
                 num_acuerdopagomes, num_cons_edoctames, num_retirocaptames,
                 monto_retirocaptames, num_retirocolocames, monto_retirocolocames
		  from tmpMi_RptCierreSucAcumulEjecut_noejecutivo a
          INTO TEMP tmp_acumulejecutOk;   
          COMMIT WORK;        

-- Se inserta la union de todas la tablas de acumulejecut (tres) a mi_rptcierresucacumulejecut
          BEGIN WORK; 
          insert into bdmis:mi_rptcierresucacumulejecut
          select empresa, sucursal, ejecutivo, 'PROMOTOR VIRTUAL' /*paso_nombre*/, producto,
                 aniomes, sum(num_ctasmes), sum(monto_ctasmes), sum(p_cumpmetactasmes), 
                 sum(meta_ctasmes), sum(monto_incrementomes), sum(meta_incrementomes), 
                 sum(p_cumpsaldomes), sum(num_abonosctascapmes), sum(monto_abonosctascapmes), 
                 sum(num_abonosctascredmes), sum(monto_abonosctascredmes), sum(p_rec_vs_pagominmes), 
                 sum(p_rec_vs_vencidomes), sum(num_clientel_actmes), sum(num_compagomes), 
                 sum(num_acuerdopagomes), sum(num_cons_edoctames), sum(num_retirocaptames), 
                 sum(monto_retirocaptames), sum(num_retirocolocames), sum(monto_retirocolocames)
          from tmp_acumulejecutOk
          group by  empresa, sucursal, ejecutivo, 4, producto,
                 aniomes ;      
          COMMIT WORK;     
			
			-- Set debug file to "gli_sp_integrapromotorvirtualdia_interact";
             --Trace on;
			
			FOREACH cusor01 WITH HOLD
                      FOR 
			 select sucursal, ejecutivo, producto, num_ctasmes,
			 monto_ctasmes, p_cumpmetactasmes, meta_ctasmes, monto_incrementomes, meta_incrementomes,
			 p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes, num_abonosctascredmes,
			 monto_abonosctascredmes, p_rec_vs_pagominmes, p_rec_vs_vencidomes, num_clientel_actmes,
			 num_compagomes, num_acuerdopagomes, num_cons_edoctames, num_retirocaptames, monto_retirocaptames,
			 num_retirocolocames,monto_retirocolocames 
			 into 	v_sucursal, v_ejecutivo, v_producto, v_num_ctasmes,
			  v_monto_ctasmes, v_p_cumpmetactasmes, v_meta_ctasmes,v_monto_incrementomes,
			  v_meta_incrementomes, v_p_cumpsaldomes, v_num_abonosctascapmes, v_monto_abonosctascapmes ,
			  v_num_abonosctascredmes, v_monto_abonosctascredmes, v_p_rec_vs_pagominmes, v_p_rec_vs_vencidomes,
			  v_num_clientel_actmes, v_num_compagomes, v_num_acuerdopagomes, v_num_cons_edoctames,
			  v_num_retirocaptames, v_monto_retirocaptames, v_num_retirocolocames, v_monto_retirocolocames 
			 from tmp_aculejecut
			 
			 
			begin work;
			
				update mi_rptcierresucacumulejecut
				set num_ctasmes = num_ctasmes + v_num_ctasmes,monto_ctasmes = monto_ctasmes + v_monto_ctasmes,
				    p_cumpmetactasmes = p_cumpmetactasmes + v_p_cumpmetactasmes, meta_ctasmes = meta_ctasmes + v_meta_ctasmes,
					monto_incrementomes = monto_incrementomes + v_monto_incrementomes, meta_incrementomes = meta_incrementomes + v_meta_incrementomes,
					p_cumpsaldomes = p_cumpsaldomes + v_p_cumpsaldomes, num_abonosctascapmes = num_abonosctascapmes + v_num_abonosctascapmes,  
					monto_abonosctascapmes = monto_abonosctascapmes + v_monto_abonosctascapmes, num_abonosctascredmes = num_abonosctascredmes + v_num_abonosctascredmes,
					monto_abonosctascredmes = monto_abonosctascredmes + v_monto_abonosctascredmes, p_rec_vs_pagominmes = p_rec_vs_pagominmes + v_p_rec_vs_pagominmes, 
					p_rec_vs_vencidomes = p_rec_vs_vencidomes + v_p_rec_vs_vencidomes, num_clientel_actmes = num_clientel_actmes + v_num_clientel_actmes,
					num_compagomes = num_compagomes + v_num_compagomes, num_acuerdopagomes = num_acuerdopagomes + v_num_acuerdopagomes,
					num_cons_edoctames = num_cons_edoctames + v_num_cons_edoctames, num_retirocaptames = num_retirocaptames + v_num_retirocaptames,
					monto_retirocaptames = monto_retirocaptames + v_monto_retirocaptames, num_retirocolocames = num_retirocolocames + v_num_retirocolocames,
					monto_retirocolocames = monto_retirocolocames + v_monto_retirocolocames				
				where sucursal = v_sucursal and ejecutivo = v_ejecutivo and
					  producto = v_producto;		
				  
					IF (dbinfo('sqlca.sqlerrd2')=0)  THEN
						
						 insert into mi_rptcierresucacumulejecut 
										(empresa, sucursal, ejecutivo, nombre ,producto, num_ctasmes, aniomes,
										monto_ctasmes, p_cumpmetactasmes, meta_ctasmes, monto_incrementomes, meta_incrementomes,
			p_cumpsaldomes, num_abonosctascapmes, monto_abonosctascapmes, num_abonosctascredmes,
			monto_abonosctascredmes, p_rec_vs_pagominmes, p_rec_vs_vencidomes, num_clientel_actmes,
			num_compagomes, num_acuerdopagomes, num_cons_edoctames, num_retirocaptames, monto_retirocaptames,
			num_retirocolocames,monto_retirocolocames 
   										 )
						        values 
										('001', v_sucursal, v_ejecutivo,'PROMOTOR VIRTUAL', v_producto, v_num_ctasmes,vaniomes,
										 v_monto_ctasmes, v_p_cumpmetactasmes, v_meta_ctasmes,v_monto_incrementomes,
										 v_meta_incrementomes, v_p_cumpsaldomes, v_num_abonosctascapmes, v_monto_abonosctascapmes ,
										 v_num_abonosctascredmes, v_monto_abonosctascredmes, v_p_rec_vs_pagominmes, v_p_rec_vs_vencidomes,
										 v_num_clientel_actmes, v_num_compagomes, v_num_acuerdopagomes, v_num_cons_edoctames,
										 v_num_retirocaptames, v_monto_retirocaptames, v_num_retirocolocames, v_monto_retirocolocames 
										);	
					
					end if 
				
				
			commit work;
			
			end FOREACH;
        RETURN '000','';
      END
    END PROCEDURE;