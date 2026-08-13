CREATE PROCEDURE "informix".sp_llena_ctescoppel_contdc(pempresa char(3))

RETURNING CHAR(6)
--Autor: Diana Castellanos, 24-08-2007
--Solicita: Juan A Coronel M
--SP para llenar tabla donde se lleva control de ctes coppel que ya tienen Tarj de Cred BanCoppel.
--Esta tabla será replicada a coppel para promoción de tarjeta de credito en cajas de tiendas coppel.
--Modifica: Juan A. Coronel, actualizar nombre de tabla donde se almacenan datos y validar null.

DEFINE sCod_Ret          CHAR(6);
DEFINE iSecuencia        INTEGER;
DEFINE cNumCte           CHAR(20);
DEFINE cNumCteCoppel     CHAR(20);
DEFINE vsqlerr           INTEGER;

LET sCod_Ret   = "000000";
LET iSecuencia = 0;
LET vsqlerr    = 0;
LET cNumCte    = "";
LET cNumCteCoppel = "";


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RollBack Work;
      RETURN sCod_Ret;
   END IF;
END EXCEPTION;

    Begin Work;

    SELECT NVL(MAX(secuencia),0)+1 INTO iSecuencia FROM sd_clientescoppelcontdc;

    FOREACH
    Select distinct a.numcte, a.numcte_ref 
    Into cNumCte,cNumCteCoppel 
    From bdinteg:si_cliente a 
    Inner Join sd_maecred b On a.empresa = b.empresa and a.numcte = b.numcte
    Left Join sd_clientescoppelcontdc c On a.numcte = c.numcte
    Where a.empresa = pempresa
    and nvl(a.numcte_ref,0) > 0
    and c.numcte is null

        INSERT INTO sd_clientescoppelcontdc(secuencia, numcte, numctecoppel)
        VALUES(iSecuencia,cNumCte,cNumCteCoppel);

        LET iSecuencia = iSecuencia + 1;

    END FOREACH;

    Commit Work;
    RETURN scod_ret;
END;
END PROCEDURE;