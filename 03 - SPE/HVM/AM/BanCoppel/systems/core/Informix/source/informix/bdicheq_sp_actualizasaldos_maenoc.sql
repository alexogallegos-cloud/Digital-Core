CREATE PROCEDURE "informix".sp_actualizasaldos_maenoc()
    RETURNING CHAR(5);
    
    DEFINE saldo_mns2010                        DECIMAL(14,2);
    DEFINE vcodret                              CHAR(5);
    DEFINE cuenta_maenoc                        CHAR(20);
    DEFINE anio2010                             CHAR (4);

    BEGIN

   	--	SET DEBUG FILE TO "/ids10_1uc5/tmp/sp_actualizasaldos_maenoc.err";
   	--	TRACE ON;

	LET anio2010 = '2010';
		
		FOREACH
			select a.cuenta, a.capvigprom12
   			into cuenta_maenoc, saldo_mns2010
                	from bdicheq:sc_sdomensualc2010 a, bdicheq:sc_maenoc b
                	where
                	a.anio = anio2010 and
                	a.cuenta = b.cuenta and a.cuenta like '19%'

               		update sc_maenoc
			set sdo_prom_mesant = saldo_mns2010
			where
                	cuenta = cuenta_maenoc;
									
 		END FOREACH;
 			
    END;

END PROCEDURE;