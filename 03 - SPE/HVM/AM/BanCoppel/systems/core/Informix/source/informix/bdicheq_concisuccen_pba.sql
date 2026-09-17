CREATE PROCEDURE "informix".concisuccen_pba(pempresa char(3),
                                        psistema char(2),
                                        pfolio_suc char(16))
       RETURNING char(5),CHAR(20);

DEFINE vcodret          CHAR(5);
DEFINE sqlerr           INTEGER;
DEFINE vexiste          CHAR(1);
DEFINE vresultado       CHAR(20);


LET vcodret    =  "000";
LET vresultado = "Folio No Encontrado";
LET vexiste = "";

BEGIN
   ON EXCEPTION
      SET sqlerr
      LET vcodret = sqlerr;
      LET vresultado = sqlerr;
      RETURN vcodret,vresultado;
   END EXCEPTION;

   IF psistema = "" or pfolio_suc = "" then
      let vcodret = "110";
      let vresultado = "REINTENTE";
      return vcodret,vresultado;
   END IF
   -- Lee Cheques
   IF psistema = "SC" THEN
      FOREACH
        SELECT cancelad INTO vexiste
        FROM   bdicheq:sc_movdia
        WHERE  empresa = pempresa  and folio_suc = pfolio_suc
        IF vexiste is null THEN
           LET vresultado = "Folio No Encontrado";
           LET vcodret = "221";
           EXIT FOREACH;
        ELSE
           IF vexiste = "S" THEN
              LET vresultado = "Folio Reversado";
              LET vcodret = "222";
              EXIT FOREACH;
           ELSE
              LET vresultado = "Folio O.K.";
              LET vcodret = "000";
              EXIT FOREACH;
           END IF
        END IF
      END FOREACH
   END IF
   -- Lee Inversiones
   IF psistema = "SV" THEN
      FOREACH
        SELECT cancelad INTO vexiste
        FROM   bdinvers:sv_movdia
        WHERE  folio_suc = pfolio_suc
        IF vexiste is null THEN
           LET vresultado = "Folio No Encontrado";
           LET vcodret = "221";
           EXIT FOREACH;
        ELSE
           IF vexiste = "S" THEN
              LET vresultado = "Folio Reversado";
              LET vcodret = "222";
              EXIT FOREACH;
           ELSE
              LET vresultado = "Folio O.K.";
              LET vcodret = "000";
              EXIT FOREACH;
           END IF
        END IF
     END FOREACH
   END IF
   -- Lee Credito
   IF psistema = "SD" THEN
      FOREACH
        SELECT reversado INTO vexiste
        FROM   bdicred:sd_movdia
        WHERE  folio_suc = pfolio_suc
        IF vexiste is null THEN
           LET vresultado = "Folio No Encontrado";
           LET vcodret = "221";
           EXIT FOREACH;
        ELSE
           IF vexiste = "S" THEN
              LET vresultado = "Folio Reversado";
              LET vcodret = "222";
              EXIT FOREACH;
           ELSE
              LET vresultado = "Folio O.K.";
              LET vcodret = "000";
              EXIT FOREACH;
           END IF
        END IF
      END FOREACH
   END IF

   return vcodret,vresultado;
END;
RETURN vcodret,vresultado;
END PROCEDURE;