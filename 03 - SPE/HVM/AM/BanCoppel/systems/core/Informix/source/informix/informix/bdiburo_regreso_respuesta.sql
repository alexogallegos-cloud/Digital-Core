CREATE PROCEDURE "informix".regreso_respuesta(pempresa CHAR(3),psucursal CHAR(4), pusuario CHAR(8), pInstitucion CHAR(2),pNumSolicitud VARCHAR(25))


        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE  iNore INTEGER;
        DEFINE cSucursalMotor CHAR(4);
        DEFINE cSucursalSol CHAR(4);
        DEFINE cNumProducto CHAR(4);


        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNore = 0;
        LET cSucursalMotor = '';
        LET cSucursalSol = '';
        LET cNumProducto = '';


        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                END EXCEPTION;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                --SET DEBUG FILE TO '/home/c90077639/SP_bdiburo_sucursales/nuema_modif/regreso_respuesta.out';
                --TRACE ON;

                IF pInstitucion = '' OR pNumSolicitud = '' THEN
                        LET cCodRet = '00002';
                END IF;

                UPDATE bdiburo:'informix'.br_respuesta_aprocesar SET status = 'PR' WHERE institucion = pInstitucion AND num_solicitud = pNumSolicitud;

                /*Se agregan filtros para traer informacion completa*/
				SELECT NVL(sucursal,''), NVL(num_producto,'')
                INTO cSucursalSol, cNumProducto
                FROM bdisolic:"informix".ss_solicitudes
                WHERE num_solicitud = pNumSolicitud;
                
				--SE COMENTA VALIDACIONES PARA MANDAR LLAMAR EL SP HOMOLOGADO ins_consulta_buro2_motor MACM
				
                /*IF EXISTS (SELECT numsucursal FROM bdicred:"informix".sd_sucursales_motor_pp where numsucursal = cSucursalSol AND cSucursalSol NOT IN ('8511', '8512')) --THEN
                AND EXISTS (SELECT numproducto  FROM bdicred:"informix".sd_productos_motor_pp where numproducto = cNumProducto) THEN         
                      EXECUTE PROCEDURE "informix".ins_consulta_buro2_motor_pp(pempresa,cSucursalSol,pusuario,pInstitucion,pNumSolicitud);
                        LET iNore = iNore +1;
				ELIF cSucursalSol NOT IN ('8511', '8512') 
				AND EXISTS (SELECT numproducto  FROM bdicred:"informix".sd_productos_motor where numproducto = cNumProducto) THEN
				
                        EXECUTE PROCEDURE "informix".ins_consulta_buro2_motor(pempresa,cSucursalSol,pusuario,pInstitucion,pNumSolicitud);
                        LET iNore = iNore +1;
                ELSE
                        EXECUTE PROCEDURE "informix".ins_consulta_buro2(pempresa,cSucursalSol,pusuario,pInstitucion,pNumSolicitud);
                        LET iNore = iNore +1;
                END IF;*/
				
				EXECUTE PROCEDURE "informix".ins_consulta_buro2_motor(pempresa,cSucursalSol,pusuario,pInstitucion,pNumSolicitud);
				LET iNore = iNore +1;

                IF (iNore = 0) then
                        UPDATE bdiburo:'informix'.br_respuesta_aprocesar SET status = 'ERRR' WHERE institucion = pInstitucion AND num_solicitud = pNumSolicitud;
                ELSE
                        UPDATE bdiburo:'informix'.br_respuesta_aprocesar SET status = 'OK' WHERE institucion = pInstitucion AND num_solicitud = pNumSolicitud;
                END IF;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez',
'FECHA: 21/04/2016',
'MODULO: DEMONIO',
'FUNCIONALIDAD: PROCESO REGRESO',
'DESCRIPCION:Es ejecutado por el trigger alata_br_respuesta',
'BD: bdiburo',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Vera Mariscal Sanchez',
'Modifica: Se crear bifurcacion para insercion de datos en tabla ss_envio_solicitudes para Motor de Evaluacion',
'Fecha: 08-07-2022',
'Peticion: Motor de Evaluacion',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Andres Godinez Hernandez',
'Modifica: Utilizar tabla sd_sucursales_motor_pp en validacion para la ejecucion del procedimiento ins_consulta_buro2_motor_pp',
'Fecha:',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Ana Elisa Ramos',
'Modifica: Se corrige flujo para motor de evaluacion',
'Fecha: 04/06/2024',
'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Autor:  Marco Antonio Cardenas Medina',
'Modifica: Se Homologa las versiones ins_consulta_buro2, ins_consulta_buro2_motor e ins_consulta_buro2_motor_pp',
'Fecha: 07/03/2025';