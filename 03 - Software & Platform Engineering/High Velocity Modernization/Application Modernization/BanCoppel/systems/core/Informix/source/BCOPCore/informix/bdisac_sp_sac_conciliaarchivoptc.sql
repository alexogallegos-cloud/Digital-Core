CREATE PROCEDURE "informix".sp_sac_conciliaarchivoptc ( psNumEmpleado CHAR (10), pdtFechaConciliacionArchivo DATE)

RETURNING CHAR (8) AS CodRespuesta,  CHAR (120) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Ejecuta el proceso de conciliaciÃ?Â?Ã?Â³n del archivo E-Global contra los registros de los catalogos de Movimientos HistÃ?Â?Ã?Â³ricos o los Movimientos del DÃ?Â?Ã?Â­a.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 24/03/2010
-- BD: BdiSac
-- SISTEMA : PAGO INTERBANCARIO DE TARJETAS DE CREDITO (PITDC)
-- Modificado: Casanova Edeza Hector Juan 10/05/2010. Se modifica la logica del sistema para que compare contra la transaccion central (transacc) en lugar de la transaccion de sucursal (transacc_suc) al momento de realizar la conciliacion de los movimientos.
--****************************************************************************************************

DEFINE vsCodRetorno CHAR (8);
DEFINE vsMensajeRet CHAR (120);
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE vsFechaUltimoArchivo DATE;
DEFINE vdtFechaActual DATE;

DEFINE vdtFecha_Alt DATE;
DEFINE vsSucursal CHAR (4);
DEFINE vsCuenta CHAR (20);
DEFINE vsTransacc_Suc CHAR (4);
DEFINE vmMonto_Tot MONEY;
DEFINE vsFolio_Suc CHAR (16);
DEFINE vsReferencia CHAR (20);
DEFINE vsNombreArchivo CHAR (20);


DEFINE vsInd_Deposito_Efectivo CHAR(1);

DEFINE vsParam_TranSacc CHAR(4);
DEFINE vsParam_PagoEfectivo CHAR(4);
DEFINE vsParam_PagoCheqMBanco CHAR(4);
DEFINE vsParam_PagoCheqOBanco CHAR(4);
DEFINE vsParam_PagoInternet CHAR(4);
DEFINE vsTransacc CHAR(4);
DEFINE visqlerr INTEGER;
DEFINE vconsmovhis      CHAR(10);
DEFINE vstatus CHAR(1);
DEFINE cMes CHAR(2);
DEFINE cDia CHAR(2);
DEFINE vsParam_Pagotransfer CHAR(4); 
DEFINE vsParam_PagoCheqCorresp CHAR(4);
DEFINE vsParam_PagoEfeccorresp CHAR(4);

--INICIALIZACION
LET vsCodRetorno = '';
LET vsMensajeRet = '';
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

LET vsFechaUltimoArchivo = CURRENT::DATE;
LET vdtFechaActual = CURRENT::DATE;

