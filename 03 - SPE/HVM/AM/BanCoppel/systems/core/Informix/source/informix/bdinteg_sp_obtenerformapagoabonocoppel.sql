CREATE PROCEDURE "informix".sp_obtenerformapagoabonocoppel(p_cFolioSuc CHAR(16))
RETURNING CHAR(6), INTEGER;

	DEFINE iSqlErr 	INTEGER;
	DEFINE formapago INTEGER;
	DEFINE  cod_ret CHAR(6);
	
	ON EXCEPTION SET iSqlErr
		LET cod_ret = iSqlErr;
		LET formapago = 0;
		RETURN cod_ret, formapago;
	END EXCEPTION;
	
	LET cod_ret = '000000';
	LET formapago = 0;
	
	BEGIN
		SELECT NVL(SUM(CAST(forma_pago AS INTEGER)),0)
		INTO formapago
		FROM bdisac:sac_movimientos
		WHERE folio_suc = p_cFolioSuc;		
	END
	RETURN cod_ret, formapago;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Se encarga de obtener el tipo de pago de un abono coppel en la reimpresion de tickets de boletos',
'EJECUTADO O LLAMADO POR: CJ003002.EXE',
'FECHA : NOVIEMBRE/2009',
'VERSION: 200911',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_cambiarpass_bpi(pEmpresa char(3), pNumCte char(20), pPass char(50))
   returning char(5);

   --Creador: Javier Humberto Calderón Zazueta
   --Actividad: Actualiza el password del usuario de BPI
   --Solicito Mauricio León
   --Fecha 09-12-09


--
-- Define variables
--
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

--
-- Inicializa variables
--
   LET cod_ret  = 000;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN
		IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte AND pass = pPass) THEN
			 LET cod_ret = '001';  -- Ya existe el pass
		ELSE
			IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte AND pass1 = pPass) THEN
				 LET cod_ret = '001';  -- Ya existe el pass
			ELSE
				IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte AND pass2 = pPass) THEN
					 LET cod_ret = '001';  -- Ya existe el pass
				ELSE
					IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte AND pass3 = pPass) THEN
						 LET cod_ret = '001';  -- Ya existe el pass
					ELSE
						UPDATE bdinteg:si_bpiusuarios SET pass3 = TRIM(pass2), f_pass3 = current WHERE empresa = pEmpresa AND numcte = pNumCte;
						UPDATE bdinteg:si_bpiusuarios SET pass2 = TRIM(pass1), f_pass2 = current WHERE empresa = pEmpresa AND numcte = pNumCte;
						UPDATE bdinteg:si_bpiusuarios SET pass1 = TRIM(pass), f_pass1 = current WHERE empresa = pEmpresa AND numcte = pNumCte;
						UPDATE bdinteg:si_bpiusuarios SET pass = TRIM(pPass), f_pass = current WHERE empresa = pEmpresa AND numcte = pNumCte;

						LET cod_ret = '000';  -- Pass modificado
					END IF;
				END IF;
			END IF;
		END IF;

   ELSE

        LET cod_ret = '002';  -- No existe el Cliente

   END IF ;

   RETURN cod_ret;

END

END PROCEDURE;