CREATE PROCEDURE "informix".sp_indic_primer_compra( pFechaI DATE ,pFechaF DATE, pTipo char(1)) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vCodFun         CHAR(3);
DEFINE	vCodRef         SMALLINT;
DEFINE	vPagoCliente	CHAR(1);
DEFINE	vlCredito CHAR(20); 
DEFINE	vlMonto DECIMAL(18,2);
DEFINE	vlTransaccion CHAR(4); 

DEFINE	vlTipo SMALLINT;
DEFINE	vlnum_credito	CHAR(20);
DEFINE	vlnumcuenta	CHAR(20);
DEFINE	vlFechaAlta	DATE;

--DEFINE	vLPrimerCompra	DECIMAL(18,2); 
--DEFINE	vlMontoPrimerDisp	DECIMAL(18,2);

DEFINE	vlfecha_movD 	DATE;
DEFINE	vlmontoD 		DECIMAL(18,2);
DEFINE	vltransacc_sucD	CHAR(4);

DEFINE	vlfecha_movc 	DATE;
DEFINE	vlmontoC 		DECIMAL(18,2);
DEFINE	vltransacc_succ	CHAR(4);
DEFINE vvcCod_ret           CHAR(6);
DEFINE cproceso             CHAR(4);	
DEFINE vTipo	CHAR(1);
------------------------------------------------

------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--TRACE ON;

    LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
	LET vCodFun       = '';
	LET vCodRef       = '';
	LET vPagoCliente  = '';		  	
	LET	vlCredito =''; 
	LET	vlMonto =0; 
	LET	vlTransaccion =''; 
	LET	vlTipo =10;
	LET	vlfecha_movD 	=dATE(1);
	LET	vlmontoD 		= NULL;
	LET	vltransacc_sucD	=NULL;
	LET	vlfecha_movc 	=DATE(1);
	LET	vlmontoC 		=NULL;
	LET	vltransacc_succ	= NULL;
	LET cproceso      = '0100';	
	LET cMensaje      = 'PROCESO EXITOSO';
	LET vTipo		  = '0';


BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '02')  RETURNING vvcCod_ret;
            RETURN cCod_ret;
        END EXCEPTION;

		set isolation to dirty read;
		SET LOCK MODE TO WAIT 3;						
				
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '01') RETURNING vvcCod_ret;
	If pTipo = '0' then 
	/*	foreach with hold   
		  select num_credito, fecha_alta, 
		         monto_primer_compra,f_primer_compra,trans_primer_compra , 
		         monto_primer_disp,f_primer_disp,trans_primer_disp
             into 	vlnum_credito	, vlFechaAlta , 
					vlmontoD, vlfecha_movD,  vltransacc_sucD,
					vlmontoC, vlfecha_movc ,	vltransacc_succ	
		  from sd_indicador_cred
		  where empresa = '001'
		    and fecha_alta >= pFechaI and fecha_alta <=pFechaF
			
			
		--IF vlmontoD IS NULL THEN
		
            SELECT transacc_suc,monto,nvl(fecha_mov,date(1))
               INTO vltransacc_sucD,vlmontoD,vlfecha_movD
               FROM "informix".sd_movhis
               where empresa = '001'
               and num_credito = vlnum_credito
               and secuencia = 
            (SELECT min(secuencia)
               FROM "informix".sd_movhis
                WHERE empresa='001'
                  and num_credito = vlnum_credito
                  and codigo_fun ='002'
                  and codigo_ref IN (50,30,40,42,41)
                  and reversado='N');  
		
		  --END IF; 	
	  
		IF vlmontoC IS NULL THEN

            SELECT transacc_suc,monto,nvl(fecha_mov,date(1))
               into vltransacc_sucC, vlmontoC, vlfecha_movC
               FROM "informix".sd_movhis
               where empresa = '001'
               and num_credito = vlnum_credito
               and secuencia = 
            (SELECT min(secuencia)
               FROM "informix".sd_movhis
                WHERE empresa='001'
                  and num_credito = vlnum_credito
                  and codigo_fun ='002'
			      and codigo_ref in (37,57) 			
                  and reversado='N'); 


		 END IF;
		 
		 BEGIN WORK;
		  UPDATE sd_indicador_cred
		    SET 
				monto_primer_compra =vlmontoC,
				f_primer_compra = vlfecha_movc,
				trans_primer_compra =vltransacc_succ, 
		        monto_primer_disp =vlmontoD,
				f_primer_disp = vlfecha_movD,
				trans_primer_disp = vltransacc_sucD
		where empresa = '001'
		 and num_credito = vlnum_credito;
		COMMIT WORK;
		
		END Foreach;		*/
        let  vlmontoC = 0.0;
	Elif pTipo ='1' then 
		Foreach with hold            
		  select  num_credito, monto,fecha, tipo 		         
           into  vlnum_credito, vlmontoD,vlFechaAlta , vTipo
		  from sd_primer_transaccion where transaccion = '0' and ( Tipo ='1' or  Tipo ='0' or Tipo = 'P' )

		  begin work;
		    UPDATE sd_indicador_cred
		    SET monto_ult_convenio =vlmontoD,
				fecha_ult_convenio = vlFechaAlta,
				cumplio_convenio =vTipo		        
		    where empresa = '001'
		      and num_credito = vlnum_credito;

		    update sd_primer_transaccion set transaccion = '1' where num_credito = vlnum_credito;

		  commit work;	
		End foreach;  
	Elif pTipo ='2' then 
		Foreach with hold   
		  select num_credito, monto,fecha, tipo 		         
           	    into  vlnum_credito, vlmontoD,vlFechaAlta , vTipo
		  from sd_primer_transaccion 
          where transaccion = '0' and (Tipo='V' or Tipo ='P' or Tipo ='C' )

		  begin work;
		    if vTipo = 'V' then
				UPDATE sd_indicador_cred
				SET monto_ultima_compra =vlmontoD,
					fecha_ultima_compra = vlFechaAlta,
					vnt_disp_monto =vlmontoD,
					vnt_disp_fecha = vlFechaAlta
				where empresa = '001'
				and num_credito = vlnum_credito and monto_ultima_compra is null;
			elif vTipo = 'P' then
				UPDATE sd_indicador_cred
					SET monto_ultima_compra =vlmontoD,
						fecha_ultima_compra = vlFechaAlta,
						pos_disp_monto  =vlmontoD,   
						pos_disp_fecha = vlFechaAlta
					where empresa = '001'
					and num_credito = vlnum_credito and monto_ultima_compra is null;
			else 		
				UPDATE sd_indicador_cred
					SET monto_ultima_compra =vlmontoD,
						fecha_ultima_compra = vlFechaAlta,
						atm_disp_monto  =vlmontoD,   
						atm_disp_fecha =vlFechaAlta
					where empresa = '001'
					and num_credito = vlnum_credito and monto_ultima_compra is null;
			end if;
		    update sd_primer_transaccion set transaccion = '1' where num_credito = vlnum_credito;

		  commit work;	
		End foreach;  
    Elif pTipo ='3' then 
		Foreach with hold   
		  select num_credito, monto,fecha, tipo 		         
           	    into  vlnum_credito, vlmontoD,vlFechaAlta , vTipo
		  from sd_primer_transaccion where transaccion = '0' and tipo ='P'

		  begin work;		    
				UPDATE sd_indicador_cred
					SET monto_ultimo_pago =vlmontoD,
						fecha_ultimo_pago = vlFechaAlta						
					where empresa = '001'
					and num_credito = vlnum_credito 
                    and monto_ultimo_pago is null;	
		
		    update sd_primer_transaccion set transaccion = '1' 
             where num_credito = vlnum_credito and tipo ='P';
		  commit work;	
		End foreach;  
    Elif pTipo ='4' then 
		Foreach with hold   
		  select num_credito, monto,fecha, tipo	,transaccion	         
           	    into  vlnum_credito, vlmontoD,vlFechaAlta , vTipo,vltransacc_succ
		  from sd_primer_transaccion 
          where ( tipo = 'C' or tipo = 'D') 

		  begin work;		    
			if vTipo = 'C' then --Disposicion
				UPDATE sd_indicador_cred
				SET monto_primer_compra =vlmontoD,
					f_primer_compra = vlFechaAlta,
					trans_primer_compra =vltransacc_succ
				where empresa = '001'
				and num_credito = vlnum_credito;
			elif vTipo = 'D' then --Compra
				UPDATE sd_indicador_cred
					SET monto_primer_disp =vlmontoD,
						f_primer_disp = vlFechaAlta,
						trans_primer_disp  =vltransacc_succ
					where empresa = '001'
					and num_credito = vlnum_credito ;
               end if;     
		    update sd_primer_transaccion set transaccion = '1' where num_credito = vlnum_credito and transaccion = vltransacc_succ and fecha= vlFechaAlta;
		  commit work;	
		End foreach;  
    Elif pTipo ='5' then 
		Foreach with hold   
		  select num_credito, monto,fecha, tipo	,transaccion	         
           	    into  vlnum_credito, vlmontoD,vlFechaAlta , vTipo,vltransacc_succ
		  from sd_primer_transaccion 
          where transaccion = '0' and tipo ='S'

		  begin work;		    			
				UPDATE sd_indicador_cred
				SET saldo_maximo = ( case when nvl(saldo_maximo,0) < vlmontoD then vlmontoD else saldo_maximo end  )
				where empresa = '001'
				and num_credito = vlnum_credito;			
		    update sd_primer_transaccion set transaccion = '1' where num_credito = vlnum_credito;
		  commit work;	
		End foreach;  
	Elif pTipo ='6' then ---GEV
		Foreach with hold  
		  select num_credito, fecha_ult_convenio  into vlnumcuenta, vlFechaAlta
                  from bdicred:sd_indicador_cred
		  where cumplio_convenio = 'P'

		  let vTipo = 0;

                  select first 1 flag_pago into vTipo
		  from bdicobranza:cb_compac_his 
                  where empresa = '001' 
		  and numcuenta =vlnumcuenta
		  and fecha_compac =vlFechaAlta;

		  
		  begin work;
		    UPDATE sd_indicador_cred
		    SET cumplio_convenio =vTipo		        
		    where empresa = '001'
		      and num_credito = vlnumcuenta;
		  commit work;	
		End foreach;
	End if;	
	UPDATE STATISTICS medium FOR TABLE "informix".sd_indicador_cred;
	  CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '03')
      RETURNING vvcCod_ret;		
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de Crédito',
'AUTOR : Faviola Martínez Juárez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".sp_consultatitularcredito(pEmpresa CHAR(3), pNumeroTarjeta CHAR(20), pNumeroCte CHAR(20))

