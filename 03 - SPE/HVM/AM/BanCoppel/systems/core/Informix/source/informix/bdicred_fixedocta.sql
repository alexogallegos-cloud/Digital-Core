create procedure "informix".fixedocta(pempresa char (3))
returning char(5);


DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE sql_err          INTEGER;
DEFINE cod_ret	CHAR(5);
DEFINE cod_ret2         char(5);
DEFINE cod_ret3         char(5);
DEFINE cod_ret4         char(5);

DEFINE v_fecha 	        DATE;

LET v_fecha 	= "/03/20/2008";
LET v_empresa 	= pempresa;
LET v_num_credito 	= "";
--SET DEBUG FILE TO "FixEdo.out";
--TRACE ON;
BEGIN
ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;

            RETURN cod_ret;
        END IF
   END EXCEPTION;

        -------------------------------------------------------
        --SE INICIALIZA TABLA PARA EDOCTAS
        ------------------------------------------------------
        IF EXISTS (select  tabname  from systables where tabname = "sd_movhisedocta" and tabid > 99 and tabtype="T")
        THEN
        DROP TABLE SD_MOVHISEDOCTA;
        END IF;
        --------------------------------------------------------
        CREATE TABLE sd_movhisedocta
          (
            empresa char(3) not null ,
            secuencia serial not null ,
            fecha_mov date not null ,
            hora_mov datetime hour to fraction(3) not null ,
            sucursal char(4),
            num_credito char(20) not null ,
            plaza char(3) not null ,
            transacc_suc char(4) not null ,
            usuario char(8) not null ,
            monto decimal(18,2) not null ,
            codigo_fun char(3) not null ,
            codigo_ref integer not null ,
            divisa char(2) not null ,
            reversado char(1) not null ,
            folio_suc char(16) not null ,
            num_producto char(4) not null ,
            nro_tarjeta varchar(20,1),
            referencia varchar(40,1),
            tipo_cambio decimal(14,6),
            monto_dls decimal(14,2),
            suc_origen varchar(4,1),
            rfc_comer varchar(20,1),
            referencia23 varchar(23,1),
            primary key (fecha_mov,num_credito,sucursal,hora_mov,secuencia,empresa)
          );
        revoke all on sd_movhisedocta from "public";

        create index inx_arrmovhis on sd_movhisedocta
            (folio_suc,codigo_fun,codigo_ref) using btree;
        create unique index inx_movedocta on sd_movhisedocta
            (empresa,num_credito,fecha_mov,reversado,secuencia) using
            btree;
        create unique index inx_movhisedocta on sd_movhisedocta
            (empresa,num_credito,codigo_fun,codigo_ref,fecha_mov,reversado,
            secuencia) using btree;
        create index numcrededocta on sd_movhisedocta
            (num_credito) using btree;

        ------------------------------------------------------
        --PREPARA LA TABLA  PARA EDOCTAS
        -------------------------------------------------------
        INSERT INTO sd_movhisedocta
                select a.empresa,a.secuencia,a.fecha_mov,a.hora_mov,a.sucursal,
                       a.num_credito,a.plaza,a.transacc_suc,a.usuario,a.monto,
                       a.codigo_fun,a.codigo_ref,a.divisa,a.reversado,a.folio_suc,a.num_producto,
                       a.nro_tarjeta,a.referencia,a.tipo_cambio,a.monto_dls,a.suc_origen,
                       a.rfc_comer,a.referencia23
                from sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
                where a.empresa = "001"
                and  a.codigo_fun = b.codigo_fun
                and a.codigo_ref  = b.codigo_ref
                and c.numero = b.transacc
				and c.sistema ="06"
                and c.se_emite_edocta = "S"
                and fecha_mov > "02/20/2008"
                and fecha_mov <= "03/20/2008"
                and reversado <> "S";
	
        UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;

	--------------------------------------------------------
	--SE CREA LA TABLA DE PASO
	--------------------------------------------------------
	IF EXISTS (select  tabname  from systables where tabname = "cred21" and tabid > 99 and tabtype="T")
	THEN
        DROP TABLE cred21;
	END IF;

	CREATE TABLE cred21(
	num_credito char(20) not null
	); 
	revoke all on cred21 from "public";
	--------------------------------------------------------
        --SE OBTIENEN LOS CREDITOS QUE NOS INTERESAN
	---------------------------------------------------------
	insert into cred21
        select unique num_credito from sd_movhisedocta
	where fecha_mov = "02/21/2008";
	----------------------------------------------------
	--SE BORRAN LOS CREDITOS21 PARA INSERTALOS NUEVAMENTE
	delete from sd_encabezado2_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
	
        delete from sd_detalle_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
	
        delete from sd_pie_edocta
	where num_credito in (select num_credito from cred21)
        and fecha_emision = "03/20/2008";
        --------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
	FOREACH SELECT num_credito
		INTO v_num_credito
 		FROM cred21
        
	LET cod_ret = "000";

    	EXECUTE PROCEDURE informix.uencabezado2layout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret2;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret2;
    	END IF
	EXECUTE PROCEDURE informix.udetallelayout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret3;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret3;
    	END IF
	EXECUTE PROCEDURE informix.upielayout_edocuenta(v_empresa,v_num_credito,v_fecha) INTO cod_ret4;
    	IF cod_ret =  "000"  THEN
    	LET cod_ret =cod_ret4;
    	END IF


 	END FOREACH;

END;
	RETURN cod_ret;
END PROCEDURE;