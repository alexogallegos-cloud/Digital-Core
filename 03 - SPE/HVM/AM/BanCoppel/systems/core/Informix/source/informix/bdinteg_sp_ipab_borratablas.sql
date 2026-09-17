CREATE PROCEDURE "informix".sp_ipab_borratablas( pNumCliente CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE cCodRet  CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET cCodRet  = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_borratablas.out';
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_borratablas.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF pNumCliente <> '999999999' THEN
    
        -- // INFORMACIÓN PERSONAL DE LOS TITULARES
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infpertit') THEN
            create table "informix".si_infpertit (
                cve_unica       char(18),
                persona         char(1),
                nombre          char(150),
                apell_paterno   char(60),
                apell_materno   char(60),
                callenum        char(90),
                colonia         char(80),
                delmun          char(60),
                ciudad          char(60),
                cod_postal      char(5),
                pais            char(50),
                estado          char(4),
                suj_retencion   char(1),
                por_retencion   decimal(6,2),
                causal_rev      smallint,
                rfc             char(13),
                curp            char(18),
                telefonos       char(30),
                correo          char(50),
                fecha_nac       char(8),
                sdo_compensado  money(15,2),
                clasif_tit      smallint,
                tipo_codpos     char(10)
              ) 
            extent size 32 next size 32 lock mode row;

            create index "informix".idx_infpertit_cve on "informix".si_infpertit(cve_unica) online;
            
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infpertit;
        ELSE
            DELETE FROM "informix".si_infpertit
             WHERE 1 = 1;
        END IF;
        
        -- // INFORMACIÓN PATRIMONIAL DE LOS TITULARES
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infpattit') THEN
            create table "informix".si_infpattit (
                numcta          char(35),
                num_inversion   char(25),
                cve_producto    char(20),
                tipo_cta        char(2),
                reg_fiscal      char(1),
                por_retencion   decimal(5,2),
                cve_sucursal    integer,
                sdo_cuenta      decimal(15,2),
                intereses       decimal(15,2),
                ret_impuestos   decimal(15,2),
                otros_accesorio decimal(15,2),
                sdo_neto        decimal(15,2),
                moneda          smallint,
                fecha_corte     char(8),
                fecha_contrata  char(8),
                plazo_opera     integer,
                tipo_tasa       smallint,
                tasa            decimal(6,3),
                inst_base       char(20),
                puntos_porc     decimal(6,3),
                operador        char(1),
                fecha_sig_corte char(8),
                sdo_prom_diario money(15,2),
                dias_ini        integer,
                saldo_ini       money(14,2),
                prom_ini        money(14,2),
                intereses_ini   money(14,2),
                isr_ini         money(14,2),
                dias_fin        integer,
                saldo_fin       money(14,2),
                prom_fin        money(14,2),
                intereses_fin   money(14,2),
                isr_fin         money(14,2) ) 
            extent size 32 next size 32 lock mode row;

            create index "informix".idx_infpattit_cta on "informix".si_infpattit(numcta) online ;
            create index "informix".idx_infpattit_inv on "informix".si_infpattit(num_inversion) online;
            
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infpattit;
        ELSE
            DELETE FROM "informix".si_infpattit
             WHERE 1 = 1;
        END IF;
        
        -- // CUENTAS ASOCIADAS DE LOS TITULARES
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_ctaasotit') THEN
            create table "informix".si_ctaasotit (
                numcta          char(35),
                num_inversion   char(25),
                cve_unica       char(18),
                porcentaje_tit  decimal(5,2) ) 
            extent size 32 next size 32 lock mode row;

            create index "informix".idx_ctaasotit_cta on "informix".si_ctaasotit(numcta) online;
            create index "informix".idx_ctaasotit_inv on "informix".si_ctaasotit(num_inversion) online;
            create index "informix".idx_ctaasotit_cve on "informix".si_ctaasotit(cve_unica) online;
            
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_ctaasotit;
        ELSE
            DELETE FROM "informix".si_ctaasotit
             WHERE 1 = 1;
        END IF;
        
        -- // INFORMACIÓN CREDITICIA DE LOS TITULARES
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infcrdtit') THEN
            create table "informix".si_infcrdtit (
                num_credito     char(20),
                moneda          smallint,
                segmento        smallint,
                tpo_cobranza    smallint,
                cap_vigente     decimal(15,2),
                cap_vencido     decimal(15,2),
                ints_ord_exig   decimal(15,2),
                ints_moratorios decimal(15,2),
                otros_accesorio decimal(15,2) )
            extent size 32 next size 32 lock mode row;

            create index "informix".idx_infcrdtit_crd on "informix".si_infcrdtit(num_credito) online;
            
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infcrdtit;
        ELSE
            DELETE FROM "informix".si_infcrdtit
             WHERE 1 = 1;
        END IF;
        
        -- // CREDITOS ASOCIADOS DE LOS TITULARES
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_crdasotit') THEN
            create table "informix".si_crdasotit (
                num_credito     char(20),
                cve_unica       char(18) ) 
            extent size 32 next size 32 lock mode row;

            create index "informix".idx_crdasotit_crd on "informix".si_crdasotit(num_credito) online;
            create index "informix".idx_crdasotit_cve on "informix".si_crdasotit(cve_unica) online;
            
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_crdasotit;   
        ELSE
            DELETE FROM "informix".si_crdasotit
             WHERE 1 = 1;
        END IF;
        
        -- // TABLA DE CLIENTES IPAB
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_clientes_ipab') THEN
            create table "informix".si_clientes_ipab (
                numcte  char(20) ) 
            extent size 32 next size 32 lock mode row;
            
            create index "informix".idx_clientesipab_cte ON "informix".si_clientes_ipab(numcte) ONLINE;
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_clientes_ipab;
        ELSE
            DELETE FROM "informix".si_clientes_ipab
             WHERE 1 = 1;
        END IF;
        
        -- // TABLA DE CLIENTES IPAB
        IF NOT EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_cliente_ipab') THEN
            create table "informix".si_cliente_ipab (
                numcte  char(20) ) 
            extent size 32 next size 32 lock mode row;
            
            create index "informix".idx_clienteipab_cte ON "informix".si_cliente_ipab(numcte) ONLINE;
            UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_cliente_ipab;
        ELSE
            DELETE FROM "informix".si_cliente_ipab
             WHERE 1 = 1;
        END IF;
        
    ELSE
    
        -- // INFORMACIÓN PERSONAL DE LOS TITULARES
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infpertit_comp') THEN
            drop table "informix".si_infpertit_comp;
        END IF;
        
        create raw table "informix".si_infpertit_comp (
            cve_unica       char(18),
            persona         char(1),
            nombre          char(150),
            apell_paterno   char(60),
            apell_materno   char(60),
            callenum        char(90),
            colonia         char(80),
            delmun          char(60),
            ciudad          char(60),
            cod_postal      char(5),
            pais            char(50),
            estado          char(4),
            suj_retencion   char(1),
            por_retencion   decimal(6,2),
            causal_rev      smallint,
            rfc             char(13),
            curp            char(18),
            telefonos       char(30),
            correo          char(50),
            fecha_nac       char(8),
            sdo_compensado  money(15,2),
            clasif_tit      smallint,
            tipo_codpos     char(10)
          ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 1024000 next size 512000 lock mode row;

        create index "informix".idx_infpertitcomp_cve on "informix".si_infpertit_comp(cve_unica) in datos03 online;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infpertit_comp;
        
        -- // INFORMACIÓN PATRIMONIAL DE LOS TITULARES
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infpattit_comp') THEN
            drop table "informix".si_infpattit_comp;
        END IF;
        
        create raw table "informix".si_infpattit_comp (
            numcta          char(35),
            num_inversion   char(25),
            cve_producto    char(20),
            tipo_cta        char(2),
            reg_fiscal      char(1),
            por_retencion   decimal(5,2),
            cve_sucursal    integer,
            sdo_cuenta      decimal(15,2),
            intereses       decimal(15,2),
            ret_impuestos   decimal(15,2),
            otros_accesorio decimal(15,2),
            sdo_neto        decimal(15,2),
            moneda          smallint,
            fecha_corte     char(8),
            fecha_contrata  char(8),
            plazo_opera     integer,
            tipo_tasa       smallint,
            tasa            decimal(6,3),
            inst_base       char(20),
            puntos_porc     decimal(6,3),
            operador        char(1),
            fecha_sig_corte char(8),
            sdo_prom_diario money(15,2),
            dias_ini        integer,
            saldo_ini       money(14,2),
            prom_ini        money(14,2),
            intereses_ini   money(14,2),
            isr_ini         money(14,2),
            dias_fin        integer,
            saldo_fin       money(14,2),
            prom_fin        money(14,2),
            intereses_fin   money(14,2),
            isr_fin         money(14,2) ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 1024000 next size 512000 lock mode row;

        create index "informix".idx_infpattitcomp_cta on "informix".si_infpattit_comp(numcta) in datos03 online ;
        create index "informix".idx_infpattitcomp_inv on "informix".si_infpattit_comp(num_inversion) in datos03 online;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infpattit_comp;
        
        -- // CUENTAS ASOCIADAS DE LOS TITULARES
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_ctaasotit_comp') THEN
            DROP TABLE "informix".si_ctaasotit_comp;
        END IF;
        
        create raw table "informix".si_ctaasotit_comp (
            numcta          char(35),
            num_inversion   char(25),
            cve_unica       char(18),
            porcentaje_tit  decimal(5,2) ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 512000 next size 64000 lock mode row;

        create index "informix".idx_ctaasotitcomp_cta on "informix".si_ctaasotit_comp(numcta) in datos03 online;
        create index "informix".idx_ctaasotitcomp_inv on "informix".si_ctaasotit_comp(num_inversion) in datos03 online;
        create index "informix".idx_ctaasotitcomp_cve on "informix".si_ctaasotit_comp(cve_unica) in datos03 online;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_ctaasotit_comp;
        
        -- // INFORMACIÓN CREDITICIA DE LOS TITULARES
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_infcrdtit_comp') THEN
            DROP TABLE "informix".si_infcrdtit_comp;
        END IF;
        
        create raw table "informix".si_infcrdtit_comp (
            num_credito     char(20),
            moneda          smallint,
            segmento        smallint,
            tpo_cobranza    smallint,
            cap_vigente     decimal(15,2),
            cap_vencido     decimal(15,2),
            ints_ord_exig   decimal(15,2),
            ints_moratorios decimal(15,2),
            otros_accesorio decimal(15,2) )
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 1024000 next size 512000 lock mode row;

        create index "informix".idx_infcrdtitcomp_crd on "informix".si_infcrdtit_comp(num_credito) in datos03 online;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_infcrdtit_comp;
        
        -- // CREDITOS ASOCIADOS DE LOS TITULARES
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_crdasotit_comp') THEN
            DROP TABLE "informix".si_crdasotit_comp;
        END IF;
        
        create raw table "informix".si_crdasotit_comp (
            num_credito     char(20),
            cve_unica       char(18) ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 512000 next size 64000 lock mode row;

        create index "informix".idx_crdasotitcomp_crd on "informix".si_crdasotit_comp(num_credito) in datos03 online;
        create index "informix".idx_crdasotitcomp_cve on "informix".si_crdasotit_comp(cve_unica) in datos03 online;
        
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_crdasotit_comp;   
        
        -- // TABLA DE CLIENTES IPAB
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_clientes_ipab_comp') THEN
            DROP TABLE "informix".si_clientes_ipab_comp;
        END IF;
        
        create raw table "informix".si_clientes_ipab_comp (
            numcte  char(20) ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 256000 next size 32000 lock mode row;
        
        create index "informix".idx_clientesipabcomp_cte ON "informix".si_clientes_ipab_comp(numcte) IN datos03 ONLINE;
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_clientes_ipab_comp;
        
        -- // TABLA DE CLIENTES IPAB
        IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_cliente_ipab_comp') THEN
            DROP TABLE "informix".si_cliente_ipab_comp;
        END IF;
        
        create raw table "informix".si_cliente_ipab_comp (
            numcte  char(20) ) 
        fragment by round robin in datos00 , datos01 , datos02 
        extent size 256000 next size 32000 lock mode row;
        
        create index "informix".idx_clienteipabcomp_cte ON "informix".si_cliente_ipab_comp(numcte) IN datos03 ONLINE;
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_cliente_ipab_comp;
    
    END IF;
        
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;