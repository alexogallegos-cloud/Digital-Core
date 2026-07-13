CREATE PROCEDURE "informix".sp_upd_bm_usuarios(fech_registro_ant datetime year to fraction(3)
, fech_registro_new datetime year to fraction(3) , pNumclt char(20) )
  DEFINE cCodRet CHAR(5);

    IF fech_registro_new >= fech_registro_ant OR (fech_registro_new IS NOT NULL AND fech_registro_new <> ' ') THEN

      EXECUTE PROCEDURE bdimnsj:sp_registra_evento ( 2,'BMV_ALTAUS', pNumclt,'', '',1, '', 
	  '', '', '', '', 0, 0,0, 0, 0, fech_registro_new, '') INTO cCodRet;
	
	END IF

END PROCEDURE
;