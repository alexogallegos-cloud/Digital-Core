CREATE PROCEDURE "informix".sp_rep_ind_credito(pempresa CHAR(3),pfecha DATE)
RETURNING  CHAR(6), CHAR(80);

DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cMensaje 		                CHAR(80); 
DEFINE cCod_ret                         CHAR(6);
DEFINE cSql                             CHAR(12000);
DEFINE iMes                             smallint;
DEFINE iAnio                            smallint;
DEFINE iDia                             smallint;
DEFINE dFechaIni                        date;
DEFINE dFechaFin                        date;
DEFINE dFechaCorte                      date;
DEFINE iNum_dia                         CHAR(02);
DEFINE iNum_mes                         CHAR(02);
DEFINE iNum_anio                        CHAR(04);
DEFINE cfecha                           CHAR(08);
DEFINE v_num_credito                    CHAR(20); 
DEFINE v_numcte                         CHAR(20);
DEFINE v_monto_otorgado                 DECIMAL(18,2);
DEFINE v_status_cred                    CHAR(2);
DEFINE v_saldo                          DECIMAL(18,2);
DEFINE v_capital_vigente                DECIMAL(18,2);
DEFINE v_capital_vencido                DECIMAL(18,2); 
DEFINE v_meses_vencido                  DECIMAL(18,2);
DEFINE v_fecha_nac                      DATE;
DEFINE v_estado_civil                   CHAR(2);
DEFINE v_sexo                           CHAR(1); 
DEFINE v_ult_fech_mov                   DATE;
DEFINE v_comp_comer                     DECIMAL(18,2);   
DEFINE v_disp_caj                       DECIMAL(18,2);   
DEFINE v_mto_disp_sucu                  DECIMAL(18,2);
DEFINE v_dep_sdo_favor                  DECIMAL(18,2);
DEFINE v_ret_sdo_favor                  DECIMAL(18,2);
DEFINE v_mto_com_repo                   DECIMAL(18,2);
DEFINE v_mto_com_ret_caj_conv           DECIMAL(18,2);    
DEFINE v_mto_com_ret_caj_red            DECIMAL(18,2);
DEFINE v_mto_com_ret_caj_inter          DECIMAL(18,2);
DEFINE v_mto_com_cons_caj_conv          DECIMAL(18,2);
DEFINE v_mto_com_cons_caj_red           DECIMAL(18,2);   
DEFINE v_mto_com_cons_caj_inter         DECIMAL(18,2);
DEFINE v_com_disp_ventanilla           DECIMAL(18,2);
DEFINE v_iva_com_gene                   DECIMAL(18,2);
DEFINE v_int_vig_gene                   DECIMAL(18,2);
DEFINE v_iva_int_vig_gene               DECIMAL(18,2);
DEFINE v_int_vdo_gene                   DECIMAL(18,2); 
DEFINE v_iva_int_vdo_gdo                DECIMAL(18,2); 
DEFINE v_pagos                          DECIMAL(18,2);
DEFINE v_com_pagadas                    DECIMAL(18,2); 
DEFINE v_iva_com_pagado                 DECIMAL(18,2);  
DEFINE v_fecha_ult_mov                  DATE;
DEFINE v_mora_debe_fin_mes              DECIMAL(18,2);
DEFINE v_cap_vig_pagado                 DECIMAL(18,2);
DEFINE v_cap_ven_pag                    DECIMAL(18,2); 
DEFINE v_int_vig_pagado                 DECIMAL(18,2);
DEFINE v_int_vencido_pag                DECIMAL(18,2);
DEFINE v_int_mora_pagados               DECIMAL(18,2);
DEFINE v_iva_int_mora_pagado            DECIMAL(18,2);
DEFINE v_iva_int_vencido_pag            DECIMAL(18,2);
DEFINE v_sucursal                       CHAR(4);
DEFINE v_tipo_ult_mov                   CHAR(15);

-- Creado: Leonardo Hernandez Moreno
-- Fecha: 16 Diciembre 2009
-- Crear en BDICRED
-- Se crea con el objetivo de obtener indicadores de credito