LET vdtFecha_Alt = CURRENT::DATE;
LET vsSucursal = '';
LET vsCuenta = '';
LET vsTransacc_Suc = '';
LET vmMonto_Tot = 0.0;
LET vsFolio_Suc = '';
LET vsReferencia = '';
LET vsNombreArchivo = '';
LET vsParam_TranSacc = '';
LET vsParam_PagoEfectivo = '';
LET vsParam_PagoCheqMBanco = '';
LET vsParam_PagoCheqOBanco = '';
LET vsParam_PagoInternet = '';
LET vsTransacc = '';
LET vsInd_Deposito_Efectivo = '';
LET visqlerr = 0;
LET vstatus='';
LET cMes = '';
LET cDia = '';
LET vsParam_Pagotransfer = ''; 
LET vsParam_PagoCheqCorresp = '';
LET vsParam_PagoEfeccorresp = '';

	--SET DEBUG FILE TO "/tmp/sp_sac_conciliaarchivoptc.out";
	--TRACE ON;

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		LET vsCodRetorno = '00599'; --ERROR DE INFORMIX
		
		--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
		SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM bdisac:sac_eglobal_mensajes_error WHERE Cod_Ret = vsCodRetorno and modulo is not null;
		LET vsMensajeRet = TRIM(vsMensajeRet) || ' ERROR (' || visqlerr || ').' ;
		RETURN vsCodRetorno, vsMensajeRet ;
		
	END EXCEPTION;
	
	/*
	IF ( psNumEmpleado = '3' )	THEN
		SET DEBUG FILE TO '/home/sysifx/PITDC/CONCILIAR_ARCH_TIPDC.sql';
		--SET DEBUG FILE TO '/tmp/PITDC/CONCILIAR_ARCH_TIPDC.sql';
		TRACE ON ;
	END IF ;
	*/
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	
	--OBTIENE LA FECHA ACTUAL DEL SISTEMA
	SELECT FIRST 1 NVL(Fecha_Hoy, CURRENT::DATE) INTO vdtFechaActual FROM BdiCheq:Sc_Fechas;

            SELECT valor
              INTO vconsmovhis
              FROM bdicheq:sc_param
             WHERE codparam = 'fechcon_movhis'
               AND  empresa = '001';
			   
	LET cMes = LPAD(MONTH(pdtFechaConciliacionArchivo::DATE), 2, '0');    
	LET cDia = LPAD(DAY(pdtFechaConciliacionArchivo::DATE), 2, '0');
	
	IF (cDia = '24' OR cDia = '31') AND cMes = '12' THEN
		SELECT status_proc INTO vstatus FROM bdinteg:sx_contproc WHERE fecha = pdtFechaConciliacionArchivo AND proceso = 'PasaMovsHist';
	ELSE
		SELECT status_proc INTO vstatus FROM bdinteg:sx_contproc WHERE fecha = pdtFechaConciliacionArchivo+1 AND proceso = 'PasaMovsHist';
	END IF;
	
	IF (TRIM(NVL(psNumEmpleado, '')) = '')THEN --VALIDA QUE EL NUMERODE EMPLEADO CONTENGA INFO
		--EL NUMERO DE EMPLEADO DEBE DE CONTENER INFORMACION
		LET vsCodRetorno = '00501';
	ELIF (pdtFechaConciliacionArchivo IS NULL) THEN 
		--LA FECHA NO PUEDE  NULO
		LET vsCodRetorno = '00507';
	ELIF (vstatus <> 'F' or vstatus is null) THEN 
		--AUN NO CONCLUYE EL PASE DE MOVIMIENTOS AL HISTORICO
		LET vsCodRetorno = '00512';
	ELIF (pdtFechaConciliacionArchivo >= vdtFechaActual) THEN 
		--LA FECHA NO PUEDE SER SUPERIOR A LA ACTUAL
		LET vsCodRetorno = '00502';
	ELIF ( NOT EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Archivo = pdtFechaConciliacionArchivo ) ) THEN --VALIDA KE EXISTA UN ARCHIVO CON LA FECHA DE GENERACION INDICADA
		--NO EXISTNE ARCHIVOS QUE CORRESPONDAN CON LA FECHA PROPORCIONADA
		LET vsCodRetorno = '00503';
	ELIF ( EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Archivo = pdtFechaConciliacionArchivo AND Conciliado = '1') ) THEN --VALIDA SI EL ARCHIVO ESTA CONCILIADO
		--EL ARCHIVO YA FUE CONCILIADO PREVIAMENTE
		LET vsCodRetorno = '00504';
	ELIF ( EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Archivo = pdtFechaConciliacionArchivo AND Estatus = '0') ) THEN --VALIDA KE EXISTA UN ARCHIVO CON LA FECHA DE GENERACION INDICADA Y KE FUE TRANSMITIDO A EGLOBAL.
		--EL ARCHIVO NO SE HA ENVIADO A EGLOBAL
		LET vsCodRetorno = '00505';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION 
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE LA TRANSACCION 
		LET vsCodRetorno = '00506';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN EFECTIVO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN EFECTIVO
		LET vsCodRetorno = '00508';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE MISMO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE MISMO BANCO
		LET vsCodRetorno = '00509';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO CHEQUE OTRO BANCO
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO CHEQUE OTRO BANCO
		LET vsCodRetorno = '00510';
	ELIF ( NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA TRANSACCION DE PAGO EN INTERNET
		--NO EXISTE EL REGISTRO DEL PARAMETRO DE PAGO EN INTERNET
		LET vsCodRetorno = '00511';
	ELSE --OK
		--OBTIENE EL NOMBRE DEL ARCHIVO ACONCILIAR
		SELECT FIRST 1 TRIM(Nombre_Archivo), Fecha_Ultimo_Archivo INTO vsNombreArchivo, vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Fecha_Archivo = pdtFechaConciliacionArchivo;
		
		--OBTIENE LOS PARAMETROS
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_TranSacc FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33003'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfectivo FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33004'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqMBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33005'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqOBanco FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33006'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoInternet FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33007'; 
		
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_Pagotransfer FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33011'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoCheqCorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33012'; 
		SELECT FIRST 1 TRIM(NVL(Valor, '')) INTO vsParam_PagoEfeccorresp FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33013'; 



		--OBTIENE EL ULTIMO REGISTRO DE LA GENERACION DEL ARCHIVO
		--SELECT MAX(Fecha_Ultimo_Archivo) INTO vsFechaUltimoArchivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo <> '' AND Fecha_Archivo < vdtFechaActual;
		
		--INCREMENTA LA FECHA EN UN DIA A LA ULTIMA GENERACION 
		LET vsFechaUltimoArchivo = vsFechaUltimoArchivo + INTERVAL(1) DAY TO DAY;
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		--OBTIENE LOS REGISTROS DE LA TABLA  MOVHIS
        if vsFechaUltimoArchivo >= vconsmovhis then
                FOREACH WITH HOLD
                        SELECT Fech_Alt, Sucursal, Cuenta, Transacc_Suc, Monto_Tot, Folio_Suc, LPAD(TRIM(Referencia),16,'0'), LPAD(TRIM(Transacc), 4, '0' )
                        INTO vdtFecha_Alt, vsSucursal, vsCuenta, vsTransacc_Suc, vmMonto_Tot, vsFolio_Suc, vsReferencia, vsTransacc 
                        FROM bdicheq:sc_movhis
                        WHERE Empresa = '001' AND Cuenta <> ''
                        AND Fech_Alt BETWEEN vsFechaUltimoArchivo::DATE AND pdtFechaConciliacionArchivo::DATE
                        AND Cancelad <> 'S'
                        AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
					
							
                    --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
                    IF (vsFlagEnTransaccion = 'F') THEN 
                         BEGIN WORK;
                         LET vsFlagEnTransaccion = 'V';
                    END IF;

                    LET vsInd_Deposito_Efectivo = '';

                    IF (vsTransacc = vsParam_PagoEfectivo) THEN
                        --LET vsCod_Razon = '91'; 
                        LET vsInd_Deposito_Efectivo = '1'; ---PAGO EN EFECTIVO
                    ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
                        --LET vsCod_Razon = '92'; 
                        LET vsInd_Deposito_Efectivo = '0'; ---PAGO CHEQUE MISMO BANCO
                    ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
                        --LET vsCod_Razon = '93'; 
                        LET vsInd_Deposito_Efectivo = '0'; ---PAGO CHEQUE OTRO BANCO
                    ELIF (vsTransacc = vsParam_PagoInternet) THEN
                        --LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO INTERNET+
					ELIF (vsTransacc = vsParam_Pagotransfer) THEN
						--LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO TRANSFER
					ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN
						--LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO CARGO CTA CORRESPONSALES
					ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN
						--LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '1'; --PAGO EFECTIVO CORRESPONSALES					
                    END IF;							

                    IF ( EXISTS(SELECT Nombre_Archivo FROM bdisac:sac_eglobal_detalle WHERE Nombre_Archivo = vsNombreArchivo AND Fecha_Archivo = pdtFechaConciliacionArchivo AND Folio_Suc = vsFolio_Suc AND Numero_Tarjeta = vsReferencia AND Ind_Deposito_Efectivo = vsInd_Deposito_Efectivo) ) THEN --EXISTE EN EL ARCHIVO
                        --ACTUALIZA EL REGISTRO COMO CONCILIADO
                        UPDATE bdisac:sac_eglobal_detalle SET Conciliado = '1' WHERE Nombre_Archivo = vsNombreArchivo AND Fecha_Archivo = pdtFechaConciliacionArchivo AND Folio_Suc = vsFolio_Suc AND Numero_Tarjeta = vsReferencia AND Ind_Deposito_Efectivo = vsInd_Deposito_Efectivo;
                    ELSE -- NO EXISTE EN EL ARCHIVO
                        -- SE GUARDA EN LA TABLA DE NO CONCILIADOS
                        INSERT INTO BdiSac:Sac_EGlobal_NoConcil (Nombre_Archivo, Fecha_Archivo, Fecha_Mov, Sucursal, Cuenta_Cargo, Transacc_Suc, Importe, Folio_Suc, Referencia, User_Insert, Fecha_Insert)
                        VALUES (vsNombreArchivo, pdtFechaConciliacionArchivo, vdtFecha_Alt, vsSucursal, vsCuenta, vsTransacc_Suc, vmMonto_Tot, vsFolio_Suc, vsReferencia, psNumEmpleado, CURRENT);
                    END IF;

                    LET viContadorRegistros = viContadorRegistros + 1;

                    --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
                    IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                        COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                        LET viContadorRegistros = 0;
                        CONTINUE FOREACH;
                    END IF;

                END FOREACH;
          else
                FOREACH WITH HOLD
                        SELECT Fech_Alt, Sucursal, Cuenta, Transacc_Suc, Monto_Tot, Folio_Suc, LPAD(TRIM(Referencia),16,'0'), LPAD(TRIM(Transacc), 4, '0' )
                        INTO vdtFecha_Alt, vsSucursal, vsCuenta, vsTransacc_Suc, vmMonto_Tot, vsFolio_Suc, vsReferencia, vsTransacc 
                        FROM bdicheq:sc_movhis_old
                        WHERE Empresa = '001' AND Cuenta <> ''
                        AND Fech_Alt BETWEEN vsFechaUltimoArchivo::DATE AND pdtFechaConciliacionArchivo::DATE
                        AND Cancelad <> 'S'
                        AND Transacc IN (vsParam_PagoEfectivo, vsParam_PagoCheqMBanco, vsParam_PagoCheqOBanco, vsParam_PagoInternet,vsParam_Pagotransfer,vsParam_PagoCheqCorresp,vsParam_PagoEfeccorresp)
												
						
                    --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
                    IF (vsFlagEnTransaccion = 'F') THEN 
                         BEGIN WORK;
                         LET vsFlagEnTransaccion = 'V';
                    END IF;

                    LET vsInd_Deposito_Efectivo = '';

                    IF (vsTransacc = vsParam_PagoEfectivo) THEN
                        --LET vsCod_Razon = '91'; 
                        LET vsInd_Deposito_Efectivo = '1'; ---PAGO EN EFECTIVO
                    ELIF (vsTransacc = vsParam_PagoCheqMBanco) THEN
                        --LET vsCod_Razon = '92'; 
                        LET vsInd_Deposito_Efectivo = '0'; ---PAGO CHEQUE MISMO BANCO
                    ELIF (vsTransacc = vsParam_PagoCheqOBanco) THEN
                        --LET vsCod_Razon = '93'; 
                        LET vsInd_Deposito_Efectivo = '0'; ---PAGO CHEQUE OTRO BANCO
                    ELIF (vsTransacc = vsParam_PagoInternet) THEN
                        --LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO INTERNET
					ELIF (vsTransacc = vsParam_Pagotransfer) THEN
                        --LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO TRANSFER
					ELIF (vsTransacc = vsParam_PagoCheqCorresp) THEN
                        --LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '0'; --PAGO CARGO CTA CORRESPONSALES
					ELIF (vsTransacc = vsParam_PagoEfeccorresp) THEN
                        --LET vsCod_Razon = '94'; 
                        LET vsInd_Deposito_Efectivo = '1'; --PAGO EFECTIVO CORRESPONSALES
                    END IF;					

                    IF ( EXISTS(SELECT Nombre_Archivo FROM bdisac:sac_eglobal_detalle WHERE Nombre_Archivo = vsNombreArchivo AND Fecha_Archivo = pdtFechaConciliacionArchivo AND Folio_Suc = vsFolio_Suc AND Numero_Tarjeta = vsReferencia AND Ind_Deposito_Efectivo = vsInd_Deposito_Efectivo) ) THEN --EXISTE EN EL ARCHIVO
                        --ACTUALIZA EL REGISTRO COMO CONCILIADO
                        UPDATE bdisac:sac_eglobal_detalle SET Conciliado = '1' WHERE Nombre_Archivo = vsNombreArchivo AND Fecha_Archivo = pdtFechaConciliacionArchivo AND Folio_Suc = vsFolio_Suc AND Numero_Tarjeta = vsReferencia AND Ind_Deposito_Efectivo = vsInd_Deposito_Efectivo;
                    ELSE -- NO EXISTE EN EL ARCHIVO
                        -- SE GUARDA EN LA TABLA DE NO CONCILIADOS
                        INSERT INTO BdiSac:Sac_EGlobal_NoConcil (Nombre_Archivo, Fecha_Archivo, Fecha_Mov, Sucursal, Cuenta_Cargo, Transacc_Suc, Importe, Folio_Suc, Referencia, User_Insert, Fecha_Insert)
                        VALUES (vsNombreArchivo, pdtFechaConciliacionArchivo, vdtFecha_Alt, vsSucursal, vsCuenta, vsTransacc_Suc, vmMonto_Tot, vsFolio_Suc, vsReferencia, psNumEmpleado, CURRENT);

                    END IF;



                    LET viContadorRegistros = viContadorRegistros + 1;

                    --TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
                    IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
                        COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                        LET viContadorRegistros = 0;
                        CONTINUE FOREACH;
                    END IF;

                END FOREACH;
          end if;
		
		--ACTUALIZA EL REGISTRO DEL ARCHIVO A CONCILIADO
		UPDATE BdiSac:Sac_EGlobal_Archivos SET Conciliado = '1', User_Insert = psNumEmpleado, Fecha_Insert = CURRENT::DATE WHERE Nombre_Archivo = vsNombreArchivo AND Fecha_Archivo = pdtFechaConciliacionArchivo;
		
		
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
		LET vsCodRetorno = '00000';
		
	END IF;
		
	--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
	SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM bdisac:sac_eglobal_mensajes_error WHERE Cod_Ret = vsCodRetorno and modulo is not null;
	
	RETURN vsCodRetorno, vsMensajeRet ;
	
END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Ejecuta el proceso de conciliaciÃ?Â?Ã?Â³n del archivo E-Global contra los registros de los catalogos de Movimientos HistÃ?Â?Ã?Â³ricos o los Movimientos del DÃ?Â?Ã?Â­a..',
'Fecha: 2010/03/24',
'Version: 20100324.1048',
'BD: BdiSac',
'',
'Modificado: Casanova Edeza HÃ?Â?Ã?Â©ctor Juan',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica la logica del sistema para que compare contra la transaccion central (transacc) en lugar de la transaccion de sucursal (transacc_suc) al momento de realizar la conciliacion de los movimientos.',
'Fecha: 2010/05/10',
'Version: 20100510.0902',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_calculaprorrateodecomisiones(dFecha_Hoy DATE)
RETURNING CHAR(5);

    --DEFINICION DE VARIABLES
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE mImporte         MONEY(16,2);
    DEFINE mIva             MONEY(16,2);
    DEFINE cNumCategoria    CHAR(2);
    DEFINE cNumConvenio     CHAR(3);
    DEFINE cInfoErr         CHAR(100);
    DEFINE iExiste          INTEGER;

      --	SET DEBUG FILE TO "/informix/VH/sac/exi.out";
      --	TRACE ON;

    --INICIALIACION DE VARIABLES
    LET cCodRet = '00000';
    LET cNumCategoria='0';
    LET cNumConvenio='0';
    LET mImporte=0;
    LET mIva=0;
    LET iExiste =0;


    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_SACCalculaProrrateoDeComisiones");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;

        FOREACH
        SELECT /*{+INDEX (bdisac:sac_convenios idxsac_conv3)}*/ 
				numcategoria,
				numconvenio,
				imp_com_trans_conv,
				iva_convenio 
			INTO 
				cNumCategoria,
				cNumConvenio,
				mImporte,
				mIva 
		   FROM 
				sac_convenios 
			WHERE 
				nomconvenio NOT IN ('PAGO DE REMESAS BTS') 
				AND imp_com_trans_conv <> 0 
				ORDER BY 
				/* Utiliza el Ã­ndice en la clÃ¡usula ORDER BY para mejorar el rendimiento */
				numcategoria, numconvenio
    
  --          SELECT /*{+INDEX (bdisac:sac_convenios idxsac_conv3)}*/ numcategoria,numconvenio,imp_com_trans_conv,iva_convenio INTO cNumCategoria,cNumConvenio,mImporte,mIva FROM sac_convenios WHERE nomconvenio NOT IN ('PAGO DE REMESAS--- BTS') AND imp_com_trans_conv<>0 

            SELECT COUNT(*) INTO iExiste FROM sac_movimientos 
            WHERE fecha_pago = dFecha_Hoy AND numcategoria = cNumCategoria and numconvenio = cNumConvenio AND importe_comision_convenio<>mImporte;

            IF iExiste>0 THEN
                UPDATE sac_movimientos SET importe_comision_convenio = mImporte, iva_comision_convenio = mImporte * (mIva/100)
                WHERE fecha_pago = dFecha_Hoy AND numcategoria = cNumCategoria AND numconvenio = cNumConvenio AND importe_comision_convenio<>mImporte;
            END IF;

        END FOREACH;
        RETURN cCodRet;
    END;
 END PROCEDURE
 DOCUMENT
'AUTOR : Jose Angel Lopez Adams',
'DESCRIPCION: Se encarga de calcular un prorrateo de las comisiones de aquellos convenios, a los cuales se les cobra comision por el total de la cobranza',
'EJECUTADO O LLAMADO POR: sp_ProcesoCierreDiarioSAC',
'BD: bdisac',
'FECHA : Septiembre de 2008',
'VERSION: 20080905';

CREATE PROCEDURE "informix".sp_generaarchivoscobranzacentral(dFecha_Hoy DATE)
RETURNING CHAR(5);  --CÃÂ³digo de retorno

   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;
    DEFINE cInfoErr                 CHAR(100);

    DEFINE cStatusConvenio          CHAR(1);
    DEFINE cNumCategoria            CHAR(2);
    DEFINE cNumConvenio             CHAR(3);
    DEFINE cId_convenio             CHAR(5);
    DEFINE cNom_rutina              CHAR(100);
    DEFINE cSqlStmt                 CHAR(200);

    DEFINE iFrecuencia              INTEGER;
    DEFINE iDiferencia              INTEGER;
    DEFINE iTransacciones           INTEGER;

    DEFINE dFechaUltimoArchivo      DATE;

    DEFINE bFlag                    BOOLEAN;

    DEFINE antadActivo              INTEGER;
    DEFINE actualActivo             char(5);
    DEFINE actualRegistrado         char(5);
    DEFINE cuentaRegistrados        INTEGER;


    --SET DEBUG FILE TO "/tmp/Cent.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cInfoErr = '';

    LET cStatusConvenio = '';
    LET cSqlStmt = '';
    LET cNom_rutina = '';
    LET cId_convenio = '';
    LET iFrecuencia = 0;
    LET iTransacciones = 0;
    LET iDiferencia = 0;
    LET bFlag = 'f';

    LET antadActivo = 0;
    LET actualActivo = '';
    LET actualRegistrado = '';
    LET cuentaRegistrados = 0;





    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_genera_ArchivosCobranzaCentral");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
        --SET DEBUG FILE TO "/tmp/exi.out";
        --TRACE ON;



 --ANTAD  mofificacion RQM 10 954 Alta de ConexiÃÂ³n a Red de Plataforma ElectrÃÂ³nica ANTAD.
            --esta secciÃÂ³n mantiene el registro de un solo convenio de antad en la tabla 'sac_controlarchivoscobranza'

            LET antadActivo = (SELECT count(*) FROM sac_convenios WHERE nomconvenio like '%ANTAD)' and statusconvenio='A');

            IF antadActivo > 0 THEN
                
                LET actualActivo = (SELECT FIRST 1 numcategoria || numconvenio FROM sac_convenios WHERE nomconvenio like '%ANTAD)' and statusconvenio='A');
                LET cuentaRegistrados = (SELECT count(*) FROM sac_controlarchivoscobranza WHERE nom_rutina ='sp_generaarchivocobranzaantad');

                IF cuentaRegistrados = 0 THEN 
                        INSERT INTO "informix".sac_controlarchivoscobranza(numcategoria, numconvenio, nom_rutina, retorno, fecha_ultimo_archivo)
                        VALUES(substr(actualActivo,1,2), substr(actualActivo,3,3), 'sp_generaarchivocobranzaantad', '00000', today-1);
                ELSE
                    LET actualRegistrado= (SELECT numcategoria || numconvenio FROM sac_controlarchivoscobranza WHERE nom_rutina = 'sp_generaarchivocobranzaantad');

                    IF actualActivo <> actualRegistrado THEN
                        UPDATE "informix".sac_controlarchivoscobranza set numcategoria = substr(actualActivo,1,2), numconvenio =substr(actualActivo,3,3)
                        WHERE numcategoria = substr(actualRegistrado,1,2) and numconvenio =substr(actualRegistrado,3,3);
                    END IF;
                END IF;
            END IF;
 --/ANTAD---------------------------------------------------



            FOREACH
                --SELECT  a.numcategoria, a.numconvenio, a.statusconvenio, a.frecnotificacion, b.nom_rutina, b.fecha_ultimo_archivo
                --FROM bdisac:sac_convenios a
                --INNER JOIN bdisac:sac_controlarchivoscobranza b
                --INTO cNumCategoria, cNumConvenio, cStatusConvenio, iFrecuencia, cNom_rutina, dFechaUltimoArchivo
                --ON a.numcategoria = b.numcategoria
                --AND a.numconvenio = b.numconvenio;

            --se cambia la consulta para quitar la busqueda secuencial ---
SELECT 
    a.numcategoria, 
    a.numconvenio, 
    a.statusconvenio, 
    a.frecnotificacion, 
    TRIM(b.nom_rutina), 
    b.fecha_ultimo_archivo
INTO 
    cNumCategoria, 
    cNumConvenio, 
    cStatusConvenio, 
    iFrecuencia, 
    cNom_rutina, 
    dFechaUltimoArchivo
FROM 
    bdisac:sac_convenios a
JOIN 
    bdisac:sac_controlarchivoscobranza b
    ON a.numcategoria = b.numcategoria
    AND a.numconvenio = b.numconvenio
WHERE
    a.numcategoria IN (SELECT numcategoria FROM bdisac:sac_controlarchivoscobranza)
                
                
/*

                SELECT  a.numcategoria, a.numconvenio, a.statusconvenio, a.frecnotificacion, TRIM(b.nom_rutina), b.fecha_ultimo_archivo
                INTO cNumCategoria, cNumConvenio, cStatusConvenio, iFrecuencia, cNom_rutina, dFechaUltimoArchivo
                FROM bdisac:sac_convenios a, bdisac:sac_controlarchivoscobranza b
                WHERE  a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio

*/

           


                LET cId_convenio = cNumCategoria || cNumConvenio ;
                LET iDiferencia = ((dFecha_Hoy::DATE) - (dFechaUltimoArchivo::DATE));

                IF iDiferencia >= iFrecuencia THEN
                    IF cStatusConvenio = 'I' THEN

                      SELECT COUNT(*)
INTO iTransacciones
FROM sac_movimientoshistorial
WHERE numcategoria = cNumCategoria
  AND numconvenio = cNumConvenio
    AND fecha_pago > dFechaUltimoArchivo
LIMIT 1;


                        IF iTransacciones > 0 THEN
                                LET bFlag = 't';
                        END IF;
                    END IF;

                    IF cStatusConvenio = 'A' OR bFlag = 't' THEN

                        --LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'||TRIM(cNom_rutina)||"('"||cId_convenio||''''||','''||dFechaUltimoArchivo||''', ''' || dFecha_Hoy || ''');"> /tmp/tmp.sql';
                        LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'||TRIM(cNom_rutina)||"('"||cId_convenio||''');" > /tmp/cob.sql';
                        SYSTEM cSqlStmt;
                        LET cSqlStmt  = 'dbaccess bdisac /tmp/cob.sql';
                        SYSTEM cSqlStmt;

                        SELECT retorno
                        INTO cCodRet
                        FROM sac_controlarchivoscobranza
                        WHERE numcategoria = cNumCategoria
                        AND numconvenio = cNumConvenio;

                        IF CAST(cCodRet AS INTEGER) <> 0 THEN
                            RETURN cCodRet;
                        END IF;


                    END IF;
                END IF;

                LET bFlag = 'f';

            END FOREACH;
            LET cSqlStmt = 'rm -f /tmp/cob.sql';
            SYSTEM cSqlStmt;

            RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃÂ© Angel LÃÂ³pez Adams',
'DESCRIPCION: Se encarga de validar si es tiempo de generar el archivo de cobranza de un convenio, de ser asi ejecuta el SP correspondiente',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Agosto de 2008',
'VERSION: 200808',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_tramapago_dish(pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER,pTimeStamp CHAR (10))
RETURNING CHAR (5) AS cCodRet, CHAR (35) AS cTrama;

--Variables
DEFINE cCodRet CHAR(5);
DEFINE cTrama CHAR(35);
DEFINE iSqlErr INTEGER;
DEFINE cTrans_MotorS CHAR(5); -- Trans_Motors
DEFINE cTrans_Suc CHAR(4);
DEFINE cTrans_Central CHAR(5);
DEFINE cTrans_Interact CHAR(5);
DEFINE cNum_Sucursal CHAR (4);
DEFINE cReferencia CHAR(14);
DEFINE cUser_Insert CHAR(10);
DEFINE cFolioConsultaDish CHAR(10);
DEFINE cImportePago CHAR(10);
DEFINE cClienteDish CHAR(10);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET cTrama		= '';
LET cTrans_MotorS	= '';	
LET cTrans_Suc = '';
LET cTrans_Central = '';
LET cTrans_Interact = '';
LET cClienteDish = '';
LET cFolioConsultaDish = '';
LET cImportePago = '';
LET cNum_Sucursal = pId_Sucursal;
LET cReferencia = TRIM(pRef1);
LET cUser_Insert = 'Informix';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_tramapagodish.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
	END EXCEPTION;

	IF NVL(pFecha_Pago, '') = '' OR NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL (pRef1, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; --DATOS VACIOS, ERROR.
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos la codigo del interac requeridos  de bdisac:"informix".sac_intrfz_serv
	SELECT trans_interact, trans_servicio INTO  cTrans_Interact, cTrans_MotorS FROM   bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Interact= '' Or cTrans_MotorS= '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos los parametros de la sac_msw_respuesta para la generacion de la trama
	SELECT campo2, campo7 INTO cClienteDish, cFolioConsultaDish FROM  bdisac:"informix".sac_msw_respuesta  WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = 1;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cClienteDish = '' OR cFolioConsultaDish = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;				
		
	--Obtenemos el monto a pagar
	SELECT REPLACE(importe_pago,'$', '') INTO cImportePago FROM bdisac:"informix".sac_movimientos WHERE numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal;

	--Agrupa los datos para la generacion de la trama
	LET cTrama = cTrans_MotorS||cFolioConsultaDish||cImportePago||cClienteDish;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM   bdisac: "informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '0');
	END IF;
	
/*	
	INSERT INTO bdisac: "informix".sac_msw_solicitud(
		numcategoria,
		numconvenio, 
		id_sucursal, 
		trans_suc, 
		trans_central, 
		trans_interact, 
		folio_suc, 
		fecha_pago, 
		num_trama, 
		campo1, 
		campo2, 
		campo3, 
		campo4,
		campo5,campo6,campo7,campo8,campo9,campo10,campo11,campo12,campo13,campo14,
		campo15,campo16,campo17,campo18,campo19,campo20,campo21,campo22,campo23,campo24,
		campo25,campo26,campo27,campo28,campo29,campo30,campo31,campo32,campo33,campo34,
		campo35,campo36,campo37,campo38,campo39,campo40,
		user_insert,
		fecha_insert) 
		VALUES (
		pNumCategoria, 
		pNumConvenio, 
		pId_Sucursal, 
		cTrans_Suc, 
		cTrans_Central, 
		cTrans_Interact, 
		pFolioSucursal, 
		pFecha_Pago,
		pNumTrama,
		cTrans_MotorS,
		cNum_Sucursal,
		cReferencia,
		cClienteDish,
		cImportePago,
		cFolioConsultaDish,
		pTimeStamp,
		'','','','','','','','','',
		'','','','', '', '', '', '', '',
		'', '', '', '', '', '', '', '', '',
		'', '', '', '', '', '',
		cUser_Insert,
		current);		*/
	  
	RETURN cCodRet, NVL(cTrama, '');
END;
END PROCEDURE
;