RETURNING CHAR(5)  AS CodRetorno,    
		  CHAR(20) AS Num_Cliente,  
		  CHAR(26) AS Nombre1,  
		  CHAR(26) AS Nombre2,   
		  CHAR(26) AS Apell_Paterno,  
		  CHAR(26) AS Apell_Materno,
		  CHAR(20) AS Num_Credito,
		  CHAR(4)  AS Producto_Credito,  
		  CHAR(1)  AS Tipo_Tarjeta,
		  CHAR(1)  AS Status_Tarjeta;

--DECLARACION DE VARIABLES
DEFINE iSqlErr          INTEGER;
DEFINE cCodRet          CHAR(5);
DEFINE cNumCte          CHAR(20);
DEFINE cNumCte2         CHAR(20);
DEFINE cApell_Paterno   CHAR(26);
DEFINE cApell_Materno   CHAR(26);
DEFINE cNombre1         CHAR(26);
DEFINE cNombre2         CHAR(26);
DEFINE cNumCredito      CHAR(20);
DEFINE cProductoCredito CHAR(4);
DEFINE cStatusTarj      CHAR(1);
DEFINE cTipoTarjeta     CHAR(1);
Define cSecuencia       CHAR(2);

--INICIALIZACION DE VARIABLES

LET cCodRet 		 = "00000";
LET cNumCte 		 = "";
LET cNumCte2		 = "";
LET cApell_Paterno 	 = "";
LET cApell_Materno	 = "";
LET cNombre1 		 = "";
LET cNombre2 		 = "";
LET cStatusTarj 	 = "";
LET cNumCredito 	 = "";
LET cTipoTarjeta 	 = "";
LET cProductoCredito = "";
LET cSecuencia 		 = "";

