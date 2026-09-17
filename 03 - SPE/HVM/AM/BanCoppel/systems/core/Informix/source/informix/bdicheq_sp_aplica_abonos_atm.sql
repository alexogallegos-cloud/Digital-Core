CREATE PROCEDURE "informix".sp_aplica_abonos_atm()
	   RETURNING char(5);

DEFINE psucursal   char(4);
DEFINE pusuario    char(8);
DEFINE pserial     integer;
DEFINE ptransacc   char(4);
DEFINE pfolio_suc  char(16);
DEFINE pcuenta     char(20);     
DEFINE pmto_tot    decimal(16,2);
DEFINE preferencia char(30);
DEFINE pnum_tarjeta char(16);
DEFINE vcodret     char(5);
DEFINE vcodret2    char(5);
DEFINE vsqlerr     integer;
DEFINE visamerr     integer;
DEFINE v_hora      CHAR(15);
DEFINE v_fecha     date;
DEFINE v_hora2      char(8);
DEFINE vexiste     smallint;

LET vcodret = "000";
LET v_hora = current hour to second;

BEGIN
on exception SET vsqlerr,visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 =visamerr;
            return vcodret;
        END IF
end exception;

set isolation to dirty read;
set lock mode to wait 3;

--Set debug file to "/DBA/spei_julio/sp_aplica_abonos_atm.out";
--trace on;

FOREACH WITH HOLD 
        SELECT num_serial, sucursal, usuario, transaccion, cuenta, num_tarjeta, monto_tot, referencia
		INTO pserial, psucursal, pusuario, ptransacc, pcuenta, pnum_tarjeta, pmto_tot, preferencia
		FROM sc_abonos_atm
		WHERE aplicado NOT IN('N', 'S')

        SELECT COUNT(*)
		  INTO vexiste
		  FROM sc_movdia
		 WHERE cuenta = pcuenta
           AND transacc = '0952'
           AND cancelad = 'S'
           AND monto_tot = pmto_tot;

        IF vexiste = 0 THEN		   

			BEGIN WORK;		
        
			LET v_hora = CURRENT HOUR TO FRACTION;
			LET pfolio_suc = 'ATM'||v_hora[1,2]||v_hora[4,5]||v_hora[7,8];
			LET psucursal = psucursal;
			LET pfolio_suc = pfolio_suc;
			LET pcuenta = pcuenta;
			LET pmto_tot = pmto_tot;
			LET pnum_tarjeta = pnum_tarjeta;
		
			call abono_ref('001',psucursal,pusuario,ptransacc,'0000',pfolio_suc,pcuenta,0,pmto_tot,pmto_tot,0.0,0.0,0,'01',preferencia,pnum_tarjeta,' ')
				returning vcodret;
        
			IF vcodret = '000' THEN
				UPDATE sc_abonos_atm SET aplicado = 'S', fecha_abono = CURRENT
				 WHERE num_serial = pserial;
				COMMIT WORK;
			ELSE
				ROLLBACK WORK;
			END IF;

		ELSE 

			UPDATE sc_abonos_atm SET aplicado = 'N', fecha_abono = CURRENT
			 WHERE num_serial = pserial;
			COMMIT WORK;
		
		END IF;
				
END FOREACH ;
RETURN vcodret;
END;
END PROCEDURE;