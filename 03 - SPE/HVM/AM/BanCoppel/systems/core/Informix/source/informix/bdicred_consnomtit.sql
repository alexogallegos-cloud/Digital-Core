CREATE PROCEDURE "informix".consnomtit(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13), -- RFC
	CHAR(16); -- Número de Tarjeta


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC		CHAR(13);
	DEFINE vNumTarjeta	CHAR(16);
    DEFINE vNumProducto CHAR(4);

    --SET DEBUG FILE TO "/respaldosbd/Sonia/consnomtit.out"; 
	--TRACE ON;
		
	--INICIALIZACION DE VARIABLES--

	LET vCodRet		= "000";
	LET vNumCliente 	= "";
	LET vApePat		= "";
	LET vApeMat		= "";
	LET vNombre1		= "";
	LET vNombre2		= "";
	LET vRFC		= "";
	LET vNumTarjeta		= "";
    LET vNumProducto = "";
	
	SET LOCK MODE TO WAIT 3;

	SELECT
		dbc_sdmacre.num_producto,bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc, dbc_sdtarj.num_tarjeta
	INTO
		vNumProducto,vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarjeta
	FROM
		bdicred:"informix".sd_maecred dbc_sdmacre,
		bdicred:"informix".sd_tarjeta dbc_sdtarj,
		bdinteg:"informix".si_cliente bdi_sicte
	WHERE
        dbc_sdmacre.empresa = pEmpresa AND
		dbc_sdmacre.num_credito = pNumeroCuenta AND
        dbc_sdmacre.empresa = dbc_sdtarj.empresa AND
		dbc_sdmacre.num_credito = dbc_sdtarj.num_credito AND
		bdi_sicte.numcte = dbc_sdmacre.numcte AND
        dbc_sdtarj.tipo_tarjeta = "T"  AND
        dbc_sdtarj.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where dbc_sdmacre.empresa = empresa and dbc_sdmacre.num_credito = num_credito and tipo_tarjeta = "T");

	IF vApePat IS NULL AND vNombre1 IS NULL THEN
		LET vCodRet = "100";
	END IF

	IF vNumProducto IS NULL OR vNumProducto = "6600" THEN
		LET vCodRet = "135";
	END IF



	RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarjeta;
END PROCEDURE

DOCUMENT 
'MODIFICADO: Sonia Guzman Rodriguez',
'FECHA: 30/08/2011',
'MODIFICACION: Se modifico para que se consulten los clientes con tarjeta cancelada';

CREATE PROCEDURE "informix".sp_saldos_facturacion(wk_credito_ini char(20), wk_credito_fin char(20))
RETURNING  CHAR(6), CHAR(80);

DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cMensaje 		                CHAR(80); 
DEFINE cCod_ret                         CHAR(6);
DEFINE cSql                             CHAR(120);

DEFINE wk_num_credito                   CHAR(20);
DEFINE wk_numreg                        INTEGER;
DEFINE wk_status_cred                   CHAR(2);
DEFINE wk_sdo_contab_mora               DECIMAL(14,2);
DEFINE wk_monto_vencido                 DECIMAL(14,2); 
DEFINE wk_mto_venc_trasp                DECIMAL(14,2); 
DEFINE wk_monto_financiado              DECIMAL(14,2);
DEFINE wk_interes_vigente               DECIMAL(14,2);
DEFINE wk_iva_vigente                   DECIMAL(14,2);
DEFINE wk_interes_nominal               DECIMAL(14,2);
DEFINE wk_interes_copete                DECIMAL(14,2);
DEFINE wk_moratorio_total               DECIMAL(14,2);
DEFINE wk_secuencia                     INTEGER;



LET cCod_ret = '00000';
LET cMensaje = 'PROCESO EXITOSA';
LET sql_err = 0;

LET wk_num_credito      = '';
LET wk_numreg           = 0;
LET wk_status_cred      = '';
LET wk_sdo_contab_mora  = 0;
LET wk_monto_vencido    = 0;
LET wk_mto_venc_trasp   = 0;
LET wk_monto_financiado = 0;
LET wk_interes_vigente  = 0;
LET wk_iva_vigente      = 0;
LET wk_interes_nominal  = 0;
LET wk_interes_copete  = 0;
LET wk_moratorio_total  = 0;
LET wk_secuencia        = 0;


      BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
        rollback work;
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cMensaje;
	  END EXCEPTION;

