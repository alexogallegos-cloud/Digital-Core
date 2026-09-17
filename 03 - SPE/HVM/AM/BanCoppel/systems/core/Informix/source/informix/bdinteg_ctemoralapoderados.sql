CREATE PROCEDURE "informix".ctemoralapoderados(
                                         eEmpresa      CHAR(3),
                                         eNumCte       CHAR(20),
                                         vSecuencia    INTEGER,
                                         vNumCteApode  CHAR(20),
                                         vNomApodera   CHAR(60),
                                         vUsuario     CHAR(20),
                                         vFecha        DATE)



RETURNING CHAR(5);

 DEFINE vcod_ret             CHAR(5);
 DEFINE vsqlerr              INTEGER;


 LET vcod_ret ='000';
 LET vsqlerr  = 0;


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcod_ret=vsqlerr;
        RETURN vcod_ret;
      END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/informix/ash/cteapo.out";
    --TRACE ON;

    if exists(select numcteapoderado from si_apoderado where numcte = eNumCte) then
         UPDATE bdinteg:si_apoderado SET secuencia = vSecuencia,
                                         numcteapoderado = vNumCteApode,
                                         nombreapoderado = vNomApodera,
                                         user_insert     = vUsuario,
                                         fecha_insert    = vFecha
         WHERE empresa = eEmpresa AND numcte = eNumCte;
     else
	INSERT INTO bdinteg:si_apoderado (secuencia,numcteapoderado,nombreapoderado,empresa,numcte,user_insert,fecha_insert)
	VALUES     (vSecuencia,vNumCteApode,vNomApodera,eEmpresa,eNumCte,vUsuario,vFecha);
     end if;
END
  RETURN vcod_ret;
END PROCEDURE;