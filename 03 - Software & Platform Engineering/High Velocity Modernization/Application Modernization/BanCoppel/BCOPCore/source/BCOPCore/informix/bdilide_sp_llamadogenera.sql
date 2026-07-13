create procedure "informix".sp_llamadogenera()
RETURNING  char(10),CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1);

DEFINE cNombreArch CHAR(20);
DEFINE cNombreArchSp CHAR(20);
DEFINE cNombreConSp CHAR(20);
DEFINE cCompleArch CHAR(15);
DEFINE cNombreCon CHAR(20);
DEFINE cCompleCon CHAR(15);
DEFINE cNumArch CHAR(1);
DEFINE cNumCon CHAR(1);
DEFINE cMensaje CHAR(10);
DEFINE cCodRet CHAR(6);
DEFINE  cNombreError CHAR(20);
DEFINE  pTipoError CHAR(1);
DEFINE pSpLLamado CHAR(40);
DEFINE pMensaje CHAR(200);
DEFINE  pMostrado CHAR(1);
LET cNombreArch = '';
LET cCompleArch = '';
LET cNombreCon = '';
LET cCompleCon = '';
LET cNumArch = '';
LEt cNumCon = '';
LET cMensaje = '';
LET cCodRet = '';
LET cNombreError = '';
LET  pTipoError = '';
LET  pSpLLamado = '';
LET  pMensaje = '';
LET pMostrado = '';
LET cNombreConSp = '';
LET cNombreArchSp = '';
    --SET DEBUG FILE TO "/home/informix/llamadogenera.out";
	--TRACE ON;
    begin
            IF EXISTS( select nombre_arch  From bdilide:sl_archsat where status = 'T' AND nombre_arch LIKE 'RC%') THEN
                        SELECT nombre_arch INTO cNombreArch FROM bdilide:sl_archsat  WHERE status = 'T' AND nombre_arch LIKE 'RC%';

                        LET cCompleArch = cNombreArch;
                        LET cNumArch = SUBSTR(cNombreArch,3,3);
                        LET cCompleArch = SUBSTR(cCompleArch,4,13);
                        SELECT nombre_arch INTO cNombreCon FROM bdilide:sl_archsat  WHERE status = 'T' AND nombre_arch LIKE 'RT%';

                        LET cCompleCon = cNombreCon;
                        LET cNumCon = SUBSTR(cNombreCon,3,3);
                        LET cCompleCon = SUBSTR(cCompleCon,4,13);
                        IF (cNumArch = cNumCon) and (cCompleArch = cCompleCon) THEN
                            LET cNombreArchSp = cNombreArch;
                            LET cNombreConSp = cNombreCon;
                            --LET cMensaje = 'ejecucion 2';
                            EXECUTE PROCEDURE bdilide:sp_generaarchivosat('02','informix',cNombreArch,cNombreCon) into cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                        END if;
             END IF;
           IF EXISTS( select nombre_arch  From bdilide:sl_archsat where status = 'I')    THEN
                        SELECT nombre_arch INTO cNombreArch FROM bdilide:sl_archsat  WHERE status = 'I';
                           -- LET cMensaje = 'ejecucion 03';
                            EXECUTE PROCEDURE bdilide:sp_generaarchivosatsegundo('03','informix',cNombreArch,'') into cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
            END if;

             IF EXISTS( select nombre_arch  From bdilide:sl_archsat where status = 'T' AND nombre_arch LIKE 'IC%') THEN
                        SELECT nombre_arch INTO cNombreArch FROM bdilide:sl_archsat  WHERE status = 'T' AND nombre_arch LIKE 'IC%';

                        LET cCompleArch = cNombreArch;
                        LET cNumArch = SUBSTR(cNombreArch,3,3);
                        LET cCompleArch = SUBSTR(cCompleArch,4,13);
                        SELECT nombre_arch INTO cNombreCon FROM bdilide:sl_archsat  WHERE status = 'T' AND nombre_arch LIKE 'IT%';
                        LET cCompleCon = cNombreCon;
                        LET cNumCon = SUBSTR(cNombreCon,3,3);
                        LET cCompleCon = SUBSTR(cCompleCon,4,13);
                        IF (cNumArch = cNumCon) and (cCompleArch = cCompleCon) THEN
                            LET cNombreArchSp = cNombreArch;
                            LET cNombreConSp = cNombreCon;
                           -- LET cMensaje = 'ejecucion 4';
                            EXECUTE PROCEDURE bdilide:sp_generaarchivosatsegundo('04','informix',cNombreArch,cNombreCon) into cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                        END if;
            END IF;

             IF EXISTS( select nombre_arch  From bdilide:sl_archsat where status = 'A' ) THEN
                        SELECT nombre_arch INTO cNombreArch FROM bdilide:sl_archsat  WHERE status = 'A';
                            --LET cMensaje = 'ejecucion 5';
                            EXECUTE PROCEDURE bdilide:sp_generaarchivosatsegundo('05','informix',cNombreArch,'') into cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
            END IF;
            return cMensaje,cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
    end;
end procedure;