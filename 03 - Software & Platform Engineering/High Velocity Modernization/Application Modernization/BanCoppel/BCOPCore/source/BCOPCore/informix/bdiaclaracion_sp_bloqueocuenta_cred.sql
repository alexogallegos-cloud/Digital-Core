CREATE PROCEDURE "informix".sp_bloqueocuenta_cred(
																pEmpresa 	CHAR(3), 
																pNumCuenta 	CHAR(20), 
																cCveBloqueo	INTEGER,
																pCveCausa 	CHAR(2), 
																pEjecutivo 	CHAR(8),
																pTipo		INTEGER
															  )
RETURNING CHAR(6) AS CODIGO,CHAR(80) AS MENSAJECOD;


--Definicion de variables

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;
		  RETURN 
			   cCodRet,
			   cMensajeRet;  
	   END IF;
    END EXCEPTION;
	
	

    CALL bdicred:"informix".sp_bloqueocuenta(pEmpresa, TRIM(pNumCuenta), cCveBloqueo,pCveCausa, pEjecutivo, 1)
    RETURNING cCodRet,cMensajeRet;

    RETURN cCodRet,cMensajeRet;

    END;     

      

    

END PROCEDURE
DOCUMENT
'Sp				:	sp_bloqueocuenta_cred',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

create procedure "informix".sp_bloqueo_cta_debito(
                                         pcuenta        CHAR(20),
                                         pmonto         MONEY(14,2),
                                         pmotivobloq    CHAR(2),
                                         pTipobloqueo   INTEGER,
                                         pusuario       CHAR(8))
returning char(5),  char(5);

--VARIABLES DE RETORNO
DEFINE codRet       CHAR (5);
DEFINE v_clave      CHAR (5);

--VARIABLES LOCALES
DEFINE empresa      CHAR(3);
DEFINE pfechabloq   DATE;
DEFINE pclave       CHAR(5);
DEFINE pAreaSolic   CHAR(2);
DEFINE pCodArea     CHAR(1);
DEFINE pTipoBloq    CHAR(2);
DEFINE pCodTipoBloq CHAR(1);

DEFINE cod_ret      CHAR(3);
DEFINE cod_ret2     CHAR(5);
DEFINE cod_ret3     CHAR(50);

--VARIABLES DE CONTROL DE ERROR
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE desc_err         CHAR(50);

--INICIALIZACIÃN DE VARIABLES
LET empresa = '001';
LET pfechabloq = TODAY;
LET pclave = '';
LET pAreaSolic= '07';
LET pCodArea='A';
LET pTipoBloq='09';
LET pCodTipoBloq = 'P';




BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/aclaraciones/bloqueo_cta_deb.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            LET cod_ret2 = isam_err;
            LET cod_ret3 = desc_err;
            return cod_ret, v_clave;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/aclaraciones/bloqueo_cta.out";
    --- TRACE ON;


     
      CALL bdicheq:"informix".bloqueo_cta(empresa,TRIM(pcuenta),pmonto , pmotivobloq, pTipobloqueo, pfechabloq, pUsuario, pclave, pAreaSolic, pCodArea,pTipoBloq, pCodTipoBloq)
      RETURNING codRet, v_clave;
    

END;


RETURN codRet, v_clave;


