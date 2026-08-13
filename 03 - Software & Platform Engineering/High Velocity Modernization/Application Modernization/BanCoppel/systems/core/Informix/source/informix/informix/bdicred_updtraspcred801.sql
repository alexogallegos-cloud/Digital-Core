CREATE PROCEDURE "informix".updtraspcred801(fecha_inicial date)
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
DEFINE cVarDataErr      CHAR(100);
DEFINE vchrcodret 	CHAR(5);
DEFINE vintcodret	INTEGER;
DEFINE vcuantos 	INTEGER;
DEFINE vmodificados 	INTEGER;
DEFINE vleidos 	        INTEGER;
DEFINE vreferencia	    CHAR(80);
DEFINE vchrfolio        CHAR(16);
DEFINE vfolio           CHAR(16);
DEFINE vtransaccion     CHAR(4);
DEFINE vusuario         CHAR(4);
DEFINE vchrtransuc      CHAR(4);
DEFINE vsucursal        CHAR(4);
DEFINE vdivisa          CHAR(2);
DEFINE vhora            CHAR(15);
DEFINE vnum_credito     CHAR(20);
DEFINE vchrTarjeta      CHAR(16);
DEFINE vimporte_abono   MONEY(14,2);
DEFINE vempresa         CHAR(3);
DEFINE v_codigo_fun     CHAR(3);
DEFINE v_codigo_ref     INTEGER;
DEFINE v_fecha_mov      DATE;


LET cVarDataErr = '';
LET vchrTarjeta = '';
LET vnum_credito = '';
LET v_codigo_fun = '';
LET v_codigo_ref = 0;
LET v_fecha_mov = date(1);
LET vfolio = '';
LET vreferencia = '';
LET vchrcodret = '000';
LET vempresa = '001';


BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
         rollback work;
    	   LET vchrcodret = vintcodret;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --//DEBUG FLAG
    --SET debug file to "/informix/gpe/updtraspcred801.out";
    --TRACE ON;

-- DIVISAS
    select abrev_divisa,cod_divisa from intercard:cat_paisdivisa
	group by abrev_divisa,cod_divisa
    into temp cat_paisdivisa_VIC;

    create unique index cat_paisdivisa_VIC_index on cat_paisdivisa_VIC(cod_divisa);
    update statistics medium for table cat_paisdivisa_VIC;

-- VIC
    select * from bditarjeta:td_movimientos_conciliacion_his
    where archivo_origen in ('VIC','MCC')
      and date(fechaconcilia) >= fecha_inicial - 180
    union all
    select * from bditarjeta:td_movimientos_conciliacion
    where archivo_origen in ('VIC','MCC') 
      and date(fechaconcilia) >= fecha_inicial - 180
    into temp td_movimientos_conciliacion_VIC with no log;

    create index td_movimientos_conciliacion_VIC_inx on td_movimientos_conciliacion_VIC(numtarjeta,folio_mov);
    update statistics medium for table td_movimientos_conciliacion_VIC;
	-- Se agregan Nuevos codigos IFRS
    select a.num_credito, 
           a.fecha_mov, 
           a.codigo_fun, 
           a.codigo_ref, 
           a.folio_suc,
           a.nro_tarjeta, 
           trim(a.folio_suc)|| ' '||trim(nomcomercio325)||' $'||round((b.monto_divisa325/100),2)||' '||trim(c.abrev_divisa)||' T.C $'||round((a.monto/(b.monto_divisa325/100)),2) referencia
    from bdicred:sd_movhisedocta a
    left outer join td_movimientos_conciliacion_VIC b on (a.folio_suc = b.folio_mov and a.nro_tarjeta = b.numtarjeta)
    left outer join cat_paisdivisa_VIC c on (b.divisa325 = c.cod_divisa)
    where a.codigo_fun = '002'
      and a.codigo_ref  IN (37,937,938)
      and a.reversado = 'N'
      and b.monto_divisa325 is not null
      into temp td_referencia_VIC with no log;

    create index td_referencia_VIC_index on td_referencia_VIC(num_credito);
    update statistics medium for table td_referencia_VIC;

    FOREACH WITH HOLD
 
        SELECT num_credito, 
               fecha_mov, 
               codigo_fun, 
               codigo_ref, 
               folio_suc,
               nro_tarjeta, 
               referencia
          INTO vnum_credito,
               v_fecha_mov,
               v_codigo_fun, 
               v_codigo_ref,
               vfolio,
               vchrTarjeta,
               vreferencia
          FROM td_referencia_VIC

        begin work;

            UPDATE sd_movhisedocta SET referencia = trim(vreferencia)
                WHERE empresa = vempresa
                  AND num_credito = vnum_credito
                  AND codigo_fun = v_codigo_fun 
                  AND codigo_ref = v_codigo_ref
				  AND fecha_mov = v_fecha_mov
                  AND reversado <> "S"
                  AND folio_suc = vfolio
                  AND nro_tarjeta = vchrTarjeta;
       
        commit work;
    END FOREACH

    --//Entrega el codigo de retorno 
    RETURN vchrcodret;

END
END PROCEDURE;