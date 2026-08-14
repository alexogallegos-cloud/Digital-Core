       IDENTIFICATION DIVISION.
       PROGRAM-ID. UDMSIIWR.
      *================================================================*
      * CAPA: UTIL (HUB)  ·  Fan-in = 449 (el mas alto del sistema)     *
      * PROPOSITO: Wrapper de escritura auditada a DMSII                *
      * LLAMADO POR: ~449 programas de todos los dominios              *
      * [CRITICO] Tocar este programa impacta a casi todo el sistema.  *
      *           Es el nodo de mayor blast radius en la migracion.    *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-RETCODE.
       LINKAGE SECTION.
       01  LS-AREA             PIC X(512).
       01  LS-RC.
           05  LS-RC-CODE      PIC 9(04).
           05  LS-RC-MSG       PIC X(80).
       PROCEDURE DIVISION USING LS-AREA LS-RC.
       0000-PRINCIPAL.
      *    Escritura con auditoria DMSII + log via otro hub
           ENTER "UAUDITWR" USING LS-AREA.
           IF LS-RC-CODE = 0
               CONTINUE
           ELSE
               ENTER "ULOGWRT" USING LS-RC
           END-IF.
           EXIT PROGRAM.