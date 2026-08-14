CREATE PROCEDURE "informix".sp_validaspei_bpi(pCtaOrigen VARCHAR(20), pCtaDestino VARCHAR(20))
 returning char(3), varchar(100);

 
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(3);
DEFINE sql_err integer;
DEFINE com_err varchar(100);
DEFINE vCteOrigen varchar(9);
DEFINE vCteDestino varchar(9);
DEFINE vStatusCtaOr varchar(2);
DEFINE cCtaDestino integer;

--INICIALIZA VARIABLES
LET cod_ret  = "000";
LET com_err = "";
LET vCteOrigen = "";
LET cCtaDestino = 0;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, "ocurrio una excepcion";
      END IF ;
   END EXCEPTION ;
   
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    SELECT num_cte,status_cta           ---OBTENIENDO EL  NUMCTE
    INTO vCteOrigen,vStatusCtaOr
    FROM bdicheq:sc_maechq WHERE cuenta = pCtaOrigen;                
    
    IF NVL(vCteOrigen, "") <> "" THEN
         
         SELECT count(*)
         INTO cCtaDestino
         FROM bdiprog:pp_ctasterceros
         WHERE num_cte = vCteOrigen AND cuenta = pCtaDestino AND cve_estado = '01';


         IF NVL(cCtaDestino,0) > 0 THEN
            RETURN '000',"";
         ELSE
            LET cod_ret = '501';
            LET com_err = "La cuenta destino no esta registrada " || pCtaDestino;
            
                INSERT INTO bdinteg:si_bpinusuales(
                 f_registro,
                 id_operacion, 
			     cta_origen, 
                 cta_destino,
			     cod_err, 
			     desc_err) VALUES (current,'1015',pCtaOrigen,pCtaDestino,cod_ret,com_err);
        	RETURN cod_ret,com_err;
         END IF;
    ELSE
       LET cod_ret = '502';
       LET com_err = "La cuenta origen no existe o está inactiva " || pCtaOrigen;
       INSERT INTO bdinteg:si_bpinusuales(
                 f_registro,
                 id_operacion, 
			     cta_origen,
                 cta_destino,
			     cod_err, 
			     desc_err) VALUES (current,'1015',pCtaOrigen,pCtaDestino,cod_ret,com_err);
        RETURN cod_ret,com_err;
    END IF;

	END;
END PROCEDURE;