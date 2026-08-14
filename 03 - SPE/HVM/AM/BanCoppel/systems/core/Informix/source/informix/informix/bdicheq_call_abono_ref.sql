CREATE PROCEDURE "informix".call_abono_ref( pempresa     CHAR(3),
                                       psucursal    CHAR(4),
                                       pusuario     CHAR(8),
                                       ptransacc    CHAR(4),
                                       ptransuc     CHAR(4),
                                       pfolio_suc   CHAR(16),
                                       pcuenta      CHAR(20),
                                       pdocto       INTEGER,
                                       pmto_tot     MONEY(14,2),
                                       pmto_firme   MONEY(14,2),
                                       pmto_sbc     MONEY(14,2),
                                       pmto_rem     MONEY(14,2),
                                       pdias_ret    SMALLINT,
                                       pdivisa      CHAR(2),
                                       preferencia  CHAR(40),
                                       pnum_tarjeta CHAR(16),
                                       pusuautoriza CHAR(8) )
RETURNING CHAR(5) as vcodret;
    
    DEFINE vcodret              CHAR(5); 
    
    
    LET vcodret         = "000";
    
BEGIN
    
    EXECUTE PROCEDURE "informix".abono_ref( pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolio_suc, 
    	pcuenta, pdocto, pmto_tot, pmto_firme,pmto_sbc, pmto_rem, pdias_ret, pdivisa, preferencia, pnum_tarjeta, pusuautoriza) 
        into vcodret;
    
    RETURN vcodret;
end;
END PROCEDURE;