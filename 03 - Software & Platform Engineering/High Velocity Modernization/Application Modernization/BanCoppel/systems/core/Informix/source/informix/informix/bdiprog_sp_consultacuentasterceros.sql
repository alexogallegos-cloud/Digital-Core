CREATE PROCEDURE "informix".sp_consultacuentasterceros(pNumCte CHAR(20), pTipoCta CHAR(2), pTipoNaturaleza CHAR(2) )
RETURNING CHAR(5) as retorno,CHAR(60) as mensaje,CHAR(3) as cve_banco,CHAR(20) as num_cta,CHAR(2) as tipo_cta,CHAR(20) as descripcion,CHAR(60) as nombre,CHAR(13) as rfc,CHAR(40) as correo,CHAR(2) as cve_company,CHAR(10) as Num_Celular;
       --codigo,mensaje,cve_banco,num_cta,tipo_cta,descripcion,nombre,   rfc  ,e-mail,cve_comany,No.Celular.

                                --*************************************************
                                --Creado por: Anselmo Verdugo                   --*
                                -- Actividad: Se obtiene cuentas asociadas al un cliente.
                                --  Solicitó: Aymme Osuna                       --*
                                --     Fecha: 27/OCT/2008         
								--* Modifico:Alejandro Osuna
								-- Fecha: Diciembre 2008
								-- Se valida dato por dato los parametros de entrada
                                --*************************************************

DEFINE vcCodRet CHAR(6);
DEFINE sql_err  INTEGER;
DEFINE vcMensaje CHAR(60);
DEFINE vcCveBanco CHAR(3);
DEFINE vcNumCta CHAR(20);
DEFINE vcTipoCta    CHAR(2);
DEFINE vcDescripcion CHAR(20);
DEFINE vcNombre     CHAR(60);
DEFINE vcRfc        CHAR(13);
DEFINE vcEmail      CHAR(40);
DEFINE vcCveCompania CHAR(2);
DEFINE vcNumCelular CHAR(10);
DEFINE vcTodas  CHAR(1);
DEFINE vcTodaNatural  CHAR(1);
DEFINE vcHayCuentas  CHAR(1);




        --MANEJADOR DE EXEPCIONES
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;

            RETURN vcCodRet,'','','','','','','','','','';
        END EXCEPTION;


    --SET DEBUG FILE TO "/home/informix/sp_consultaCuentasPropiasTerceros.out";
	--TRACE ON;


