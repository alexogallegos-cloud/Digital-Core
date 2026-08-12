CREATE PROCEDURE "informix".sp_updstatistics_movhis()
RETURNING char(3) AS Respuesta;
BEGIN
    DEFINE vsRespuesta CHAR(3);
    LET vsRespuesta='000';

    UPDATE STATISTICS MEDIUM FOR TABLE sc_movhis;
    RETURN vsRespuesta;

END

END PROCEDURE;