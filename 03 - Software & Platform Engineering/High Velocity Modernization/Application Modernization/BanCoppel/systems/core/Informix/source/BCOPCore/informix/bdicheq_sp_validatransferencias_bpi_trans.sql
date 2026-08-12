CREATE PROCEDURE "informix".sp_validatransferencias_bpi_trans(pEmpresa char(3), pCtaOrigen char(20), pCtaDestino char(20))
returning char(5),char(100);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE vCodRet char(5);
    DEFINE vDesc char(100);
    DEFINE vCteOrigen varchar(9);
    DEFINE vCteDestino varchar(9);
    DEFINE vStatusCtaOr varchar(2);
    DEFINE sql_err integer;

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET vCodRet = "00000";
    LET vDesc = "";
    LET vCteOrigen = "";
    LET vCteDestino = "";
    LET vStatusCtaOr = "";
    LET sql_err = 0;

    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vDesc;
        END IF
    END exception;

    SET ISOLATION DIRTY READ ;

    SELECT num_cte, status_cta 
      INTO vCteOrigen, vStatusCtaOr
      FROM bdicheq:sc_maechq
     WHERE empresa = pEmpresa 
       AND cuenta = pCtaOrigen;
	   
	   

    --- IF NVL(vCteOrigen,'') <> "" AND vStatusCtaOr = 1 THEN
    IF ( NVL(vCteOrigen,'') <> "" AND vStatusCtaOr NOT IN('2','6','7') ) THEN
        SELECT numcte_tf  
          INTO vCteDestino
        --FROM bdicheq:sc_maechq
		  FROM bditransfer:'informix'.tf_maecte
     --- WHERE empresa = pEmpresa AND num_cte = vCteOrigen AND cuenta = pCtaDestino AND status_cta = '1';
         WHERE (telefono = pCtaDestino  OR cuenta_tf = pCtaDestino )           
		   AND empresa = pEmpresa 		   
           AND status_cta <> '2';

        IF NVL(vCteDestino,'') = "" THEN
            SELECT num_cte 
              INTO vCteDestino
              FROM bdiprog:pp_ctasterceros
             WHERE num_cte = vCteOrigen 
               AND cuenta = pCtaDestino 
               AND cve_estado = '01';

            IF NVL(vCteDestino,'') <> "" THEN
                RETURN vCodRet,vDesc;
            ELSE
                LET vCodRet = '50001';
                LET vDesc = "La cuenta destino no esta registrada " || pCtaDestino;

                INSERT INTO bdinteg:si_bpinusuales(id_operacion, cta_origen, cta_destino, cod_err, desc_err, f_registro)
                VALUES ('1016', pCtaOrigen, pCtaDestino, vCodRet, vDesc, current);

                RETURN vCodRet, vDesc;
            END IF;
        ELSE
            RETURN vCodRet, vDesc;
        END IF;
    ELSE
        LET vCodRet = '50002';
        LET vDesc = "La cuenta origen no existe " || pCtaOrigen;

        INSERT INTO bdinteg:si_bpinusuales(id_operacion, cta_origen, cta_destino, cod_err, desc_err, f_registro)
        VALUES ('1008', pCtaOrigen, pCtaDestino, vCodRet, vDesc, current);

        RETURN vCodRet, vDesc;
    END IF;

    END
    
END PROCEDURE;