END PROCEDURE
DOCUMENT
'Sp				:	sp_bloqueo_cta_debito',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_concentrado_robo_identidad(folio_csuac_sp VARCHAR(30),numero_cuenta_sp VARCHAR(30),numero_cliente_sp VARCHAR(30), tipo_producto_sp CHAR(2),producto_sp integer)
    RETURNING   CHAR(6)     as s_codRet,
                char(3000) as dtosReporte1;




             --definicion de variables--
             DEFINE cod_retorno                     CHAR(5);
             DEFINE p_area                          CHAR(500);
             DEFINE p_fky_accion_e                  CHAR(5);
             DEFINE nombre_persona_reclama_p        CHAR (50);
             DEFINE fecha_nac_p                     CHAR (40);
             DEFINE genero_p                        CHAR (40);
             DEFINE curp_p                          CHAR (40);
             DEFINE direccion_p                     CHAR (40);
             DEFINE estado_p                        CHAR (40);
             DEFINE municipio_p                     CHAR (40);
             DEFINE codigo_postal_p                 CHAR (40);
             DEFINE fechacaptura_p                  CHAR (40);
             DEFINE importereclamado_p              CHAR (40);
             DEFINE numero_cuenta_p                 CHAR (40);
             DEFINE descripcion_p                   CHAR (40);
             DEFINE predictamen_p                   CHAR (300);
             DEFINE oficio_seguimiento_legal_p      CHAR (30);
             DEFINE monto_quebrantado_p             CHAR (30);
             DEFINE monto_recuperado_p              CHAR (30);
             DEFINE comentarioBitacora_p            CHAR (300);
             DEFINE comentarioBitacoraNvo_p         CHAR (300);
             DEFINE fecha_apertura_p                CHAR (20);
             DEFINE sucursal_origen_cta_p           CHAR (40);
             DEFINE lugar_apertura_p                CHAR (40);
             DEFINE nombramiento_p                                 CHAR (40);
             DEFINE puesto_quien_autorizo_p                        CHAR (40);
             DEFINE requerida_identificacion_persona_contrato_p    VARCHAR(3);
             DEFINE identificacion_validada_persona_fisica_p       CHAR (5);
             DEFINE numero_identificacion_p                        CHAR (30);
             DEFINE estatusCuenta_p                                VARCHAR(20);
             DEFINE tipo_identificacion_presentada_p               CHAR (20);
             DEFINE esCredito                                      CHAR(10);
             DEFINE tipoConsulta                                   CHAR(2);
             DEFINE iSqlErr                                        INTEGER;
             DEFINE areaNombre                                     CHAR(30);
             DEFINE seEnvio                                        CHAR(2);
             DEFINE seEnvioEmail                                   CHAR(2);
             DEFINE idMensaje                                      CHAR(30);
             DEFINE idEmail                                        CHAR(30);
             DEFINE contador integer;
             DEFINE contadorEmail integer;

             --26
            LET cod_retorno = '000*';
            let areaNombre='';
            let seEnvio='Si';
            let seEnvioEmail='Si';
            let idMensaje='ACL_SMS';
            let idEmail='ACL_SMS'; --Modificar para agregar el ID de notificacion de correo Electronico
            let contador=0;
            let contadorEmail=0;
            LET comentarioBitacoraNvo_p='';
            LET p_area='a';
            LET esCredito   = '0';
            LET p_fky_accion_e='13';
            LET nombre_persona_reclama_p='';
            LET fecha_nac_p='';
            LET tipo_identificacion_presentada_p='';
            LET genero_p='';
            LET curp_p='';
            LET direccion_p='';
            LET estado_p='';
            LET municipio_p='';
            LET codigo_postal_p='';
            LET fechacaptura_p='';
            LET importereclamado_p='';
            LET numero_cuenta_p='';
            LET descripcion_p='';
            LET predictamen_p=='';
            LET oficio_seguimiento_legal_p='';
            LET monto_quebrantado_p='';
            LET monto_recuperado_p='';
            LET comentarioBitacora_p='';
            LET fecha_apertura_p='';
            LET sucursal_origen_cta_p='';
            LET lugar_apertura_p='';
            LET nombramiento_p='';
            LET puesto_quien_autorizo_p='';
            LET requerida_identificacion_persona_contrato_p='';
            LET identificacion_validada_persona_fisica_p='';
            LET numero_identificacion_p='';
            LET estatusCuenta_p='';
            LET tipo_identificacion_presentada_p='';
            LET cod_retorno = '000*';
            LET tipoConsulta = '';

      BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*',iSqlErr||'*';
            END IF;
        END EXCEPTION;




     --TIPO CONSULTA
   --/*PRODUCTOS DE DEBITO*/
     IF(tipo_producto_sp = '2') THEN

            /*OBTENEMOS EL VALOR DE NOBRAMIENTO Y SUCURSAL*/
          select e.nombre,(s.sucursal||'-'||s.nombre)  fetch into nombramiento_p,sucursal_origen_cta_p
            from  bdinteg:si_cliente sc,bdinteg:si_ejecut e,bdinteg:si_sucursales s
             where sc.ejecut_autoriza   = e.ejecutivo
                and s.sucursal          = e.sucursal
                and sc.numcte           = numero_cliente_sp;

         IF(producto_sp ='8000' OR producto_sp='1100'  OR producto_sp='3000') THEN

            IF(producto_sp='8000') THEN
                /*OBTENEMOS EL ESTATUS DE LA CUENTA Y LA FECHA DE CONTRATACION DEL PRODUCTO*/
                LET  estatusCuenta_p  = sp_consulta_estatus_cuenta_transfer('1',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
               /*LA FECHA DE CONTRATACION DEL PRODUCTO*/
               LET  fecha_apertura_p = sp_consulta_estatus_cuenta_transfer('2',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
            END IF;
             IF(producto_sp='1100') THEN
                /*OBTENEMOS EL ESTATUS DE LA CUENTA Y LA FECHA DE CONTRATACION DEL PRODUCTO*/
                LET  estatusCuenta_p  = sp_consulta_estatus_cuenta_inv_crec('1',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
               /*LA FECHA DE CONTRATACION DEL PRODUCTO*/
               LET  fecha_apertura_p = sp_consulta_estatus_cuenta_inv_crec('2',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
            END IF;
            IF(producto_sp='3000') THEN
                /*OBTENEMOS EL ESTATUS DE LA CUENTA Y LA FECHA DE CONTRATACION DEL PRODUCTO*/
                LET  estatusCuenta_p  = sp_consulta_estatus_cuenta_pagare('1',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
               /*LA FECHA DE CONTRATACION DEL PRODUCTO*/
               LET  fecha_apertura_p = sp_consulta_estatus_cuenta_pagare('2',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
            END IF;
        END IF;

        IF(producto_sp !='8000' AND producto_sp!='1100' AND producto_sp!='3000') THEN



             select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(r.tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis

               FETCH INTO  lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,-- dtos persona que reclama
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis

                FROM       acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte

                       where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;


               /*SP ESTATUS CUENTA CAMBIA A SP_STATUS_CUENTA_DEBITOS*/
              LET estatusCuenta_p=(sp_consulta_estatus_cuenta(numero_cuenta_sp,numero_cliente_sp,tipo_producto_sp));

              /*SE TOMA LA FECHA DE APERTURA DE LA CUENTA*/
               select fecha_alta    fetch into fecha_apertura_p    from bdicheq:sc_maenoc
                     where cuenta=numero_cuenta_p;

           END IF;
            /*CUENTAS PRODUCTO TRANSFER*/
           IF(producto_sp ='8000') THEN
            select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(r.tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis


               FETCH INTO  lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis*/

                FROM      acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte

                       where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;

           END IF;
           /*INVERSION CRECIENTE*/
           IF(producto_sp='1100') THEN
               select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis

                    FETCH INTO  lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis*/

                FROM      acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte
                        where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;

           END IF;
          /*PAGARE*/
           IF(producto_sp='3000') THEN
                select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(r.tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis


              FETCH INTO   lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis


                FROM      acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte
                       where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;
           END IF;
        END IF;         /*PRODUCTOS DE CREDITO*/
        IF(tipo_producto_sp = '1') THEN

              /*OBTENEMOS EL VALOR DE NOBRAMIENTO Y SUCURSAL   MAECRED*/
          select e.nombre,(s.sucursal||'-'||s.nombre)  fetch into nombramiento_p,sucursal_origen_cta_p
            from  bdinteg:si_cliente sc,bdinteg:si_ejecut e,bdinteg:si_sucursales s
             where sc.ejecut_autoriza   = e.ejecutivo
                and s.sucursal          = e.sucursal
                and sc.numcte           = numero_cliente_sp;

             /*PARA LOS PRODUCTOS MAECRED*/
           IF(producto_sp !='6011' AND producto_sp!='6300' AND producto_sp!='6400' AND producto_sp!='6900' AND producto_sp!='7600' AND producto_sp!='7700') THEN
                select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(r.tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis


              FETCH INTO   lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis


                FROM      acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte
                       where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;



                  /*OBTENEMOS EL ESTATUS DE LA CUENTA Y LA FECHA DE CONTRATACION DEL PRODUCTO*/
                LET  estatusCuenta_p  = sp_consulta_estatus_cuenta_cred('1',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
               /*LA FECHA DE CONTRATACION DEL PRODUCTO*/
               LET  fecha_apertura_p = sp_consulta_estatus_cuenta_cred('2',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
           END IF;
           IF(producto_sp ='6011' OR producto_sp='6300' OR producto_sp='6400' OR producto_sp='6900' OR producto_sp='7600' OR producto_sp='7700') THEN
               select
                    nvl(r.lugar_apertura,'-'),nvl(r.puesto_quien_autorizo,'-'),--dtos contr prod
                    nvl(r.requerida_identificacion_persona_contrato,'-'),nvl(r.identificacion_validada_persona_fisica,'-'),nvl(r.tipo_identificacion_presentada,'-'),nvl(r.numero_identificacion,'-'),--dtos contr prod
                    nvl(r.nombre_persona_reclama,'-'),nvl(r.fecha_nac,'-'),nvl(r.genero,'-'),nvl(r.curp,'-'),nvl(r.direccion,'-'),nvl(r.estado,'-'),nvl(r.municipio,'-'),nvl(r.codigo_postal,'-'),--dtos persona que reclama
                    nvl(a.fechacaptura,'-'),nvl(a.importereclamado,'0'),nvl(p.numero_cuenta,'-'),nvl(p.descripcion,'-'),--dtos folio
                    nvl(a.predictamen,'-'),nvl(r.oficio_seguimiento_legal,'-'),nvl(r.monto_quebrantado,'0'),nvl(r.monto_recuperado,'0')--dtos analisis


              FETCH INTO   lugar_apertura_p,puesto_quien_autorizo_p,
                           requerida_identificacion_persona_contrato_p,identificacion_validada_persona_fisica_p,tipo_identificacion_presentada_p,numero_identificacion_p,--contr prod
                           nombre_persona_reclama_p,fecha_nac_p,genero_p,curp_p,direccion_p,estado_p,municipio_p,codigo_postal_p,
                           fechacaptura_p,importereclamado_p,numero_cuenta_p,descripcion_p,--dtos folio
                           predictamen_p,oficio_seguimiento_legal_p,monto_quebrantado_p,monto_recuperado_p--dtos analisis


                FROM      acl_concentrado_robo_identidad r,acl_aclaracion a, acl_producto p,bdinteg:si_cliente as cte
                       where  a.fky_concentrado_robo=r.pky_concentrado_robo
                        and    a.fky_producto       = p.pky_producto
                        and    a.num_cliente        = cte.numcte
                        and    a.folio_csuac        = folio_csuac_sp
                        and    a.num_cliente        = numero_cliente_sp;

                   /*OBTENEMOS EL ESTATUS DE LA CUENTA Y LA FECHA DE CONTRATACION DEL PRODUCTO*/
                   LET  estatusCuenta_p  = sp_consulta_estatus_cuenta_cred_otros('1',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
                   /*LA FECHA DE CONTRATACION DEL PRODUCTO*/
                   LET  fecha_apertura_p = sp_consulta_estatus_cuenta_cred_otros('2',numero_cuenta_sp,TO_NUMBER(numero_cliente_sp));
                         END IF;
         END IF;
           /*SE OBTIENE EL COMENTARIO DE BITACORA CON LA ACCION 13 (RESPUESTO DEL AREA)*/
          FOREACH
                select trim(descripcion)  fetch into comentarioBitacoraNvo_p from acl_entrada_bitacora
                   where folio_csuac=folio_csuac_sp  and  fky_accion=p_fky_accion_e
                let comentarioBitacora_p=trim(comentarioBitacora_p)||'--'||trim(nvl(comentarioBitacoraNvo_p,''));

         END FOREACH

         /*SE VERIICA SI SE ENVIO MSJ DE CONFIRMACION */
        select COUNT(*) fetch into contador from bdimnsj:mnsjr_trx_online  where cliente=numero_cliente_sp  and  id_mensaje like idMensaje and transaction_id is not  null;

         /*SE VERIICA SI SE ENVIO Email DE CONFIRMACION */
        select COUNT(*) fetch into contadorEmail from bdimnsj:mnsjr_trx_online  where cliente=numero_cliente_sp  and  id_mensaje like idEmail and transaction_id is not  null;


         IF contador=0 THEN
                let seEnvio='No';
                select COUNT(*) fetch into contador
                    from bdimnsj:mnsjr_trx_online_his
                 where cliente=numero_cliente_sp  and  id_mensaje like idMensaje and transaction_id is not  null;
           IF contador=1 THEN
               let seEnvio='Si';
           END IF;
         END IF;

        IF contadorEmail=0 THEN
                let seEnvioEmail='No';
                select COUNT(*) fetch into contadorEmail
                    from bdimnsj:mnsjr_trx_online_his
                 where cliente=numero_cliente_sp  and  id_mensaje like idEmail and transaction_id is not  null;
           IF contadorEmail=1 THEN
               let seEnvioEmail='Si';
           END IF;
         END IF;


           RETURN cod_retorno,trim(fecha_apertura_p)||'*'||trim(sucursal_origen_cta_p)||'*'||trim(lugar_apertura_p)||'*'||trim(nombramiento_p)||'*'||trim(puesto_quien_autorizo_p)||'*'||trim(comentarioBitacora_p)||'*'
                  ||trim(requerida_identificacion_persona_contrato_p)||'*'||trim(identificacion_validada_persona_fisica_p)||'*'||trim(tipo_identificacion_presentada_p)||'*'||trim(numero_identificacion_p)||'*'||trim(estatusCuenta_p)||'*'||seEnvio
                  ||'*'||trim(nombre_persona_reclama_p)||'*'||trim(fecha_nac_p)||'*'||trim(genero_p)||'*'||trim(curp_p)||'*'||trim(direccion_p)||'*'||trim(estado_p)||'*'||trim(municipio_p)||'*'||trim(codigo_postal_p)||--dtos persona que reclama
                  '*'||trim(fechacaptura_p)||'*'||trim(importereclamado_p)||'*'||trim(numero_cuenta_p)||'*'||trim(descripcion_p)||--dtos folio
                  '*'||trim(predictamen_p)||'*'||trim(oficio_seguimiento_legal_p)||'*'||trim(importereclamado_p)||'*'||trim(monto_quebrantado_p)||'*'||trim(monto_recuperado_p)||'*'||seEnvioEmail;


    END  
END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_concentrado_robo_identidad',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_transfer(p_tipo CHAR(20),p_cuenta CHAR(20),p_cliente integer)

    RETURNING   char(50) AS estatus_cta;
    
    DEFINE iSqlErr      	  INTEGER;

    DEFINE cod_retorno  CHAR(5);
    DEFINE estatus_cuenta           CHAR(50);
    DEFINE secuencia_p              CHAR(50);
    DEFINE fecha_alta_p             CHAR(50);
    DEFINE estCta                   CHAR(50);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta   CHAR(1);
    DEFINE valor_retorno            CHAR(20);
   

    LET estatus_cuenta           = '';
    LET secuencia_p              = '';
    LET fecha_alta_p             = '';
    LET estCta                   = '';
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
    LET cod_retorno              = '000*';
    LET iSqlErr                  = '';

	BEGIN
        
       
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
  --      TRACE ON;
       /*SI EL TIPO DE CONSULTA ES 1 RETORNA EL ESTATUS DE BLOQUEO PARA TIPO DE CUENTA INV CRECIENTE*/      
       IF '1' = consulta_est_cta THEN        
         select  mst.descripcion FETCH INTO estatus_cuenta
            from bditransfer:tf_maecte ma
              INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
           where ma.cuenta_tf  = p_cuenta 
           and   ma.numcte     = p_cliente;
         LET valor_retorno=estatus_cuenta;
       END IF;
 
       /*SI EL TIPO DE CONSULTA ES DOS RETORNA LA FECHA DE APERTURA PARA TIPO DE CUENTA PAGARE*/
      IF p_tipo = consulta_est_fech_alta THEN 
          select  ma.fec_alta   fetch into fecha_alta_p
           from bditransfer:tf_maecte ma
            INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
           where ma.cuenta_tf  = p_cuenta 
           and   ma.numcte     = p_cliente;            
          LET valor_retorno=fecha_alta_p;
       END IF;    
 
    RETURN valor_retorno;

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_transfer',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_inv_crec(p_tipo CHAR(20),p_cuenta CHAR(20),p_cliente integer)

    RETURNING  char(50) AS estatus_cta;
    
    DEFINE iSqlErr      	        INTEGER;
    DEFINE cod_retorno              CHAR(5);
    DEFINE estatus_cuenta           CHAR(50);
    DEFINE secuencia_p              CHAR(50);
    DEFINE fecha_alta_p             CHAR(50);
    DEFINE estCta                   CHAR(50);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta   CHAR(1);
    DEFINE valor_retorno            CHAR(20);
   
    LET cod_retorno              = '000*';
    LET iSqlErr      	         = '';
    LET estatus_cuenta           = '';
    LET secuencia_p              = '';
    LET fecha_alta_p             = '';
    LET estCta                   = '';
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
   
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
  --      TRACE ON;
       /*SI EL TIPO DE CONSULTA ES 1 RETORNA EL ESTATUS DE BLOQUEO PARA TIPO DE CUENTA INV CRECIENTE*/      
       IF p_tipo = consulta_est_cta THEN 
         select  mst.descripcion  FETCH INTO estatus_cuenta
           from bdicheq:sc_maechq ma
            INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
           where ma.cuenta  = p_cuenta 
           and   ma.num_cte = p_cliente;

         LET valor_retorno=estatus_cuenta;
       END IF;
 
       /*SI EL TIPO DE CONSULTA ES DOS RETORNA LA FECHA DE APERTURA PARA TIPO DE CUENTA PAGARE*/
      IF p_tipo = consulta_est_fech_alta THEN 
          select  ma.fecultdep   fetch into fecha_alta_p
             from bdicheq:sc_maechq ma
               INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
             where ma.cuenta=p_cuenta 
            and   ma.num_cte=p_cliente;
          LET valor_retorno=fecha_alta_p;
       END IF;    
 
    RETURN valor_retorno;

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_inv_crec',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_pagare(p_tipo CHAR(20),p_cuenta CHAR(20),p_cliente integer)

    RETURNING     CHAR(50) AS estatus_cta;
    
    DEFINE iSqlErr      	       INTEGER;

    DEFINE cod_retorno              CHAR(5);
    DEFINE estatus_cuenta           CHAR(50);
    DEFINE secuencia_p              CHAR(50);
    DEFINE fecha_alta_p             CHAR(50);
    DEFINE estCta                   CHAR(50);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta   CHAR(1);
    DEFINE valor_retorno            CHAR(20);
   
    LET cod_retorno              = '000*';
    LET estatus_cuenta           = '';
    LET secuencia_p              = '';
    LET fecha_alta_p             = '';
    LET estCta                   = '';
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
   
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;
  --      SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
  --      TRACE ON;
       /*SI EL TIPO DE CONSULTA ES 1 RETORNA EL ESTATUS DE BLOQUEO PARA TIPO DE CUENTA PAGARE*/
       IF p_tipo = consulta_est_cta THEN 
           select  mst.descripcion  fetch into estatus_cuenta
         from bdinvers:sv_maeinv ma
           INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
        where ma.cuenta=p_cuenta 
        and   ma.num_cte=p_cliente    
        and   ma.secuencia = ( select max(ma.secuencia)
                                          from bdinvers:sv_maeinv ma  
                                              where ma.cuenta=p_cuenta and   ma.num_cte=p_cliente);
         LET valor_retorno=estatus_cuenta;
       END IF;
 
       /*SI EL TIPO DE CONSULTA ES DOS RETORNA LA FECHA DE APERTURA PARA TIPO DE CUENTA PAGARE*/
      IF p_tipo = consulta_est_fech_alta THEN 
           select  ma.fecha_alta  fetch into fecha_alta_p
         from bdinvers:sv_maeinv ma
           INNER JOIN bdicheq:sc_mae_estatus mst  on mst.cod_estatus=ma.status_cta
        where ma.cuenta=p_cuenta 
        and   ma.num_cte=p_cliente    
        and   ma.secuencia = ( select max(ma.secuencia)
                                          from bdinvers:sv_maeinv ma  
                                              where ma.cuenta=p_cuenta and   ma.num_cte=p_cliente);

          LET valor_retorno=fecha_alta_p;
       END IF;    
 
    RETURN valor_retorno;

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_pagare',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_cred_otros(p_tipo CHAR(1),p_cuenta char(30),p_cliente integer)

    RETURNING char(50) AS valor_retorno_s;
    
    DEFINE iSqlErr      	        INTEGER;
    DEFINE cod_retorno              CHAR(5);
    DEFINE p_estatus_cuenta          CHAR(30);
    DEFINE fecha_alta_p             CHAR(30);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta    CHAR(30);
    DEFINE valor_retorno            CHAR(30);
   
    LET iSqlErr      	         = '';
    LET cod_retorno              = '000*';
    LET p_estatus_cuenta           = '';
    LET fecha_alta_p             = '';  
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
   
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
  --      TRACE ON;
         /*CUENTA ACTIVA (ESTATUS) PARA CUENTAS DE CREDITO */
          IF p_tipo=consulta_est_cta THEN 
            SELECT tc.descripcion FETCH INTO p_estatus_cuenta
               FROM bdicred:sd_maecredcrd mcrd
                 INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
               WHERE mcrd.numcte = p_cliente
                 AND num_credito = p_cuenta;

              LET  valor_retorno = p_estatus_cuenta;
          END IF;
          /*CUENTA ACTIVA(FECHA APERTURA) PARA CUENTAS DE CREDITO */
          IF p_tipo=consulta_est_fech_alta THEN 

            SELECT TO_CHAR(mcrd.fecha_apertura) FETCH INTO consulta_est_fech_alta  --mcrd.fecha_apertura
               FROM bdicred:sd_maecredcrd mcrd
                 INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
               WHERE mcrd.numcte = p_cliente
                 AND num_credito = p_cuenta;


           LET  valor_retorno = consulta_est_fech_alta;
          END IF;
        
 
    RETURN trim(valor_retorno);

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_cred_otros',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_monitor_alerta_aclaraciones()
RETURNING
	CHAR(5) AS codret, CHAR(100) AS descrip;

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE cMensaje CHAR(100);
	DEFINE cRutaArch CHAR(25);
	DEFINE vsSQL  CHAR(1600);
	DEFINE vsSQL1 CHAR(500);
	DEFINE vsSQL2 CHAR(500);
	DEFINE vsSQL3 CHAR(500);
	DEFINE vsArchTemp CHAR(50);
	DEFINE nContador INTEGER;
	DEFINE vFechaAclaracion CHAR(10);

	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(29);
	DEFINE iPaso				SMALLINT;

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_tmpmonitoracla';
	LET vFechaAclaracion    = LPAD(DAY(CURRENT::DATE),2,'0')||'/'||LPAD(MONTH(CURRENT::DATE),2,'0')||'/'||YEAR(CURRENT::DATE);
	LET iPaso				= 0;
	
	LET cRutaArch = '';
	LET cMensaje = 'ERROR EN PASO: ';
	
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET vsArchTemp = '';
	LET v_cod_ret = '00000';
	LET nContador = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
			
				LET v_cod_ret = iSqlErr;
			END IF;
			
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			
			RETURN v_cod_ret, cMensaje;
		END EXCEPTION;

    --CAMBIAR EN PRODUCCION POR UNA RUTA QUE TENGA TODOS LOS PERMISOS
	LET cRutaArch = '/home/procesos/';

	LET iPaso = 1;
	
	LET vsArchTemp = cFechaArchivoOUT||'.txt';
	
	--ACLARACIONES CON ESTATUS DE INTENTO Y BONIFICACION TEMPORAL

	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || TRIM (vsArchTemp)|| ' DELIMITER ' || ''' ''';
	
	LET vsSQL2 = " SELECT DISTINCT acl.folio_csuac "
	|| " FROM bdiaclaracion:acl_movimiento mov INNER JOIN bdiaclaracion:acl_aclaracion acl "
	|| " ON acl.folio_csuac = mov.folio_csuac "
	|| " WHERE acl.fky_estatus_aclaracion = '1' and mov.exitoso = '1' and acl.fechacaptura = TODAY "
	|| " ORDER BY acl.folio_csuac ";

	LET vsSQL3 = ' " > '|| TRIM(cRutaArch) || cFechaArchivoOUT||'.sql';
	LET vsSQL = TRIM( vsSQL1 ) || ' ' || TRIM( vsSQL2 ) || ' ' || TRIM( vsSQL3 );
	SYSTEM vsSQL;
	
	LET iPaso = 2;
	
	--RUTA PRODUCTIVA
	LET vsSQL = '/ifxsif01/bin/dbaccess bdiaclaracion ' || TRIM(cRutaArch) || cFechaArchivoOUT||'.sql > '||TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--RUTA PRUEBAS
	--LET vsSQL = '/informix/bin/dbaccess bdiaclaracion ' || TRIM(cRutaArch) || cFechaArchivoOUT||'.sql > '||TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	SYSTEM vsSQL;
	
	LET iPaso = 3;
	
	SELECT COUNT(*)
	INTO nContador
	FROM bdiaclaracion:acl_movimiento mov INNER JOIN bdiaclaracion:acl_aclaracion acl
	ON acl.folio_csuac = mov.folio_csuac
	WHERE acl.fky_estatus_aclaracion = '1' and mov.exitoso = '1' and acl.fechacaptura = TODAY;
	
	LET iPaso = 4;
	
	IF( nContador == 0 ) THEN
		LET vsSQL = 'echo "No existen movimiento pendientes." >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	ELSE
		LET vsSQL = 'echo "Los siguientes Folios CSUAC no concluyeron su ingreso, quedando con estatus intento, pero generaron un abono temporal:" >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	END IF;	
	
	SYSTEM vsSQL;
	
	LET iPaso = 5;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;
	
	LET iPaso = 6;	
	
	LET vsSQL = 'cat ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.txt >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;	

	LET iPaso = 7;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.sql';
	SYSTEM vsSQL;
	
	LET iPaso = 8;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.out';
	SYSTEM vsSQL;
	
	LET iPaso = 9;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.txt';
	SYSTEM vsSQL;

	LET iPaso = 10;
	
	LET vsSQL = 'mailx -s"MONITOR DE ACLARACIONES ' || vFechaAclaracion || '" "ncorona@bancoppel.com -c oortega@bancoppel.com; vjmendoza@bancoppel.com; rzavalag@bancoppel.com; plopezl@bancoppel.com; molverar@bancoppel.com; jgonzalez@bancoppel.com;" < ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;
	
	LET iPaso = 11;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.sql';
	SYSTEM vsSQL;
	
	LET iPaso = 12;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.out';
	SYSTEM vsSQL;	
	
	LET iPaso = 13;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.txt';
	SYSTEM vsSQL;	
	
	LET iPaso = 14;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;	
		
	RETURN v_cod_ret, 'PROCESO TERMINADO';

END;
--##############################################################################
--## Procedimiento   : 
--## Version         : 1.0
--## Creado por      : 
--## Fecha creacion  : 
--##Descripcion :  
--##############################################################################
END PROCEDURE;