LET cCod_ret = '00000';
LET cMensaje = 'PROCESO EXITOSO';
LET sql_err = 0;
LET iNum_dia  ='';
LET iNum_mes  ='';
LET iNum_anio ='';
LET cfecha ='';
LET v_num_credito           = ""; 
LET v_numcte                = "";
LET v_monto_otorgado        = 0;
LET v_status_cred           = "";
LET v_saldo                 = 0;
LET v_capital_vigente       = 0;
LET v_capital_vencido       = 0;
LET v_meses_vencido         = 0;
LET v_fecha_nac             = "";
LET v_estado_civil          = "";
LET v_sexo                  = "";
LET v_ult_fech_mov          = "";
LET v_comp_comer            = 0;  
LET v_disp_caj              = 0; 
LET v_mto_disp_sucu         = 0;
LET v_dep_sdo_favor         = 0;
LET v_ret_sdo_favor         = 0;
LET v_mto_com_repo          = 0;
LET v_mto_com_ret_caj_conv  = 0;
LET v_mto_com_ret_caj_red   = 0;
LET v_mto_com_ret_caj_inter = 0;
LET v_mto_com_cons_caj_conv = 0;
LET v_mto_com_cons_caj_red  = 0;
LET v_mto_com_cons_caj_inter = 0;
LET v_com_disp_ventanilla   = 0;
LET v_iva_com_gene          = 0;
LET v_int_vig_gene          = 0;
LET v_iva_int_vig_gene      = 0;
LET v_int_vdo_gene          = 0;
LET v_iva_int_vdo_gdo       = 0;
LET v_pagos                 = 0;
LET v_com_pagadas           = 0;
LET v_iva_com_pagado        = 0;
LET V_fecha_ult_mov         = "";
LET v_mora_debe_fin_mes     = "";
LET v_cap_vig_pagado        = 0;
LET v_cap_ven_pag           = 0;
LET v_int_vig_pagado        = 0;
LET v_int_vencido_pag       = 0;
LET v_int_mora_pagados      = 0;
LET v_iva_int_mora_pagado   = 0;
LET v_iva_int_vencido_pag   = 0;
LET v_sucursal              = "";
LET v_tipo_ult_mov          = "";


      BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cMensaje;
	  END EXCEPTION;

--SET DEBUG FILE TO "/pisa/leo/indicadores_creditos/sp_prueba_ind_cred.out";
--TRACE ON;
LET dFechaIni = mdy(month(pfecha),'01',year(pfecha)) - 1 units month;
LET dFechaFin = mdy(month(pfecha),'01',year(pfecha)) - 1 units day;
LET dFechaCorte = mdy(month(dFechaIni),'20',year(dFechaIni));


--ini Fecha nombre del archivo
LET iNum_dia  = lpad(day(dFechaCorte),2,'0');
LET iNum_mes  = month(dFechaCorte);
LET iNum_anio = lpad(year(dFechaCorte),4,'0');
LET cfecha = iNum_dia || lpad(trim(iNum_mes),2,'0') || iNum_anio;
--fin Fecha nombre del archivo


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

     TRUNCATE TABLE sd_indica_cred;

     FOREACH WITH HOLD

            SELECT num_credito,numcte,sucursal,status_cred
              INTO v_num_credito, v_numcte, v_sucursal,v_status_cred
              FROM  bdicred:sd_maecredcont 
             WHERE fecha = dFechaFin
               AND empresa = pempresa
			   AND num_credito >= ''
			   
            SELECT  monto_otorgado,sdo_cap_insoluto, --saldo
                    sdo_capital, --capital_vigente
                    mto_venc_trasp + cap_tras_no_venci, --capital_vencido
                    mto_fin_ven_trasp, --meses_vencido
                   (sdo_contab_mora + sdo_moratorio) mora_debe_fin_mes --moratorio debe a fIN de mes
              INTO v_monto_otorgado, v_saldo, v_capital_vigente,v_capital_vencido,v_meses_vencido,v_mora_debe_fin_mes
              FROM  bdicred:sd_maesdoscont
             WHERE fecha = dFechaFin AND num_credito = v_num_credito AND empresa = pempresa
               AND sdo_cap_insoluto > 0;

            SELECT sdo_cap_insoluto --Depositos saldo a favor
              INTO v_dep_sdo_favor
              FROM  bdicred:sd_maesdoscont
             WHERE fecha = dFechaFin AND num_credito = v_num_credito AND empresa = pempresa
               AND sdo_cap_insoluto < 0;

            SELECT fecha_nac,estado_civil,sexo
              INTO v_fecha_nac, v_estado_civil, v_sexo
              FROM bdinteg:si_ctepf
             WHERE numcte = v_numcte;

 SELECT MAX(CASE WHEN ((codigo_fun in ('033','334','336','337','904') AND codigo_ref = 1) OR (codigo_fun = '002' AND codigo_ref in (37,30,40,41,42,50)))THEN fecha_mov ELSE date(1) END) fecha_ult_mov,
         SUM(CASE WHEN codigo_fun = '002' AND codigo_ref in (37,937,938) THEN monto ELSE 0 END) comp_comer, --Compras a Comercio
         SUM(CASE WHEN codigo_fun = '002' AND codigo_ref IN (30,40,41,42) THEN monto ELSE 0 END) disp_caj, --Disposiciones en cajero
         SUM(CASE WHEN codigo_fun = '002' AND codigo_ref in (50,60) THEN monto ELSE 0 END) mto_disp_sucu,--Monto de disposiciones en sucursal