BEGIN 

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet, '', '', '', '', '', '', '','','';
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_consultatitularcredito.out"; 
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

--OBTENER DATOS DEL CLIENTE
	
		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '00458';
			RETURN cCodRet, '', '', '', '', '', '', '','','';
		ELIF NVL(pNumeroCte,'') = '' THEN
			IF pNumeroTarjeta <> "" THEN
				IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta  = pNumeroTarjeta) THEN
					SELECT num_credito,numcte 
					INTO cNumCredito,cNumCte  
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = pEmpresa 
					AND num_tarjeta = pNumeroTarjeta;
					
					
				ELSE
					LET cCodRet = "00545";
					RETURN cCodRet, '', '', '', '', '', '', '','','';
				END IF;
			   
			ELSE
				LET cCodRet = '00458';
				RETURN cCodRet, '', '', '', '', '', '', '','','';
			END IF;
		ELIF NVL(pNumeroTarjeta,'') = '' THEN
			IF pNumeroCte <> "" THEN
				LET cNumCte = pNumeroCte;
				
				SELECT b.num_credito 
				INTO cNumCredito 
				FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tarjeta b
				WHERE a.empresa = pEmpresa 
				AND a.num_credito = b.num_credito
				AND b.numcte = cNumCte
				AND b.tipo_tarjeta = 'T'
				AND b.status_tar = 'A';
				--AND a.numcte = b.numcte;
			ELSE
				LET cCodRet = '00458';
				RETURN cCodRet, '', '', '', '', '', '', '','','';
			END IF;
		ELSE
			IF pNumeroTarjeta <> "" THEN
				IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta  = pNumeroTarjeta) THEN
					SELECT num_credito 
					INTO cNumCredito
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = pEmpresa 
					AND num_tarjeta = pNumeroTarjeta;


					SELECT numcte 
					INTO cNumCte 
					FROM bdicred:"informix".sd_maecred 
					WHERE empresa = pEmpresa 
					AND num_credito = cNumCredito;
				ELSE
					LET cCodRet = "00545";
					RETURN cCodRet, '', '', '', '', '', '', '','','';
				END IF;
			ELSE
				LET cNumCte = pNumeroCte;

				SELECT num_credito 
				INTO cNumCredito 
				FROM bdicred:"informix".sd_maecred 
				WHERE empresa = pEmpresa 
				AND numcte = cNumCte;
			END IF;
		END IF;

		IF cNumCte <> "" THEN
			SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno 
			INTO cNumCte2, cNombre1, cNombre2, cApell_Paterno, cApell_Materno
			FROM  bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = cNumCte;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN                                                                                              
				LET cCodRet = "00154";
				RETURN cCodRet, '', '', '', '', '', '', '','','';
			END IF;

			-- OBTENER LOS DATOS DEL FIRMANTE

				SELECT  sd_tar.secuencia, sd_mae.num_producto, sd_tar.tipo_tarjeta,sd_tar.status_tar
				INTO cSecuencia, cProductoCredito, cTipoTarjeta, cStatusTarj
				FROM
					bdicred:"informix".sd_tarjeta AS sd_tar,
					bdicred:"informix".sd_maecred AS sd_mae
				WHERE
					sd_tar.empresa =  pEmpresa AND
					sd_tar.num_credito = cNumCredito AND
					sd_tar.numcte = cNumCte2 AND
					sd_mae.num_credito  = sd_tar.num_credito AND
					sd_tar.secuencia = (SELECT MAX(sd_tar.secuencia) 
										FROM bdicred:"informix".sd_tarjeta AS sd_tar 
										WHERE sd_tar.empresa = pEmpresa 
										AND sd_tar.num_credito = cNumCredito
										AND sd_tar.numcte = cNumCte);
										 
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN                                                                                              
					LET cCodRet = "00000";
					RETURN cCodRet,cNumCte2,cNombre1, cNombre2,cApell_Paterno,cApell_Materno,cNumCredito,cProductoCredito,cTipoTarjeta,cStatusTarj;
				END IF;						 

				IF cTipoTarjeta = "T" THEN
					IF cNumCte2 <> cNumCte THEN
						IF pNumeroCte <> "" THEN
							LET cCodRet  		 = "00134"; -- cliente consultado no es titular
						ELIF pNumeroTarjeta <> "" THEN
							LET cCodRet  		 = "00524"; -- Tarjeta consultada no es titular
						END IF;
						LET cNumCte2         = "";
						LET cNombre1         = "";
						LET cNombre2         = "";
						LET cApell_Paterno   = "";
						LET cApell_Materno   = "";
						LET cProductoCredito = "";
						LET cTipoTarjeta     = "";
						LET cStatusTarj      = "";
						LET cNumCredito      = "";
					ELSE
						IF cStatusTarj = "A" THEN
							LET cCodRet  = "00000"; -- CLiente consultado es titular y la tarjeta es Activa
						ELSE
							LET cCodRet  		 = "00396"; -- cliente con tarjeta cancelada
							LET cNumCte2  		 = "";
							LET cNombre1 		 = "";
							LET cNombre2 		 = "";
							LET cApell_Paterno   = "";
							LET cApell_Materno   = "";
							LET cProductoCredito = "";
							LET cTipoTarjeta 	 = "";
							LET cStatusTarj 	 = "";
							LET cNumCredito 	 = "";
						END IF;
					END IF;
				ELSE
					IF pNumeroCte <> "" THEN
						LET cCodRet  		 = "00134"; -- cliente consultado no es titular
					ELIF pNumeroTarjeta <> "" THEN
						LET cCodRet  		 = "00524"; -- Tarjeta consultada no es titular
					END IF;
					
					LET cNumCte2  		 = "";
					LET cNombre1 		 = "";
					LET cNombre2 		 = "";
					LET cApell_Paterno   = "";
					LET cApell_Materno   = "";
					LET cProductoCredito = "";
					LET cTipoTarjeta 	 = "";
					LET cStatusTarj 	 = "";
				END IF;
			RETURN cCodRet,cNumCte2,cNombre1, cNombre2,cApell_Paterno,cApell_Materno,cNumCredito,cProductoCredito,cTipoTarjeta,cStatusTarj;
		END IF;
	END

