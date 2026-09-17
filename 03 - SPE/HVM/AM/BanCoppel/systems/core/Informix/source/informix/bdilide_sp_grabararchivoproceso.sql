CREATE PROCEDURE "informix".sp_grabararchivoproceso(pTipo CHAR(1), pArchivo1 CHAR(16), pArchivo2 CHAR(16), pStatus CHAR(1),pUsuario CHAR(8) )
RETURNING CHAR(6);

	 --*************************************************
	--Creado por: Anselmo Verdugo                   --*
	-- Actividad: Realiza registro a la tabla bdilide:sl_archsat y sl_procesos.
    --  Solicitó: Aymme Osuna                       --*
	--     Fecha: 10/OCT/2008                       --*
    --*************************************************

-- DEFINICIÓN DE LAS VARIABLES.
DEFINE vcCodRet CHAR(6);
DEFINE sql_err  INTEGER;
DEFINE vdFechaHoy DATE;
DEFINE vcMensaje CHAR(100);
DEFINE cErrorSP  CHAR(6);
DEFINE vcErrorTipo CHAR(2);



        --MANEJADOR DE EXEPCIONES
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            rollback work;
            IF pTipo = '0' THEN
                LET vcMensaje = 'Error tratando de la inserccion en sl_archsat del archivo: '|| pArchivo1 ;
            END IF;

            IF pTipo = '1' THEN
                LET vcMensaje = 'Error tratando de la inserccion en sl_procesos del archivo: ' || pArchivo1 ;
            END IF;


            execute procedure bdilide:sp_grabarErrores('GENERICO', vcCodRet, 'P', 'sp_grabarArchivoProceso', vcMensaje, 'N')  into cErrorSP;            

            RETURN vcCodRet;
        END EXCEPTION;


    --SET DEBUG FILE TO "/home/informix/sp_grabarArchivoProceso.out";
	--TRACE ON;

--INICIALIZACIÓN DE VARIABLES
LET vcCodRet = '000';
LET cErrorSP = '';


begin work;
    
    SELECT NVL(fecha_hoy,'01/01/1900')   INTO vdFechaHoy  FROM bdinteg:si_fechas;

    -- se verifica la NO existencia del archivo1

    IF pTipo = '0' THEN
        INSERT INTO bdilide:sl_archsat VALUES(pArchivo1,vdFechaHoy,'','',pStatus,'0','',pUsuario,CURRENT::DATE);
--        INSERT INTO bdilide:sl_procesos VALUES(pArchivo2,vdFechaHoy,'0',pUsuario,CURRENT::DATE);

    ELIF pTipo = '1' THEN

       IF NOT EXISTS ( select proceso from bdilide:sl_procesos where proceso = pArchivo1) THEN
            INSERT INTO bdilide:sl_procesos VALUES(pArchivo1,vdFechaHoy,'0',pUsuario,CURRENT::DATE);
       ELSE
            -- 002 indica que el registro en sl_procesos si existe.
            LET vcCodRet = '002';
       END IF;

    ELIF pTipo <> '2' and pTipo <> '1' THEN
        LET vcCodRet = '001';
    END IF;


commit work;
RETURN vcCodRet;

END PROCEDURE;