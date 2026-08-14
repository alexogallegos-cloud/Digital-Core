create procedure "informix".sp_mail_inserta_cliente( pempresa CHAR(3), ptipo_mensaje SMALLINT, pnumcte CHAR(20), 
                                                     pnum_credito CHAR(20), pemail CHAR(60),ppago_minimo DECIMAL(18,2), 
                                                     psaldo_total DECIMAL(18,2), ppagos_vencidos DECIMAL(18,2), 
                                                     pmonto_convenio DECIMAL(18,2), pfecha_convenio DATE, pfecha_compac DATE, 
                                                     pfecha_primercons DATE, penviado SMALLINT,pcumplio_compac SMALLINT ,
													 ppago_venc DECIMAL(18,2), ppago_min_sin_venc DECIMAL(18,2), psdo_venc_int_mora DECIMAL(18,2))
returning VARCHAR(6);

DEFINE pfechahoy          DATE;
DEFINE pestatus           char (2);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

BEGIN 
   ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO;
     rollback work;
     RETURN P_COD_RET;
   END exception;
 let P_COD_RET = '000000';
  Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = '001';
LET pestatus = 'AC';

    if nvl(pempresa,'') = '' then
        let P_COD_RET ="200000";
    end if
    if nvl(pnumcte,'') = '' then
        let P_COD_RET ="200001";
    end if
     if nvl(pnum_credito,'') = '' then
        let P_COD_RET ="200002";
    end if
    if nvl(pemail,'') = '' then
        let P_COD_RET ="200003";
    end if

    INSERT INTO bdicobranza:cb_mail_cliente (empresa , tipo_mensaje,fecha_insert, numcte , 
                                         num_credito , email ,pago_minimo , saldo_total , 
                                         pagos_vencidos ,monto_convenio ,fecha_convenio, 
                                         fecha_compac, fecha_primercons, estatus, enviado, cumplio_compac,
										  pago_venc , pago_min_sin_venc , sdo_venc_int_mora )
    VALUES(pempresa , ptipo_mensaje,pfechahoy, pnumcte ,  
            pnum_credito , pemail ,ppago_minimo , psaldo_total ,  
            ppagos_vencidos , pmonto_convenio , pfecha_convenio,  
            pfecha_compac, pfecha_primercons, pestatus, penviado, pcumplio_compac,
			ppago_venc , ppago_min_sin_venc , psdo_venc_int_mora);
 let P_COD_RET = '000000';
end
RETURN P_COD_RET;
END PROCEDURE;