END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la consulta del titular del crédito',
'AUTOR : Martin Miranda',
'FECHA : 27/Octubre/2011',
'MODIFICÓ: Martha Aguirre',
'DESCRIPCIÓN: Se modifica para filtrar la búsqueda en la tabla sd_tarjeta',
'             para que traiga solamente las tarjetas con estatus = "A"',
'FECHA:  11/Junio/2012',
'BD    : BDICRED',
'MODIFICÓ    : Martín Miranda',
'FECHA       : 25/Julio/2012',
'DESCRIPCIÓN : -- Se modifica procedimiento almacenado para que obtenga el número de Cliente cuando se realiza',
'                  consulta por No. de Tarjeta',
'              -- Se separa la consulta de los datos del cliente',
'BD    : BDICRED',
'                                                                                                                ',
'MODIFICÓ    : Martín Miranda',
'FECHA       : 18/Septiembre/2012',
'DESCRIPCIÓN : -- Se modifica procedimiento almacenado para validar cuando se ingrese una tarjeta "Adicional"',
'              -- Se moficica consulta por número de cliente, para validar que el cliente exista en la tabla intercard:tarjeta',
'			   -- Se ingresa nuevo codigo de retorno para cuando se haga consulta por Número de Cliente y este no sea el Titular del Crédito.',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_grupo_a(pempresa CHAR(3), pfechacorte DATE)
RETURNING CHAR(6);
--Creado por: Francisco Martinez Viveros
-- 28/Agosto/2012
-- Modificado por: Francisco Martinez Viveros
-- 27/Noviembre/2012  
-- Ultim.Modificacion de Optimizacion con tablas temporales 
--31/Diciembre/2012
--Proceso para la generación del reporte del grupo6 o grupo A


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(11104);
DEFINE cSQL_cero            CHAR(4500); --FMV 4ene2013 Se adicionan tablas temporales a la sesion
DEFINE cSQL1                CHAR(2500);
DEFINE cSQL2                CHAR(4004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE iParamNombreArch     INTEGER;


--SET DEBUG FILE TO "/tmp/sp_reporte_grupo_a.out";
--TRACE ON;

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_retIB              = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0018';
LET cruta                   = "";
LET cnombre					= "Grupo_A";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL_cero                   = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_retIB;
        RETURN cCod_ret;
    END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '01')
    Returning cCod_retIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = ""  THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
        INTO cMensaje
        FROM bdicobranza:"informix".cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
    SELECT empresa
	INTO cempresa
	FROM bdinteg:si_empresas
	WHERE empresa = pempresa;

    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener caracter delimitador
    SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 2;

	--Valida que exista el caracter
    IF NVL(cdelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor)
        INTO cruta
        FROM bdicred:sd_param
        WHERE empresa = pempresa
        AND cod_param = '033';
        
    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '02')
        Returning cCod_retIB;
        Return cCod_Ret;
	END IF;



    LET cFechaGenArchivo =  to_char(pfechacorte,'%d%m%Y');
    LET cFechaCorte = pfechacorte;

	--Validar que existe el archivo	

	LET cnomarchivo1 =  trim(cnombre)||cFechaGenArchivo||'A.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_GenArchgrupoA' || '.sql';


   --FMV 31dic2012: Creacion de las tablas temporales para optimizacion descarga de datos

                --Tabla 1 de 6  sd_grupo_cliente 
    LET cSQL_cero = ' echo  " SET ISOLATION TO DIRTY READ; '
                 || " SELECT empresa, numcte "
                 || " FROM bdicred:sd_grupo_cliente "                 
                 || " INTO temp CteGpoA WITH NO LOG; "
                 || " CREATE INDEX ix_CteGpoA ON CteGpoA (empresa, numcte); "
                 || " UPDATE STATISTICS MEDIUM FOR TABLE CteGpoA; "

                --Tabla 2 de 6  sd_grupo_credito 
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT crd.empresa , crd.numcte, crd.num_credito, crd.num_historia_efic "
                || "  FROM bdicred:sd_grupo_credito crd, CteGpoA "
                || " WHERE crd.empresa = CteGpoA.empresa "
                || "   AND crd.numcte = CteGpoA.numcte "
                || "   AND crd.num_producto = '6001' "
                || "   INTO temp CredGpoA WITH NO LOG; "
                || " CREATE INDEX ix_CredGpoA ON CredGpoA (empresa, numcte, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE CredGpoA; "

                --Tabla 3 de 6  sd_maecred 
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT cr.empresa, cr.numcte, cr.num_credito, cr.fecha_apertura, cr.sucursal "
                || "  FROM CredGpoA cte, bdicred:sd_maecred cr "
                || " WHERE cte.empresa = cr.empresa "
                || "   AND cte.numcte = cr.numcte "  
                || "  INTO temp CreditosA WITH NO LOG; "
                || " CREATE INDEX ix_CreditosA ON CreditosA (empresa, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE CreditosA; "

                --Tabla 4 de 6   sd_movhis
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT movh.empresa, movh.num_credito, movh.fecha_mov, movh.codigo_fun, "
                || "       movh.codigo_ref, movh.reversado, movh.monto "
                || "  FROM CreditosA crda, bdicred:sd_movhis movh "
                || " WHERE movh.empresa = crda.empresa "
                || "   AND movh.num_credito = crda.num_credito "
                || "   AND movh.codigo_fun = '001' "
                || "   AND movh.codigo_ref = 1 "
                || "   AND movh.fecha_mov < today "
                || "   AND movh.reversado = 'N' "
                || "  INTO temp movtos_hisA WITH NO LOG; "
                || " CREATE INDEX ix_movtos_hisA ON movtos_hisA (empresa, num_credito); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE movtos_hisA; "

                --Tabla 5 de 6  ss_resum_scor_fin
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT fin.empresa, fin.evalua_cc, fin.num_solicitud "
                || "  FROM CreditosA cr, bdisolic:ss_resum_scor_fin fin "
                || " WHERE cr.num_credito = fin.num_solicitud "
                || "  INTO temp ResumScor WITH NO LOG; "
                || " CREATE INDEX ix_ResumScor ON ResumScor (num_solicitud); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE ResumScor; "

                --Tabla 5 de 6  sd_bitacora_aumlincred
                || " SET ISOLATION TO DIRTY READ; "
                || " SELECT aum.* "
                || "  FROM CreditosA cr, bdicred:sd_bitacora_aumlincred aum "
                || " WHERE cr.num_credito = aum.num_solicitud "
                || "  INTO temp Aumento WITH NO LOG; "
                || " CREATE INDEX ix_Aumento ON Aumento (num_solicitud); "
                || " UPDATE STATISTICS MEDIUM FOR TABLE Aumento; ";

    LET cSQL1 = ' SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)||'';
                      
  

        LET cSQL2 = " SELECT a.numcte, b.num_credito, b.fecha_apertura , f.fecha_insert as FofertaIncre , f.fecha_status as FAcepta , "
               || " ema.correo_elec, tca.telefono, tcl.telefono, tra.telefono, tra.extension, "
               || " a.num_historia_efic as meses_vigentes, b.sucursal, mov.monto as monto_otorgado, "
               || " f.lincred_actual, f.lincred_sugerida, h.evalua_cc "
               || " FROM   CredGpoA a, movtos_hisA mov, "
               || "        ResumScor h , "               
               || "        CreditosA b "
               || " LEFT JOIN bdinteg:si_telefonos tca on (b.numcte = tca.numcte AND tca.tipo_tel = 1 AND tca.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tcl on (b.numcte = tcl.numcte AND tcl.tipo_tel = 2 AND tcl.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tra on (b.numcte = tra.numcte AND tra.tipo_tel = 3 AND tra.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN Aumento f on (b.num_credito = f.num_solicitud ) "
               || " LEFT JOIN bdinteg:si_correos ema on ( ema.numcte = b.numcte ) "
               || " WHERE a.empresa = '001' "
               || " AND a.empresa = b.empresa "
               || " AND a.numcte = b.numcte "
               || " AND a.num_credito = b.num_credito "
               || " AND a.num_credito = h.num_solicitud "           
               || " AND a.empresa = mov.empresa "
               || " AND a.num_credito = mov.num_credito "

               || "  union all "

               || " SELECT a.numcte, b.num_credito, b.fecha_apertura , date(1) as FofertaIncre , date(1) as FAcepta , "
               || " ema.correo_elec, tca.telefono, tcl.telefono, tra.telefono, tra.extension, "
               || " a.num_historia_efic as meses_vigentes, b.sucursal, sdo.monto_otorgado,  "
               || " 0 AS lincred_actual, 0 AS lincred_sugerida, h.evalua_cc "
               || " FROM bdicred:sd_grupo_credito a, bdicred:sd_maesdoscrd sdo, bdisolic:ss_resum_scor_fin h , bdicred:sd_maecredcrd b "
               || " LEFT JOIN bdinteg:si_telefonos tca on (b.numcte = tca.numcte AND tca.tipo_tel = 1 AND tca.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tcl on (b.numcte = tcl.numcte AND tcl.tipo_tel = 2 AND tcl.status_tel ='A' AND tca.cofetel='V' ) "
               || " LEFT JOIN bdinteg:si_telefonos tra on (b.numcte = tra.numcte AND tra.tipo_tel = 3 AND tra.status_tel ='A' AND tca.cofetel='V' ) "               
               || " LEFT JOIN bdinteg:si_correos ema on ( ema.numcte = b.numcte ) "
               || " WHERE a.empresa = '001' "
               || " AND a.empresa = b.empresa "
               || " AND a.numcte = b.numcte "               
               || " AND a.num_credito = b.num_credito "               
               || " AND a.num_credito = h.num_solicitud "
               || " AND a.empresa = sdo.empresa "
               || " AND a.num_credito = sdo.num_credito; ";



    LET cSQL3 = '" >'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = cSQL_cero || trim(cSQL1) || (cSQL2) || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoEjecSql;
	SYSTEM cSQL;

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, vproceso, cCod_ret, cMensaje, '03')
            Returning cCod_retIB;
	
    RETURN cCod_ret;

END;
END PROCEDURE;