LET vcCodRet = '00000';
LET sql_err  = 0;
LET vcMensaje = '';
LET vcCveBanco = '';
LET vcNumCta = '';
LET vcTipoCta    = '';
LET vcDescripcion = '';
LET vcNombre     = '';
LET vcRfc        = '';
LET vcEmail      = '';
LET vcCveCompania = '';
LET vcNumCelular = '';
LET vcTodas      = 'N';
LET vcTodaNatural = 'N';
LET vcHayCuentas = 'N';


    -- Se validan las variables que se reciben como los parametros.
   -- IF NVL(pNumCte,'') <> '' and NVL(pTipoCta,'') <> '' and NVL(pTipoNaturaleza,'') <> '' THEN

    IF NVL(pNumCte,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '104';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';
	END IF;

	IF NVL(pTipoCta,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '11';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';
	END IF;


	IF NVL(pTipoNaturaleza,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '12';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';

	END IF;

        -- Se valida la existencia del cliente.
        IF EXISTS ( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte )  THEN

            -- Se valida la existencia del tipo de cuenta asociada.
            IF EXISTS ( SELECT descripcion FROM bdiprog:pp_tpcuentasasoc WHERE tipo_asoc = pTipoCta ) THEN

				IF  pTipoNaturaleza = '01' or pTipoNaturaleza = '03' or pTipoNaturaleza = '04' THEN


                        -- Se recupera todos los tipos de cuentas ( PROPIAS Y TERCEROS).
                        IF pTipoCta = '04' THEN
                            LET vcTodas  = 'S';
                        END IF;

                        -- Se recupera las cuentas PROPIAS o TODAS.
                        IF pTipoCta = '01' or vcTodas = 'S' THEN

                            -- Cuentas de todas naturaleza.
                            IF pTipoNaturaleza = '03' THEN
                                LET vcTodaNatural = 'S';
                            END IF;

                            -- Cuentas de CAPTACION.
                            IF pTipoNaturaleza = '01' or vcTodaNatural = 'S' THEN
                                FOREACH
                                    SELECT distinct cuenta INTO vcNumCta FROM bdicheq:sc_maechq maechq
                                    inner join bdiprog:pp_producperm producperm ON producperm.producto = maechq.producto
--                                    WHERE maechq.num_cte = pNumCte and maechq.status_cta = '1' and producperm.permite_prog = 'S'
									WHERE maechq.num_cte = pNumCte and maechq.status_cta <> '2' and producperm.permite_prog = 'S'

                                    LET vcHayCuentas = 'S';

                                    SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    LET vcTipoCta = '01';

                                    SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                   RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,'',vcNombre,vcRfc,'','','' WITH RESUME;
                                    --codigo,mensaje,cve_banco,num_cta,tipo_cta,descripcion,nombre,   rfc  ,e-mail,cve_comany,No.Celular.
                                END FOREACH;
                            END IF;
                            -- Cuentas de CREDITO.
                            IF pTipoNaturaleza = '04' or vcTodaNatural = 'S' THEN
                                FOREACH
                                    SELECT distinct tarjeta.num_tarjeta INTO vcNumCta FROM bdicred:sd_maecred maecred
                                    inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
									INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
                                    WHERE maecred.numcte = pNumCte and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
									AND tarjeta.status_tar = 'A'
									
									--SELECT num_tarjeta INTO vcNumCta FROM  bdicred:sd_tarjeta WHERE  num_credito = vcNumCta ;

                                    LET vcHayCuentas = 'S';

                                    SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    LET vcTipoCta = '04';

                                    SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                    RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,'',vcNombre,vcRfc,'','','' WITH RESUME;

                                END FOREACH;
                            END IF;

                        END IF;


                        -- Se recupera las cuentas de TERCEROS
                        IF (pTipoCta = '02') or vcTodas = 'S' THEN

                            -- -- Se recupera las cuentas de TODAS LAS CUENTAS DE TERCEROS CON CUENTA DIFERENCTE '05'.
                            IF pTipoNaturaleza = '03' THEN
                                --LET vcTodaNatural = 'S';
								FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta <> '05'

									IF vcCveBanco = '137' THEN
										IF (vcTipoCta = '01')  THEN
--										IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta = '1' ) THEN
										IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta <> '2' ) THEN
												LET vcHayCuentas = 'S';
												RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
											ELSE
												continue FOREACH;
											END IF;
										END IF;
										IF (vcTipoCta = '04') THEN
											IF EXISTS( SELECT distinct tarjeta.num_tarjeta FROM bdicred:sd_maecred maecred
													inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
													INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
													WHERE tarjeta.num_tarjeta = vcNumCta and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
													AND tarjeta.status_tar = 'A') THEN
												LET vcHayCuentas = 'S';
												RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
											ELSE
												continue FOREACH;
											END IF;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;
								
								END FOREACH;
                            END IF;

                            -- Cuentas de CAPTACION para TERCEROS.
                            IF pTipoNaturaleza = '01' THEN
                                FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado  = '01'  and cve_cuenta in('01','02','03')
									
									IF (vcCveBanco = '137')  and (vcTipoCta = '01') THEN 
--									IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta = '1' ) THEN
									IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta <> '2' ) THEN
											LET vcHayCuentas = 'S';
											RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
										ELSE
											continue FOREACH;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;									
                                END FOREACH;
                            END IF;

                            -- Cuentas de CREDITO para Terceros.
                            IF pTipoNaturaleza = '04' THEN
                                FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta = '04'
									
									IF vcCveBanco = '137' THEN
										IF EXISTS( SELECT distinct tarjeta.num_tarjeta FROM bdicred:sd_maecred maecred
													inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
													INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
													WHERE tarjeta.num_tarjeta = vcNumCta and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
													AND tarjeta.status_tar = 'A') THEN
											LET vcHayCuentas = 'S';
											RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
										ELSE
											continue FOREACH;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;
                                END FOREACH;

                            END IF;


                        END IF;

						-- SE VAN A RECUPERAR LAS CUENTAS DE SERVICIOS.
						IF ( pTipoCta = '03') or vcTodas = 'S' THEN

							IF pTipoNaturaleza = '03' THEN
							    FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco   FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta = '05'

                                    LET vcHayCuentas = 'S';

                                    --SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    --LET vcTipoCta = pTipoNaturaleza;

                                    --SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                    RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;

                                END FOREACH;

							END IF;

						END IF;
                        IF  vcHayCuentas = 'N' THEN
                            -- Se regresa informacion sobre que no hubo cuenta para el cliente.
                            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '13';
                            RETURN vcCodRet,vcMensaje,'','','','','','','','','';
                        END IF;

				ELSE
					-- Se regresa que el numero de cliente no existe.
		            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '12';
		            RETURN vcCodRet,vcMensaje,'','','','','','','','','';
				END IF;

            ELSE
                -- Se regresa la NO existencia del tipo de cuenta asociada.
                SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '11';
                RETURN vcCodRet,vcMensaje,'','','','','','','','','';

            END IF;

        ELSE
            -- Se regresa que el numero de cliente no existe.
            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '04';
            RETURN vcCodRet,vcMensaje,'','','','','','','','','';

        END IF;
   /* ELSE
        --REGREGAR PARAMETROS RECIBIDOS NO DEBER ESTAR EN NULO O ESPACIO EN BLANCO.
        SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '01';
        RETURN vcCodRet,vcMensaje,'','','','','','','','','';
    END IF;*/

        --SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '13';
        --RETURN vcCodRet,vcMensaje,'','','','','','','','','';


END PROCEDURE;