--         SUM(CASE WHEN codigo_fun IN ('033','334','336','337','904')  AND codigo_ref = 901 THEN monto ELSE 0 END) dep_sdo_favor, --Depositos Saldo a Favor
         SUM(CASE WHEN codigo_fun = '002' AND codigo_ref IN (60, 61, 62, 63, 64, 65) THEN monto ELSE 0 END) ret_sdo_favor, --Retiros Saldo a Favor
         SUM(CASE WHEN codigo_fun = '033' AND codigo_ref = 6212 THEN monto ELSE 0 END) mto_com_repo,--Monto comision reposicion
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref = 18 THEN monto ELSE 0 END) mto_com_ret_caj_conv, --Monto comision retiro cajero convenio
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref = 17 THEN monto ELSE 0 END) mto_com_ret_caj_red, --Monto comision retiro cajero red
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref = 19 THEN monto ELSE 0 END) mto_com_ret_caj_inter, --Monto comision retiro cajero INter
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref = 25 THEN monto ELSE 0 END) mto_com_cons_caj_conv, --Monto comision consulta cajero convenio
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref in (24,994,993) THEN monto ELSE 0 END) mto_com_cons_caj_red, --Monto comision consulta cajero red
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref in (26,996,995) THEN monto ELSE 0 END) mto_com_cons_caj_inter, --Monto comision consulta cajero Inter
         SUM(CASE WHEN codigo_fun IN ('333','339') AND codigo_ref IN (50,51,6901,6902) THEN monto ELSE 0 END) com_disp_ventanilla, --comision por dispocision en ventanilla
         SUM(CASE WHEN codigo_fun = '340' AND codigo_ref IN (1,2) THEN monto ELSE 0 END) iva_com_gene, --iva de comisiones generadas
         SUM(CASE WHEN codigo_fun = '605' AND codigo_ref in (2,125,127) THEN monto ELSE 0 END) int_vig_gene, --Interes vigente generado
         SUM(CASE WHEN codigo_fun = '605' AND codigo_ref in (3,126,128) THEN monto ELSE 0 END) iva_int_vig_gene, --iva de Intereses vigente generado
         SUM(CASE WHEN codigo_fun = '604' AND codigo_ref in (2,7001) THEN monto ELSE 0 END) int_vdo_gene, --Interes vencido generado
         SUM(CASE WHEN codigo_fun = '340' AND codigo_ref in (22,23) THEN monto ELSE 0 END) iva_int_vdo_gdo, --iva de Intereses vencido generado
         SUM(CASE WHEN codigo_fun IN ('033', '334', '335', '336', '337','338','904','905') AND codigo_ref = 1 THEN monto ELSE 0 END) pagos,--Pagos
         SUM(CASE WHEN codigo_fun = '339' AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19) THEN monto ELSE 0 END)com_pagadas, --comisiones pagadas
         SUM(CASE WHEN codigo_fun = '340' AND codigo_ref IN (1,2) THEN monto ELSE 0 END) iva_com_pagado, --iva de comisiones pagado
         SUM(CASE WHEN codigo_fun IN('033','334','335','336','337','904','905') AND codigo_ref = 10 THEN monto ELSE 0 END) cap_vig_pagado, --Capital Vigente Pagado
         SUM(CASE WHEN codigo_fun IN('033','334','335','336','337','904','905') AND codigo_ref IN (7,8,907,908,909) THEN monto ELSE 0 END) cap_ven_pag,--capital vencido pagado
         0 int_vig_pagado,--INteres vigente pagado
         SUM(CASE WHEN codigo_fun IN('033','334','335','336','337','904','905') AND codigo_ref IN (3,5,903,925,926,923) THEN monto ELSE 0 END) int_vencido_pag,  -- interes vencido pagado
         SUM(CASE WHEN codigo_fun IN('033','334','335','336','337','904','905') AND codigo_ref = 2 THEN monto ELSE 0 END) int_mora_pagados, --INtereses moratorios pagados
         SUM(CASE WHEN codigo_fun IN('033','334','335','336','337','904','905') AND codigo_ref IN (6616,6617,11,12) THEN monto ELSE 0 END) iva_int_mora_pagado, --INtereses moratorios pagados
         SUM(CASE WHEN codigo_fun IN('033','334','336','337','904','905') AND codigo_ref IN (6640,6641,6652,6651,6650) THEN monto ELSE 0 END) iva_int_vencido_pag --iva de INtereses vencido pagado
      INTO v_fecha_ult_mov,v_comp_comer,v_disp_caj,v_mto_disp_sucu,v_ret_sdo_favor,v_mto_com_repo,v_mto_com_ret_caj_conv,
           v_mto_com_ret_caj_red,v_mto_com_ret_caj_inter,v_mto_com_cons_caj_conv,v_mto_com_cons_caj_red,v_mto_com_cons_caj_inter,
           v_com_disp_ventanilla, v_iva_com_gene,v_int_vig_gene,v_iva_int_vig_gene,v_int_vdo_gene,v_iva_int_vdo_gdo,
           v_pagos,v_com_pagadas,v_iva_com_pagado,v_cap_vig_pagado,v_cap_ven_pag,v_int_vig_pagado,v_int_vencido_pag,v_int_mora_pagados,
           v_iva_int_mora_pagado,v_iva_int_vencido_pag 
      FROM bdicred:sd_movhis
    WHERE  empresa = pempresa
     AND num_credito = v_num_credito
     AND reversado = "N"
     AND fecha_mov >=dFechaIni
     AND fecha_mov <=dFechaFin;


        SELECT (CASE WHEN codigo_fun in ('033','334','336','337','904') THEN 'PAGO' 
                ELSE CASE WHEN codigo_ref in (37,937,938) THEN 'COMPRA' ELSE 'DISPOSICION'END END) tipo_ult_mov
        INTO v_tipo_ult_mov         
        FROM sd_movhis WHERE empresa = pempresa
         AND num_credito = v_num_credito
         AND reversado = 'N' 
         AND secuencia = (SELECT MAX(secuencia) FROM sd_movhis WHERE empresa = pempresa AND num_credito = v_num_credito AND fecha_mov = v_fecha_ult_mov
         AND ((codigo_fun IN ('033','334','336','337','904') AND codigo_ref = 1) OR (codigo_fun = '002' AND codigo_ref in (37,937,938,30,40,41,42,50))))
         AND fecha_mov = v_fecha_ult_mov;


        INSERT INTO bdicred:sd_indica_cred VALUES(v_sucursal, v_num_credito, v_numcte, v_monto_otorgado, v_status_cred,v_meses_vencido,v_fecha_ult_mov, v_tipo_ult_mov,
                    v_fecha_nac,v_sexo,v_estado_civil,v_saldo,v_capital_vigente,v_capital_vencido,v_comp_comer, v_disp_caj, v_mto_disp_sucu, v_dep_sdo_favor, v_ret_sdo_favor,
                    v_mto_com_repo, v_mto_com_ret_caj_conv, v_mto_com_ret_caj_red, v_mto_com_ret_caj_inter, v_mto_com_cons_caj_conv, v_mto_com_cons_caj_red, v_mto_com_cons_caj_inter,
                    v_com_disp_ventanilla, v_iva_com_gene, v_int_vig_gene, v_iva_int_vig_gene, v_int_vdo_gene, v_iva_int_vdo_gdo, v_pagos, v_cap_vig_pagado, v_cap_ven_pag, v_com_pagadas,
                    v_iva_com_pagado, v_int_vig_pagado, 0, v_int_vencido_pag, v_iva_int_vencido_pag, v_int_mora_pagados, v_iva_int_mora_pagado, v_mora_debe_fin_mes);


     END FOREACH;


        LET cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || cfecha ||'_indicadores_credito.unl' || ' DELIMITER ' || '''|'''  ||
                   ' SELECT * FROM bdicred:sd_indica_cred ' ||
                   ' " > /resplogifx/archivoscartera/indicadores_credito_querys.sql';
        SYSTEM cSql;

        LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/indicadores_credito_querys.sql';
        SYSTEM SUBSTR(cSql,1,LENGTH(cSql));

        LET cSql = 'rm /resplogifx/archivoscartera/indicadores_credito_querys.sql';
        SYSTEM SUBSTR(cSql,1,LENGTH(cSql));  



RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;