--  SET DEBUG FILE TO "/pisa/leo/saldos_facturacion.out";
--  TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    select num_credito, count(*) cantidad, min(dias_acum_mora) dias_mora
    from bdicred:sd_maesdoshist 
    where empresa = '001' 
    and fecha = mdy('09','20','2011')
    and num_credito >= wk_credito_ini
    and num_credito < wk_credito_fin
    group by 1
    having count(*) > 1
    into temp paso1 with no log;

    create unique index inx_paso1 on paso1(num_credito);
    update statistics high for table paso1;

    select a.fecha, a.num_credito, min(a.rowid) numreg
    from bdicred:sd_maesdoshist a, paso1 b
    where a.empresa = '001' 
      and a.num_credito = b.num_credito
      and a.dias_acum_mora = b.dias_mora
      and fecha = mdy('09','20','2011')
    group by 1,2 
    into temp cred_his with no log;

    create index inx_cred_his on cred_his(numreg,fecha,num_credito);
    update statistics high for table cred_his;

    select 
    a.rowid numreg, 
    a.fecha, 
    a.num_credito, 
    sdo_cap_insoluto, 
    sdo_capital, 
    monto_vencido, 
    mto_venc_trasp, 
    monto_financiado, 
    cap_tras_no_venci, 
    mto_fin_ven_trasp mens_vencidas,
    case when (int_tra_no_exig - sdo_acum_mes_int) < 0 then 0 else int_tra_no_exig - sdo_acum_mes_int end interes_vencido,
    sdo_acum_mes_int interes_vigente,
    case when monto_vencido  > 0 then "BA" 
         when mto_venc_trasp > 0 then "BT" 
         else ''
    end status_cred,
    sdo_contab_mora
    from bdicred:sd_maesdoshist a, cred_his b
    where a.empresa = '001'     
      and a.num_credito = b.num_credito
      and a.fecha = b.fecha
      and a.rowid = b.numreg
    into temp cred_fac with no log;

    create index inx_cred_fac on cred_fac(numreg,fecha,num_credito);
    update statistics high for table cred_fac;

    foreach with hold
        select num_credito, numreg, status_cred, sdo_contab_mora, monto_vencido, mto_venc_trasp, monto_financiado, interes_vigente, round(interes_vigente * 0.156142,2)
          into wk_num_credito, wk_numreg, wk_status_cred, wk_sdo_contab_mora, wk_monto_vencido,wk_mto_venc_trasp, wk_monto_financiado, wk_interes_vigente, wk_iva_vigente
          from cred_fac

          begin work;

            -- Borra saldos
            delete from bdicred:sd_maesdos where empresa = '001' and num_credito = wk_num_credito;

            -- inserta saldos correctos
            insert into bdicred:sd_maesdos 
            (empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4) 
            SELECT empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4 
              from bdicred:sd_maesdoshist
             where empresa = '001'
               and num_credito = wk_num_credito
               and rowid = wk_numreg;

            -- actualiza status del credito
            update bdicred:sd_maecred set status_cred = wk_status_cred where empresa = '001' and num_credito = wk_num_credito;

            -- recostruye amortiza
            if (wk_status_cred = 'BA') then

                let wk_interes_nominal = round(wk_monto_vencido * 0.65 / 360,2);
                let wk_interes_copete  =  wk_sdo_contab_mora - wk_interes_nominal;

                update bdicred:sd_amortiza_credito set mora_provi_ordi = wk_interes_nominal, mora_provi_cope = wk_interes_copete, capital_status = '7'
                where empresa = '001' and num_credito = wk_num_credito and fecha_cuota = mdy('08','20','2011');

                update bdicred:sd_amortiza_credito set capital_mto_cuota = wk_monto_financiado - wk_monto_vencido, capital_debe = wk_monto_financiado - wk_monto_vencido, interes_debe = wk_interes_vigente, iva_debe = wk_iva_vigente
                where empresa = '001' and num_credito = wk_num_credito and fecha_cuota = mdy('09','20','2011');

                --actualziar movhis
                select max(secuencia) 
                 into wk_secuencia
                from bdicred:sd_movhis 
                where empresa = '001'
                and num_credito = wk_num_credito
                and fecha_mov = mdy('09','20','2011')
                and codigo_fun = '605' 
                and codigo_ref = 2 
                and usuario = 'informix';

                IF wk_secuencia IS NULL THEN let wk_secuencia = 999999999; end if;

                update bdicred:sd_movhis set reversado = 'S' where empresa = '001' and num_credito = wk_num_credito and fecha_mov = mdy('09','20','2011') and secuencia >= wk_secuencia and usuario = 'informix';

            end if;

            if (wk_status_cred = 'BT') then

                select nvl(sum(mora_provi_ordi + mora_provi_cope + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag),0)
                into wk_moratorio_total
                from bdicred:sd_amortiza_credito 
                where empresa = '001'
                and num_credito = wk_num_credito
                and capital_status = '2'
                and fecha_cuota < mdy('08','20','2011');

                let wk_sdo_contab_mora = wk_sdo_contab_mora - wk_moratorio_total;

                let wk_interes_nominal = round(wk_mto_venc_trasp * 0.65 / 360,2);
                let wk_interes_copete = wk_sdo_contab_mora - wk_interes_nominal;

                update bdicred:sd_amortiza_credito set mora_provi_ordi = wk_interes_nominal, mora_provi_cope = wk_interes_copete
                where empresa = '001' and num_credito = wk_num_credito and fecha_cuota = mdy('08','20','2011');

                update bdicred:sd_amortiza_credito set capital_mto_cuota = wk_monto_financiado - wk_mto_venc_trasp, capital_debe = wk_monto_financiado - wk_mto_venc_trasp, interes_debe = wk_interes_vigente, iva_debe = wk_iva_vigente
                where empresa = '001' and num_credito = wk_num_credito and fecha_cuota = mdy('09','20','2011');

                --actualziar movdia y movhis
                 update bdicred:sd_movhis set reversado = 'S' where empresa = '001' and num_credito = wk_num_credito and codigo_fun = '601' and codigo_ref = 2 and fecha_mov = mdy('09','20','2011') and usuario = 'informix';

            end if;
             
            -- borra historico duplicados
            delete from bdicred:sd_maesdoshist where empresa = '001' and fecha = mdy('09','20','2011') and num_credito = wk_num_credito and rowid <> wk_numreg;

          commit work;

    end foreach;


    LET cCod_ret = "000";
    LET cMensaje = "ACTUALIZACION EXITOSA";

RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;