CREATE PROCEDURE "informix".spl_devolucionspei(lngPkPagoOriginal integer, intFolioPaquete integer,mlngFolioPago integer,mstrMotivoDevolucion char(1) )
RETURNING char(5);


--SET debug file to "/pisa/spl_devolucionspei.out";
--TRACE ON;

DEFINE v_codret char(5); --CODIGO DE RETORNO
DEFINE intpkpaqueteenv1 integer; --CLAVE DEL PAQUETE
DEFINE intPkPago1 integer;


DEFINE dtFechaOp date;
DEFINE lngCveCesifOrd integer;
DEFINE lngCveCesifBenef integer;
DEFINE bytPrioridad char(1);
DEFINE mcurMonto decimal(19,0);
DEFINE mstrClaveRastreo varchar(30);

DEFINE mnyImportepaquete decimal(19,0);

set debug file to "/tmp/spl_devolucionspei.out";
trace on;

            --INICIALIZA EL CODIGO DE RETORNO A 000 PARA INDICAR EXITO EN LA OPERACION
                LET v_codret = "000";

                --OBTINE EL NUMERO DE FOLIO GENERADO PARA EL PAQUETE
                EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO  v_codret,intpkpaqueteenv1;
                IF v_codret != 0 THEN
                                --SE GENERO UN ERROR TERMINA LA INSTRUCCION
                                RETURN v_codret;
                END IF;

                --OBTIENE LOS DATOS DEL PAGO ORIGINAL
		 SELECT dtfechavalor,cvecesifbcoord ,
                    cvecesifbcodest,chrprioridad,mnyimporte ,vchrclaverastreo
                    INTO dtFechaOp,lngCveCesifOrd,lngCveCesifBenef,bytPrioridad,mcurMonto,mstrClaveRastreo
                    FROM tblpago WHERE intpkpago = lngPkPagoOriginal;
                                                  
                --Guarda en la base de datos el paquete
                INSERT INTO tblPaqueteEnv (
                    intpkpaqueteenv, intFolioPaquete, dtFechaOp,
                    chrTopologia, cvecesifbcoOrd, cvecesifbcoDest,
                    chrPrioridad, dtmFechaEnvio, intFolioAcuse,
                    mnyMonto, intNumPagos, chrSentidoPago, chrEstatus )
                    VALUES (
                     intpkpaqueteenv1, intFolioPaquete,dtFechaOp,
                     "V",lngCveCesifOrd,lngCveCesifBenef ,
                     bytPrioridad, dtFechaOp,0,
                    0, 1, "R", "N" );

                --AQUI EMPIESA A REGISTRAR CADA UNO DE LOS PAGOS

                                        --Obtiene el pk del pago original
                             /*   SELECT intpkpago FROM tblpago
                                         WHERE vchrclaverastreo = "mstrClaveRastreo" AND dtFechaValor = "Format(mdtFechaOperacion, mm/dd/yyyy)"
                                             AND cvecesifbcodest = "mlngCesifOrdenante"
                               */
                                        --Obtiene el Folio Siguiente
                                        EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO  v_codret,intPkPago1;
                                        IF v_codret != 0 THEN
                                                        --SE GENERO UN ERROR
                                                        RETURN v_codret;
                                        END IF;

                                        --Inserta el pago en la tabla de pagos
                                        INSERT INTO tblPago
                                                                (
                                                                intPkPago, chrprioridad, chrTopologia,
                                                                intfoliopago, cvecesifbcoord, cvecesifbcodest,
                                                                intPkPaqueteEnv, intcvetipopago, mnyImporte,
                                                                chrestatusenvio, dtfechavalor, dtfechacaptura,
                                                                vchrClaveRastreo, vchrCveRastreoOrig, sintLongCveRastreo,
                                                                chrSentidoPago, vchrMotivodev, intpkpagoorig
                                                                )
                                                                 VALUES
                                                                (
                                                                intPkPago1,bytprioridad, "T" ,
                                                                mlngFolioPago, lngCveCesifOrd, lngCveCesifBenef,
                                                                 intpkpaqueteenv1, 0, mcurMonto,
                                                                 "I", dtFechaOp,dtFechaOp,
                                                                mstrClaveRastreo, mstrClaveRastreo,length(mstrClaveRastreo),
                                                                "R",mstrMotivoDevolucion,lngPkPagoOriginal
                                                                );

                                        --Inserta el pago en la base de datos

                                        --Guarda el CDE, como es un arreglo de bytes debe hacerlo por medio del appendchunk
                                        --SELECT intpkpago, txtcde FROM tblPago WHERE intpkpago = "mlngPkPago"
                                        --sPago.Fields("txtcde").AppendChunk mArrCDE()


                                        --Marca el pago orginal como devuelto.
                                        UPDATE tblpago
                                                    SET chrestatusenvio = "D",
                                                            vchrmotivodev = mstrMotivoDevolucion
                                                                    WHERE
intPkPago = lngPkPagoOriginal;

                --Obtiene el total de los pagos del paquete.

                  SELECT SUM(mnyImporte) INTO mnyImportepaquete FROM tblpago WHERE intpkpaqueteenv = intpkpaqueteenv1;

                --Actualiza el monto total del paquete
                     UPDATE tblPaqueteEnv SET mnyMonto = mnyImportepaquete WHERE intpkpaqueteenv = intpkpaqueteenv1;


                RETURN v_codret;

END PROCEDURE;