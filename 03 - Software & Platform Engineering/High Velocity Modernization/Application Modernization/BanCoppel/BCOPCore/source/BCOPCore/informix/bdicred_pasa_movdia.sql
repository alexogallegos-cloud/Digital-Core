CREATE PROCEDURE "informix".pasa_movdia()


        INSERT INTO sd_movhis SELECT * FROM sd_movdia;
        TRUNCATE sd_movdia;

END PROCEDURE;