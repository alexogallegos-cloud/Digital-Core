CREATE PROCEDURE "informix".spsp_resumen_anexo(p_identautoridad    VARCHAR(8),
                              p_empresa           CHAR(3),
                              p_clavereporte      VARCHAR(10),
                              p_claveperiodicidad VARCHAR(2),
                              p_claveprioridad    SMALLINT)
       RETURNING char(3), varchar(255);
   -- ********** Definicion de Variables **********
   --De Retorno
   DEFINE r_codret      char(3);
   DEFINE r_mensaje     varchar(255);
   --De Filtroresumen
   DEFINE v_renglon     INTEGER;
   DEFINE v_columna     INTEGER;
   DEFINE v_saldo       DECIMAL(18,4);
   DEFINE v_fecha 		DATE;
   --De Renglones
   DEFINE v_naturaleza  VARCHAR(2);
   DEFINE v_grupo       VARCHAR(3);
   -- ********** Debug del Procedure **********
   --LET r_mensaje = r_mensaje || v_claveprioridad;
   --LET r_codret = '999';
   --LET r_mensaje = 'PROCESO EN CONSTRUCCION';
   --RETURN r_codret, r_mensaje;
   -- *****************************************
   --Borra el Resumen del Filtro
   DELETE
   FROM    sp_filtroresumen_anexo
   WHERE   identautoridad = p_identautoridad
   AND     empresa        = p_empresa
   AND     clavereporte   = p_clavereporte;
   --Inserta el Resultado del Resumen
   INSERT INTO sp_filtroresumen_anexo
          SELECT identautoridad, empresa,       clavereporte,
                 numerorenglon,  numerocolumna,
                 SUM(SPSP_FSIGNO(saldocifra, signo)),fecha
          FROM   sp_filtroreporte_anexo f
          WHERE  identautoridad = p_identautoridad
          AND    empresa        = p_empresa
          AND    clavereporte   = p_clavereporte
          GROUP  BY identautoridad, empresa,       clavereporte,
                    numerorenglon,  numerocolumna,fecha;
   FOREACH SELECT f.numerorenglon, f.numerocolumna, f.saldo,
                  r.naturaleza,    r.grupo,fecha
           INTO   v_renglon,       v_columna,       v_saldo,
                  v_naturaleza,    v_grupo,v_fecha
           FROM   sp_filtroresumen_anexo f, sp_renglones r
           WHERE  r.identautoridad = f.identautoridad
           AND    r.empresa        = f.empresa
           AND    r.clavereporte   = f.clavereporte
           AND    r.numerorenglon  = f.numerorenglon
           AND    f.identautoridad = p_identautoridad
           AND    f.empresa        = p_empresa
           AND    f.clavereporte   = p_clavereporte
      --Coloca el Saldo Verificado
      LET v_saldo = SPSP_VERIFICA(v_saldo, v_naturaleza);
      --Depende el Grupo coloca el Dato
      IF v_grupo = "POS" THEN
         IF v_saldo < 0 THEN
            LET v_saldo = v_saldo * -1;
         END IF;
      ELIF v_grupo = "NEG" THEN
         IF v_saldo > 0 THEN
            LET v_saldo = v_saldo * -1;
         END IF;
      END IF;
      --Actualiza el Saldo insertado
      UPDATE sp_filtroresumen_anexo
      SET    saldo = v_saldo,fecha= v_fecha
      WHERE  identautoridad = p_identautoridad
      AND    empresa        = p_empresa
      AND    clavereporte   = p_clavereporte
      AND    numerorenglon  = v_renglon
      AND    numerocolumna  = v_columna
	  AND 	 fecha 			= v_fecha;
   END FOREACH;
   --Dependiendo la Clave Ejecuta el Proceso
   IF p_claveperiodicidad = "M" THEN
      IF p_clavereporte = 'SIFSD' OR p_clavereporte = 'SIFSP' THEN
         EXECUTE PROCEDURE SPSP_INTRESUM(p_identautoridad,
                                         p_empresa,
                                         p_clavereporte)
              INTO r_codret, r_mensaje;
         IF r_codret <> '000' THEN
            LET r_mensaje = 'ERR. RESUMEN : ' ||
                            r_codret || ' ' || r_mensaje;
            LET r_codret = '003';
            RETURN r_codret, r_mensaje;
         END IF;
      END IF;
   ELIF p_claveperiodicidad = "R" THEN
      ---EXECUTE PROCEDURE sumnivel();
   END IF;
   --Ejecuta el Resumen Detallado
   IF p_claveprioridad = 2 THEN
      ---EXECUTE PROCEDURE resumdet(v_claveperiod) into cod_ret;
   END IF;
   --Si el Reporte es SIFSD o SIFSP borra los datos en cero
   IF p_clavereporte = 'SIFSD' OR p_clavereporte = 'SIFSP' THEN
      --Obtiene los datos en cero
      FOREACH SELECT numerorenglon, SUM(saldo),fecha
              INTO   v_renglon, v_saldo,v_fecha
              FROM   sp_filtroresumen_anexo
              WHERE  identautoridad = p_identautoridad
              AND    empresa        = p_empresa
              AND    clavereporte   = p_clavereporte
              GROUP  BY numerorenglon,fecha
              HAVING SUM(saldo) = 0
         --Borra datos del FiltroResumen
         DELETE 
         FROM   sp_filtroresumen_anexo
         WHERE  identautoridad = p_identautoridad
         AND    empresa        = p_empresa
         AND    clavereporte   = p_clavereporte
         AND    numerorenglon  = v_renglon
		 AND    fecha 		   = v_fecha;
      END FOREACH;
   END IF;
   --Ejecuta el Proceso de Niveles
   ---EXECUTE PROCEDURE sumniv() into cod_ret;
   --Termina El Proceso
   LET r_codret = '000';
   LET r_mensaje = 'PROCESO EXITOSO';
   RETURN r_codret, r_mensaje;
END PROCEDURE;