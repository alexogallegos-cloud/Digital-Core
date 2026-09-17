CREATE PROCEDURE "informix".sp_consultarprogramaciongeneral_bpi(p_empresa Char(3),p_snum_cte Char(20),p_sestado Char(2), pDesde INTEGER, pHasta INTEGER)
      RETURNING   CHAR(5),    --Código Retorno
                        CHAR(250),  --Mensaje Retorno
                        CHAR(10),   --Clave de Pago de Programación
                        CHAR(2),    --Clave de Estado
                        CHAR(20),   --Concepto de Pago
                        DATE,       --Fecha Programación
                        CHAR(30),   --Frecuencia
                        MONEY(16,2),--Monto
                        DATE,       --Fecha Inicio
                        CHAR(40),   --Canal Programación
                        CHAR(20),   --Cuenta Destino
                        CHAR(60),   --Beneficiario
                        CHAR(40),   --Banco
                        CHAR(20),   --Cuenta Origen
                        CHAR(70),   --Tipo Operación
                        CHAR(40),   --Tipo Cuenta Origen
                        CHAR(30),   --Notifica Cliente
                        CHAR(30),   --Notifica Receptor
                        CHAR(2),    --clave de tipo de operación
                        CHAR(40),   --Referencia1
                        CHAR(20),   --Referencia2
                        CHAR(5),    --Convenio
                        CHAR(1);    --tipo pago: 1-fijo,2-minimo, 3-porcentaje
                        
      ---**********************************************************
      -- Realizo   :Alejandro Osuna    
      --Solicito : Aymme Osuna
      -- Proyecto :  Pagos Programados
      -- Actividad : Tener un procedimiento que permitirá consultar las transacciones programadas
    --                    para un cliente determinado
      -- Fecha     :18 de  Novimebre  de 2008
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se clona SP para modificar los parámetros de salida e implementar paginación.
      -- Fecha:         2011/05/16
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se cambia la tabla de donde se toma la descripcion del canal y se agregan 3 parametros de salida mas (ref1,ref2 y convenio).
      -- Fecha:         2011/05/16
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se le agrega el orden DESC a las consultas para que aparezcan las últimas mas nuevas en la interfaz.
      -- Fecha:         2011/10/11
	  --********************************************************
	  -- Bibiana Gaxiola Verdugo
	  -- Se modificó la forma en que se extrae el nombre del beneficiario para Pago TDC BanCoppel Propia y Pago TDC terceros mismo banco
	  -- Fecha: 22/11/2013
	  --*********************************************************
      --Definicion de Variables  
      DEFINE v_sCodRet CHAR(5);
      DEFINE v_sMensajeRet CHAR(250);
            
      DEFINE sCve_PagoProg         CHAR(10);
      DEFINE aCve_Estado                 CHAR(2);
      DEFINE sConcepto_Pago        CHAR(20);
      DEFINE sFecha_Programacion   DATE;
      DEFINE sFrecuencia                 CHAR(30);
      DEFINE sMonto                      MONEY(16,2);
      DEFINE sFecha_Inicio         DATE;
      DEFINE sCanal_Programacion   CHAR(40);
      DEFINE sCuenta_Destino       CHAR(20);
      DEFINE sBeneficiario         CHAR(60);
      DEFINE sBanco_Descrip        CHAR(40);
      DEFINE sCuenta_Origen        CHAR(20);
      DEFINE sTipo_Operacion       CHAR(70);
      DEFINE sCve_Notifica_Emi     CHAR(2);
      DEFINE sCve_Notifica         CHAR(2);
      DEFINE sTipo_Cta_Origen      CHAR(40);
      DEFINE sNotifica_Cte         CHAR(30);
      DEFINE sNotifica_Recep       CHAR(30);
      DEFINE sCveOperacion         CHAR(2);
    DEFINE sFecha_Cancelacion DATE;
    DEFINE v_dfecha                DATE;
    DEFINE iContador               INT;
      DEFINE sReferencia1                CHAR(40);
      DEFINE sReferencia2                CHAR(20);
      DEFINE sConvenio             CHAR(5);
      DEFINE sTipo_Pago            CHAR(1);
      DEFINE iNo_Repet             INT;
      DEFINE sFecha_Fin            DATE;
	  DEFINE vNumcte CHAR(9);
                  
      --Inicializacion de Variables
      LET v_sCodRet = '';
      LET v_sMensajeRet = '';
      LET sCve_PagoProg = '';
      LET aCve_Estado = '';
      LET sConcepto_Pago = '';
      LET sFecha_Programacion = '';
      LET sFrecuencia = '';
      LET sMonto = 0;
      LET sFecha_Inicio = '';
      LET sCanal_Programacion = '';
      LET sCuenta_Destino = '';
      LET sBeneficiario = '';
      LET sBanco_Descrip = '';
      LET sCuenta_Origen = '';
      LET sTipo_Operacion = '';
      LET sCve_Notifica_Emi = '';
      LET sCve_Notifica = '';
      LET sTipo_Cta_Origen = '';
      LET sNotifica_Cte = '';
      LET sNotifica_Recep = '';
      LET sCveOperacion = '';
    LET sFecha_Cancelacion = '';
    LET v_dfecha = '';        
    LET iContador = 0;
      LET sReferencia1 = '';
      LET sReferencia2 = '';
      LET sConvenio = '';
      LET sTipo_Pago = '';
      LET iNo_Repet = 0;
      LET sFecha_Fin = '';
	  LET vNumcte = '';
      
      --debug
      --SET DEBUG FILE TO "/tmp/sp_ConsultarProgramacionGeneral_BPI.out";
    --TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
      
      --Cuerpo del procedimiento.
      BEGIN
            SET LOCK MODE TO WAIT 10;
        SELECT fecha_hoy INTO v_dfecha FROM bdinteg:'informix'.si_fechas;

            --Valida que los parametros de entrada sean diferentes a nulos o blancos
            IF (NVL(p_snum_cte,'') <> '')  THEN
            ELSE
                  SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '104';
                  RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
            END IF;
            IF (NVL(p_sestado,'') <> '')  THEN
            ELSE
                  SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '126';
                  RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
            END IF;
                  --se valida que el cliente exista
                  IF EXISTS(SELECT empresa  FROM bdinteg:'informix'.si_cliente WHERE numcte =  p_snum_cte) THEN
                        --SE EXCLUYEN LOS ESTADOS QUE NO APLICAN PARA CONSULTA DE PROGRAMACION GENERAL
                        IF (p_sestado = '03') or (p_sestado = '05') or (p_sestado = '06') THEN
                             SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '86';
                             RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                        END IF;
                        --SE VALIDA EL VALOR DE ESTADO PERMITIDO
                        IF p_sestado = '99' THEN
                             --SE validaq que existan pagos programados para ese cliente
                                   IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_pagoprog WHERE num_cte = p_snum_cte) THEN
                                         --Se seleccionan todos los pagos programados de ese cliente.
                                         FOREACH     
                                               SELECT SKIP pDesde a.cve_pagoprog,a.cve_estado,a.descripcion as concepto_pago,a.fecha_insert as fecha_programacion,
                                               NVL(b.descripcion,'No Definida') as frecuencia, NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,a.fecha_inicio,
                                               NVL(c.descripcion,'No Definido') as canal_programacion,a.cuenta_destino,NVL(d.nombre,'No Definido') as beneficiario,
                                               e.descripcion as banco_descrip, a.cuenta_origen,f.descripcion as tipo_operacion,
                                               a.cve_notifica_emi,a.cve_notifica,f.cve_pago,a.fecha_cancela, a.referencia1, a.referencia2, a.convenio,
                                               CASE WHEN TRIM(f.cve_pago) == '05' AND a.tipo_spei IN (1,2,3) THEN a.tipo_spei ELSE 1 END, NVL(a.no_repeticiones,0), a.fecha_fin
                                               INTO sCve_PagoProg,aCve_Estado,sConcepto_Pago,sFecha_Programacion,
                                               sFrecuencia,sMonto,sFecha_Inicio,
                                               sCanal_Programacion,sCuenta_Destino,sBeneficiario,
                                               sBanco_Descrip,sCuenta_Origen,sTipo_Operacion,
                                               sCve_Notifica_Emi,sCve_Notifica,sCveOperacion, sFecha_Cancelacion, sReferencia1, sReferencia2, sConvenio,
                                               sTipo_Pago, iNo_Repet, sFecha_Fin
                                               FROM bdiprog:'informix'.pp_pagoprog a LEFT JOIN bdiprog:'informix'.pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                                               LEFT JOIN bdiprog:'informix'.pp_tpcanal c ON (a.cve_canal = c.cve_canal)
                                               LEFT JOIN bdiprog:'informix'.pp_ctasterceros d ON (a.num_cte = d.num_cte and a.cuenta_destino = d.cuenta)
                                               LEFT JOIN bdinteg:'informix'.si_bancos e ON ( a.banco_destino = e.banco )
                                               LEFT JOIN bdiprog:'informix'.pp_tppago f ON (a.cve_pago = f.cve_pago)
                                               WHERE a.num_cte = p_snum_cte
                                               ORDER BY a.cve_estado,a.fecha_insert DESC,b.cve_programa

                                                                IF ( iContador = pHasta ) THEN
                                                                    EXIT foreach;
                                                                END IF;

                                                                IF ( TRIM(aCve_Estado) != '01'  ) THEN
                                                                                                    IF (TRIM(aCve_Estado) = '04'  ) THEN
                                                                                                          IF(iNo_Repet != 0) THEN
                                                                                                                SELECT fecha_prog INTO sFecha_Fin FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg 
                                                                                                                     AND consecutivo = (SELECT MAX(consecutivo) FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg);
                                                                                                          END IF;
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Fin,+6) returning sFecha_Fin;
                                                                                                          IF (sFecha_Fin < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF; 
                                                                                                    ELSE
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Cancelacion,+6) returning sFecha_Cancelacion;
                                                                                                          IF (sFecha_Cancelacion < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF;                                                                
                                                                                                    END IF;
                                                                END IF;                                              
                                                                
                                                                    SELECT limit 1 b.nombre_prod
                                                                    INTO sTipo_Cta_Origen
                                                                    FROM bdicred:'informix'.sd_maecred a
                                                                    JOIN bdicred:'informix'.sd_definicion b ON (a.num_producto=b.num_producto and a.empresa=b.empresa)
                                                                    WHERE a.num_credito = sCuenta_Origen and a.empresa = p_empresa;

                                                                    IF NVL(sTipo_Cta_Origen,'') = '' THEN
                                                                            SELECT limit 1 b.nombre
                                                                            INTO sTipo_Cta_Origen
                                                                            FROM bdicheq:'informix'.sc_maechq a
                                                                            JOIN bdicheq:'informix'.sc_producto b ON (a.producto=b.producto and a.empresa=b.empresa)
                                                                            WHERE a.cuenta = sCuenta_Origen and a.empresa = p_empresa;
                                                                    END IF;

                                                                                                    IF sCveOperacion = '01' THEN --Se obtiene nombre de beneficiario en caso de ser propia
                                                                                                          SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
                                                                                                          INTO sBeneficiario
                                                                                                          FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																									ELIF sCveOperacion = '05' THEN
																										SELECT numcte INTO vNumcte FROM bdicred:"informix".sd_tarjeta where empresa = '001' AND num_tarjeta = sCuenta_Destino;
																										IF vNumcte = sBeneficiario THEN
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																										ELSE
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = vNumcte;
																										END IF;
                                                                                                    END IF;
                                                                                                    
                                                                    SELECT descripcion
                                                                    INTO sNotifica_Cte
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica_Emi;

                                                                    SELECT descripcion
                                                                    INTO sNotifica_Recep
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica;

                                                                    SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '00';
                                                                    LET iContador = iContador + 1;
                                                                    RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago  WITH RESUME;
                                         END FOREACH;
                                   ELSE
                                   --Se informa que no existen pagos programados para ese cliente
                                         SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '88';
                                         RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                                   END IF;
                        ELSE
                             --se valida que exista en la tabla de estados
                             IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_estados WHERE cve_estado = p_sestado) THEN
                                   --SE validaq que existan pagos programados para ese cliente y ese estado
                                   IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_pagoprog WHERE num_cte = p_snum_cte AND cve_estado = p_sestado) THEN
                                         --Se seleccionan todos los pagos programados de ese cliente y ese estado
                                          FOREACH
                                               SELECT SKIP pDesde FIRST pHasta a.cve_pagoprog,a.cve_estado,a.descripcion as concepto_pago,a.fecha_insert as fecha_programacion,
                                               NVL(b.descripcion,'No Definida') as frecuencia, NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,a.fecha_inicio,
                                               NVL(c.descripcion,'No Definido') as canal_programacion,a.cuenta_destino,NVL(d.nombre,'No Definido') as beneficiario,
                                               e.descripcion as banco_descrip, a.cuenta_origen,f.descripcion as tipo_operacion,
                                               a.cve_notifica_emi,a.cve_notifica,f.cve_pago,a.fecha_cancela, a.referencia1, a.referencia2, a.convenio,
                                               CASE WHEN TRIM(f.cve_pago) == '05' AND a.tipo_spei IN (1,2,3) THEN a.tipo_spei ELSE 1 END, NVL(a.no_repeticiones,0), a.fecha_fin
                                               INTO sCve_PagoProg,aCve_Estado,sConcepto_Pago,sFecha_Programacion,
                                               sFrecuencia,sMonto,sFecha_Inicio,
                                               sCanal_Programacion,sCuenta_Destino,sBeneficiario,
                                               sBanco_Descrip,sCuenta_Origen,sTipo_Operacion,
                                               sCve_Notifica_Emi,sCve_Notifica, sCveOperacion,sFecha_Cancelacion, sReferencia1, sReferencia2, sConvenio,
                                               sTipo_Pago, iNo_Repet, sFecha_Fin
                                               FROM bdiprog:'informix'.pp_pagoprog a LEFT JOIN bdiprog:'informix'.pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                                               LEFT JOIN bdiprog:'informix'.pp_tpcanal c ON (a.cve_canal = c.cve_canal)
                                               LEFT JOIN bdiprog:'informix'.pp_ctasterceros d ON (a.num_cte = d.num_cte and a.cuenta_destino = d.cuenta)
                                               LEFT JOIN bdinteg:'informix'.si_bancos e ON ( a.banco_destino = e.banco )
                                               LEFT JOIN bdiprog:'informix'.pp_tppago f ON (a.cve_pago = f.cve_pago)
                                               WHERE a.num_cte = p_snum_cte AND a.cve_estado = p_sestado
                                               ORDER BY a.cve_estado,a.fecha_insert DESC,b.cve_programa
                                               
                                                                 IF ( iContador = pHasta ) THEN
                                                                    EXIT foreach;
                                                                END IF;

                                                                IF ( TRIM(aCve_Estado) != '01'  ) THEN
                                                                                                    IF (TRIM(aCve_Estado) = '04'  ) THEN
                                                                                                          IF(iNo_Repet != 0) THEN
                                                                                                                SELECT fecha_prog INTO sFecha_Fin FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg 
                                                                                                                     AND consecutivo = (SELECT MAX(consecutivo) FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg);
                                                                                                          END IF;
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Fin,+6) returning sFecha_Fin;
                                                                                                          IF (sFecha_Fin < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF; 
                                                                                                    ELSE
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Cancelacion,+6) returning sFecha_Cancelacion;
                                                                                                          IF (sFecha_Cancelacion < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF;                                                                
                                                                                                    END IF;
                                                                END IF;     
                                               
                                                                    SELECT limit 1 b.nombre_prod
                                                                    INTO sTipo_Cta_Origen
                                                                    FROM bdicred:'informix'.sd_maecred a
                                                                    JOIN bdicred:'informix'.sd_definicion b ON (a.num_producto=b.num_producto and a.empresa=b.empresa)
                                                                    WHERE a.num_credito = sCuenta_Origen and a.empresa = p_empresa;

                                                                    IF NVL(sTipo_Cta_Origen,'') = '' THEN
                                                                            SELECT limit 1 b.nombre
                                                                            INTO sTipo_Cta_Origen
                                                                            FROM bdicheq:'informix'.sc_maechq a
                                                                            JOIN bdicheq:'informix'.sc_producto b ON (a.producto=b.producto and a.empresa=b.empresa)
                                                                            WHERE a.cuenta = sCuenta_Origen and a.empresa = p_empresa;
                                                                    END IF;

                                                                                                    IF sCveOperacion = '01' THEN --Se obtiene nombre de beneficiario en caso de ser propia
                                                                                                          SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
                                                                                                          INTO sBeneficiario
                                                                                                          FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																									ELIF sCveOperacion = '05' THEN
																										SELECT numcte INTO vNumcte FROM bdicred:"informix".sd_tarjeta where empresa = '001' AND num_tarjeta = sCuenta_Destino;
																										IF vNumcte = sBeneficiario THEN
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																										ELSE
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = vNumcte;
																										END IF;
                                                                                                    END IF;
                                                                                                    
                                                                    SELECT descripcion
                                                                    INTO sNotifica_Cte
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica_Emi;

                                                                    SELECT descripcion
                                                                    INTO sNotifica_Recep
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica;

                                                                    SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '00';
                                                                    LET iContador = iContador + 1;
                                                                    RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago  WITH RESUME;
                                         END FOREACH;      
                                   ELSE
                                   --Se informa que no existen pagos programados para ese cliente y ese estado
                                         SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '88';
                                         RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                                   END IF;
                             --se informa que el estado no existe
                             ELSE
                                   SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '87';
                                   RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                             END IF;
                        END IF;                 
                  --Se informa que el cliente exista
                  ELSE
                        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '04';
                        RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                        END IF;
      END;
END PROCEDURE;