create procedure "informix".sp_mail_remanentepagmin(pempresa char (3),pfechacorte date)
returning VARCHAR(6);
--DEFINE pempresa          char(3);
DEFINE pnumcredito       char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pmontofinanciado  decimal(18,2);
DEFINE pfechaact         date;
DEFINE pfechaant         date;
DEFINE pfechahoy         date;

--DEFINE vempresa  char(3);
DEFINE cProceso  char(4);
DEFINE cCod_ret  smallint;
DEFINE cMensaje  char (100); 
DEFINE pdia      date; 
DEFINE pfechaarmada date; 
 


DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    RETURN P_COD_RET;
    END exception;
 
    let P_COD_RET = '111111';
    let cCod_ret = '';
    let cMensaje = '';
    let cProceso = '2022';
	
	--valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	IF NVL (pfechacorte, '') = '' THEN
        LET cCod_Ret= '104008';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
       IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
		
	
    Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa ;

    delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos= 31;     
    select limit 1 dia_corte into pdia from bdicred:sd_maecredanexo where empresa = pempresa ;
     
   
   let pfechaarmada = mdy(month(pfechacorte),day(pdia),year(pfechacorte));
   let pfechaact = date(pfechacorte);

   if (pfechacorte <= pfechaarmada) then
        let pfechaant = date (pfechaarmada) - 1 units month + 1 units day;
   end if;
   if (pfechacorte > pfechaarmada ) then
        let pfechaant = date (pfechaarmada) + 1 units day;
   end if;   

	
   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

set isolation to dirty read;
foreach 
     
    SELECT   a.num_credito, a.numcte, b.email, f.monto_financiado Pago_minimo
        INTO  pnumcredito, pnumcte, pemail, pmontofinanciado
	FROM bdicred:sd_maecred a
		inner join bdinteg:si_ctepf b on ( b.empresa=a.empresa and b.numcte = a.numcte)
		join bdicred:sd_maecredanexo d on (  d.empresa = a.empresa  and d.num_credito = a.num_credito)
		join bdicred:sd_maesdos f on (f.empresa = a.empresa and f.num_credito = a.num_credito)
    WHERE  a.status_cred = 'AA' 
       AND nvl(b.email, '') <> ''
       and d.fecha_ult_pago between pfechaant and  pfechaact
       and f.monto_financiado > 0
	   

    call "informix".sp_mail_inserta_cliente (pempresa,1, pnumcte, pnumcredito, pemail,pmontofinanciado,0,31,0,null,null,null,0,0)
    returning P_COD_RET;
    let P_COD_RET = '000000';

end foreach
	 call  "informix".sp_inserta_mensaje('001',1,0,31) RETURNING P_COD_RET;
            let P_COD_RET = '000000';  	  

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
    RETURN P_COD_RET;
END PROCEDURE;