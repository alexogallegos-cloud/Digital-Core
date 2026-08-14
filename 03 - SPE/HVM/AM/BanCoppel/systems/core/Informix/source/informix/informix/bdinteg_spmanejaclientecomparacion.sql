CREATE PROCEDURE "informix".spmanejaclientecomparacion(pTipo SMALLINT, pNumcte INTEGER, pStatus CHAR, pReferencia INTEGER, pSecuencia INTEGER, pKeyx INTEGER, pFechamov DATETIME year to second, pSecuenciaReferencia INTEGER)
RETURNING INTEGER;

DEFINE vCodret INTEGER;

BEGIN
    LET vCodret = 0;

        IF EXISTS(SELECT secuencia FROM si_clientecomparacioncoppel WHERE tipo = pTipo AND numcte = pNumcte AND referencia = pReferencia AND secuencia = pSecuencia) THEN
            LET vCodret = 1;
        ELSE
            INSERT INTO si_clientecomparacioncoppel
                (tipo, numcte, secuencia, status, referencia, fechamov, keyxcoppel, secuenciareferencia)
            VALUES
                (pTipo, pNumcte, pSecuencia, pStatus, pReferencia, pFechamov, pKeyx, pSecuenciaReferencia );
        END IF;

    RETURN vCodret;
END;
END PROCEDURE;