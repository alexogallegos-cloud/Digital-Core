CREATE PROCEDURE "informix".sp_consulta_convenio_pba(pcategoria CHAR(2),pconvenio CHAR(3))
returning CHAR(5),CHAR(40),CHAR(1),CHAR(1),INTEGER,CHAR(1),CHAR(1),INTEGER,CHAR(1);
	--************************************************************--
	--**	Elaboró: Ramon Octavio Romero Mascareño       **--
	--**	Actividad: Consulta Convenio                                   **--
	--**	Solicito: Mauricio León						       **--
	--**	Fecha: 10/07/09								   **--
	--************************************************************--
	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE vflg_ref1		CHAR(1);
	DEFINE vflg_ref2		CHAR(1);
	DEFINE vlong_ref1		INTEGER;
	DEFINE vlong_ref2		INTEGER;
	DEFINE vflg_calculoref1	CHAR(1);
	DEFINE vflg_calculoref2	CHAR(1);
	DEFINE vNom_convenio		CHAR(40);
	DEFINE vstatus_convenio	CHAR(1);

	LET cod_err				="000";
	LET vflg_ref1			="";
	LET vflg_ref2			="";
	LET vlong_ref1			= 0;
	LET vlong_ref2			= 0;
	LET vflg_calculoref1	="";
	LET vflg_calculoref2	="";
	LET vNom_convenio		="";
	LET vstatus_convenio	="";

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err,vNom_convenio,vstatus_convenio,vflg_ref1,vlong_ref1,vflg_calculoref1,vflg_ref2,vlong_ref2,vflg_calculoref2;
      END IF ;
END EXCEPTION ;


    SELECT nomconvenio, statusconvenio,
		   flg_ref1, longitud_ref1, flgcalculodv_ref1,    	/*si tiene una referencia, obtiene longitud y rutina para validar dv*/
           flg_ref2, longitud_ref2, flgcalculodv_ref2    	/*si tiene una segunda referencia, obtiene longitud y rutina para validar dv*/
	INTO 	vNom_convenio, vstatus_convenio, vflg_ref1, vlong_ref1, vflg_calculoref1,
			vflg_ref2, vlong_ref2, vflg_calculoref2
    FROM BDISAC:sac_convenios
    WHERE numcategoria = pcategoria --02
    AND numconvenio = pconvenio;   --001

    IF vstatus_convenio = 'A' THEN
        LET cod_err = '000';
    ELSE
        LET cod_err = '001'; /*001 = el convenio no está activo*/
    END IF;

    RETURN cod_err,vNom_convenio,vstatus_convenio,vflg_ref1,vlong_ref1,vflg_calculoref1,vflg_ref2,vlong_ref2,vflg_calculoref2;
 END;
END PROCEDURE;