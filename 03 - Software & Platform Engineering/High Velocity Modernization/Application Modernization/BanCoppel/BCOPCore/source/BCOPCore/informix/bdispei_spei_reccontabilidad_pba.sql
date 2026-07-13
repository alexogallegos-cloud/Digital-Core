CREATE PROCEDURE "informix".spei_reccontabilidad_pba(pempresa CHAR(3)) 
RETURNING CHAR(5);
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    
    DEFINE wfecha_hoy       DATE;
    DEFINE wchrempresa      CHAR(3);
    DEFINE wpendientes      INTEGER;
    DEFINE wintpkpasecont   INTEGER;
    DEFINE wchrsucursal     CHAR(4);
    DEFINE wccmayor         CHAR(4);
    DEFINE wccsub           CHAR(2);
    DEFINE wccsubsub        CHAR(2);
    DEFINE wccssubsub       CHAR(2);
    DEFINE wccsssubsub      CHAR(2);
    DEFINE wccsector        CHAR(2);
    DEFINE wccauxiliar      CHAR(2);
    DEFINE wchrtransaccion  CHAR(2);
    DEFINE wchrdivisa       CHAR(2);
    DEFINE vexiste          CHAR(4);
    DEFINE wfech_habil      DATE;
    DEFINE wfecha_habil     CHAR(10);
    
    DEFINE vcodretrpt1      CHAR(5);
    DEFINE vcodretrpt2      CHAR(5);
    DEFINE vcodretrpt3      CHAR(50);

    LET sql_err        = 0;
    LET isam_err       = 0;
    LET vcodret1       = "00000";
    LET vcodret2       = "00000";
    
    LET wfecha_hoy      = '';
    LET wchrempresa     = '001';
    LET wpendientes     = 0;
    LET wintpkpasecont  = 0;
    LET wchrsucursal    = '9201';
    LET wccmayor        = '';
    LET wccsub          = '';
    LET wccsubsub       = '';
    LET wccssubsub      = '';
    LET wccsssubsub     = '';
    LET wccsector       = '';
    LET wccauxiliar     = ' ';
    LET wchrtransaccion = ' ';
    LET wchrdivisa      = '01';
    LET vexiste         = '';
    LET wfech_habil     = '';
    LET wfecha_habil    = '';
    
    LET vcodretrpt1 = '000';
    LET vcodretrpt2 = '000';
    LET vcodretrpt3 = '';
    
    --- SET DEBUG FILE TO "/tmp/spei_reccontabilidad.out";
    --- TRACE ON;

    BEGIN
         
        EXECUTE PROCEDURE bdicheq:"informix".sp_rptmovsdiariospei(wchrempresa)
        INTO vcodretrpt1, vcodretrpt2, vcodretrpt3;
        

    
    RETURN vcodret1;
    
    END;
    
END PROCEDURE;