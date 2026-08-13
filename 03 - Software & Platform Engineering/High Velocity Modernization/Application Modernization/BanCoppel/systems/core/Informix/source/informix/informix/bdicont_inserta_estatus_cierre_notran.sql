CREATE PROCEDURE "informix".inserta_estatus_cierre_notran(pempresa char(3),
                                        pfecha_hoy DATE,
                                        pdescri_cierre CHAR(20),
                                        pestatus_cierre CHAR(20),
                                        pcodigo_retorno CHAR(5),
                                        pusuario char(8),
                                        psucursal  CHAR(4),
                                     phora_inicio CHAR(12),
                                     phora_fin CHAR(12))
  RETURNING char(5);

  DEFINE  codret CHAR(5);
  DEFINE sql_err INTEGER;
  DEFINE isam_err INTEGER;
  DEFINE error_info CHAR(40);

    LET pusuario = USER;

    SELECT bdinteg:si_ejecut.sucursal
    INTO  psucursal
    FROM bdinteg:si_ejecut
    WHERE bdinteg:si_ejecut.ejecutivo = USER;

    INSERT INTO co_cierre_cif
    VALUES ( pempresa,pfecha_hoy,pdescri_cierre,pestatus_cierre,
             pcodigo_retorno,pusuario,psucursal,phora_inicio,phora_fin);

    RETURN "000";

END PROCEDURE;