CREATE PROCEDURE "informix".cambio_producto_intercard()
RETURNING CHAR(05),char(80);

        DEFINE icliente         varchar(13);
        DEFINE itarjeta         varchar(16);
        DEFINE inombre          varchar(104);

        DEFINE cSql             CHAR(2024);

        DEFINE icodret          char(5);
        DEFINE cMensaje         char(80);
        DEFINE sql_err          integer;
        DEFINE isam_err         integer;

ON EXCEPTION SET sql_err,isam_err,cMensaje
    LET icodret = sql_err;
    RETURN icodret,cMensaje;
END EXCEPTION;

     --   set debug file to "CAMBIOPRODUCTO.sql";
     --   trace on;

        LET icodret="00000";
        LET cSql="";
        LET cMensaje='';

        set isolation to dirty read;

        select numtarjeta
        from intercard:Movimiento
        where metodocaptura = '01' and tipotransaccionposdigitada in ('CE','AV') 
        group by numtarjeta
        union all
        select numtarjeta
        from intercard:Movimientohistorico
        where metodocaptura = '01' and tipotransaccionposdigitada in ('CE','AV') 
        group by numtarjeta into temp temp_cambio_producto;


    FOREACH WITH HOLD
        select numtarjeta
        into itarjeta
        from temp_cambio_producto
	group by numtarjeta
        
    begin work;

            UPDATE intercard:Tarjeta set codproductotarjeta='003'
            WHERE numtarjeta=itarjeta and codproductotarjeta='001' and codstatustarjeta='ACT';

    commit work;

    END FOREACH;

    RETURN icodret,cMensaje;

end procedure;