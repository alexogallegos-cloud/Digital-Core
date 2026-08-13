CREATE PROCEDURE "informix".call_genmov(  
	p_empresa                VARCHAR(3),
   	p_num_credito            VARCHAR(20),
   	p_num_producto           VARCHAR(4),
   	p_codigo_ref             INTEGER,
   	p_codigo_fun             VARCHAR(3),
   	p_fecha_hoy              DATE,
   	p_monto                  MONEY(14,2),
   	p_foliosuc               VARCHAR(16),
   	p_sucursal               VARCHAR(4),
   	p_divisa                 VARCHAR(2),
   	p_transacc_suc           VARCHAR(4))
RETURNING VARCHAR(10) as codRet, VARCHAR(80) as mensaje;
    
    DEFINE   codRet       VARCHAR(10);
	DEFINE   mensaje       VARCHAR(80);
    
    
BEGIN
    
    EXECUTE PROCEDURE "informix".genmov(p_empresa,p_num_credito,p_num_producto, p_codigo_ref,
    	p_codigo_fun, p_fecha_hoy, p_monto, p_foliosuc,p_sucursal,p_divisa,p_transacc_suc) 
        into codRet, mensaje;
    
    RETURN codRet, mensaje;
end;
END PROCEDURE;