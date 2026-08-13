create procedure "informix".sp_actualizacodfechaenvio(pTipo CHAR(1),pNomArch CHAR(16),pCod_Envio CHAR(5), pStatus CHAR(1) )
RETURNING CHAR(6);

    --*************************************************
	--Creado por: Anselmo Verdugo                   --*
	-- Actividad: Realiza actualización del campo fecha_envio y cod_envio.
    --  Solicitó: Aymme Osuna                       --*
	--     Fecha: 08/OCT/2008                       --*
    --*************************************************



-- DEFINICIÓN DE LAS VARIABLES.
DEFINE vcCodRet CHAR(6);
DEFINE sql_err  INTEGER;
DEFINE vdFechaError DATE;
DEFINE vcMensaje CHAR(100);
DEFINE cErrorSP  CHAR(6);
DEFINE vcArchivoCT CHAR(16);


    

      --MANEJADOR DE EXEPCIONES
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            ROLLBACK WORK;
            IF vcCodRet <> 0 THEN

                IF pTipo = '0' THEN 
                    LET vcMensaje = 'Error trantando de actulizar CODIGO DE ENVIO, STATUS y FECHA DE ENVIO en tabla sl_archsat';
                END IF;
                IF pTipo = '1' THEN 
                    LET vcMensaje = 'Error trantando de actulizar CODIGO DE ENVIO y STATUS en tabla sl_archsat';
                END IF;

                IF pTipo = '2' THEN 
                    LET vcMensaje = 'Error trantando de actulizar CODIGO DE ENVIO y STATUS en tabla sl_archsat';
                END IF;
                IF pTipo = '3' THEN 
                    LET vcMensaje = 'Error trantando de actulizar ESTADO en tabla sl_consat';
                END IF;
                IF pTipo = '4' THEN 
                    LET vcMensaje = 'Error trantando de actulizar ESTADO en tabla sl_procesos de un archivo de envio al SAT.';
                END IF;
                IF pTipo = '5' THEN 
                    LET vcMensaje = 'Error trantando de actulizar ESTADO en tabla sl_consat y STATUS en sl_archsat con archivo: ' ;
                END IF;

            execute procedure bdilide:sp_grabarErrores(pNomArch, vcCodRet, 'P', 'sp_actualizaCodFechaEnvio', vcMensaje, 'N')  into cErrorSP;
            END IF;

            RETURN vcCodRet;
        END EXCEPTION;


--    SET DEBUG FILE TO "/home/informix/sp_actualizaEnvio.out";
--	TRACE ON;


--INICIALIZACIÓN DE VARIABLES
LET vcCodRet = '000';
LET vcMensaje = '';
LET cErrorSP = '';
LET vcArchivoCT = 'CT';

BEGIN WORK;
    -- si tipo es igual a 0 se actualiza CODIGO DE ENVIO, FECHA_ENVIO y STATUS.
    IF pTipo = '0' THEN 

       -- IF EXISTS( select nombre_arch from bdilide:sl_archsat where nombre_arch = pNomArch ) THEN
            
            SELECT NVL(fecha_hoy,'01/01/1900')   INTO vdFechaError  FROM bdinteg:si_fechas;
            update bdilide:sl_archsat set cod_envio = trim(pCod_Envio) where nombre_arch = pNomArch;
            update bdilide:sl_archsat set fecha_envio = vdFechaError where nombre_arch = pNomArch;
            update bdilide:sl_archsat set status = pStatus where nombre_arch = pNomArch;
        --ELSE
            --execute procedure bdilide:sp_grabarErrores('GENERICO', '7777', 'P', 'sp_actualizaCodFechaEnvio', 'No se puede actualizar CODIGO DE ENVIO del archivo ' || pNomArch  || ' por que no existe en la tabla sl_archsat', 'N')  into cErrorSP;
        --END IF;

    --si tipo es igual a 1 se actualiza CODIGO DE ENVIO y STATUS.
    ELIF pTipo = '1' THEN

        --IF EXISTS( select nombre_arch from bdilide:sl_archsat where nombre_arch = pNomArch ) THEN
            
            update bdilide:sl_archsat set status = pStatus, cod_envio = trim(pCod_Envio) where nombre_arch = pNomArch;
            --update bdilide:sl_archsat set cod_envio  where nombre_arch = pNomArch;
        --ELSE
          --  execute procedure bdilide:sp_grabarErrores('GENERICO', '7777', 'P', 'sp_actualizaCodFechaEnvio', 'No se puede actualizar FECHA DE ENVIO del archivo ' || pNomArch  || ' por que no existe en la tabla sl_archsat', 'N')  into cErrorSP;
        --END IF;

    --si tipo es igual a 2 se actualiza el status del archivo.
    ELIF pTipo = '2' THEN
     
		--IF EXISTS( select nombre_arch from bdilide:sl_archsat where nombre_arch = pNomArch ) THEN
            
            update bdilide:sl_archsat set status = pStatus where nombre_arch = pNomArch;
        --ELSE
        --    execute procedure bdilide:sp_grabarErrores('GENERICO', '7777', 'P', 'sp_actualizaCodFechaEnvio', 'No se puede actualizar el STATUS DEL ARCHIVO del archivo ' || pNomArch  || ' por que no existe en la tabla sl_archsat', 'N')  into cErrorSP;

        --END IF;

    ELIF pTipo = '3' THEN
            
            update bdilide:sl_consat set estado = pStatus where nombre_arch = pNomArch;
    ELIF pTipo = '4' THEN

            
            update bdilide:sl_procesos set status = pStatus where proceso = pNomArch;
            
            IF substr(pNomArch,1,2) = 'CC' THEN
                LET vcArchivoCT = trim(vcArchivoCT) || trim(substr(pNomArch,3,length(pNomArch)-2));
                update bdilide:sl_procesos set status = pStatus where proceso = vcArchivoCT;
            END IF;
    
    -- la opcion 5 actualiza estado en 'E' en la tabla sl_consat, status 'E' en sl_archsat de los archivo CC y CT.
    ELIF pTipo = '5' THEN

            
            update bdilide:sl_consat set estado = pStatus where nombre_arch = pNomArch;
            update bdilide:sl_archsat set status = pStatus where nombre_arch = pNomArch;
            IF substr(pNomArch,1,2) = 'CC' THEN
                LET vcArchivoCT = trim(vcArchivoCT) || trim(substr(pNomArch,3,length(pNomArch)-2));
                update bdilide:sl_archsat set status = pStatus where nombre_arch = vcArchivoCT;
            END IF;

    ELSE
        LET vcCodRet = '001';
    END IF;

COMMIT WORK;
RETURN vcCodRet;

end procedure;