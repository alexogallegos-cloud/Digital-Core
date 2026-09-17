CREATE PROCEDURE "informix".sp_registracitatramite(pSucursal CHAR(4), pNumcte CHAR(10),pNum_cuenta CHAR(20), 
pNombre_cte CHAR(50), pFecha_cita CHAR(10), pHora_cita CHAR(8), pEmpleado CHAR(8), pTramite CHAR(50), pNumCelular CHAR(10),pSecuencia CHAR(11), pOpcion CHAR(1))

RETURNING CHAR(5) AS cCodigoRet;

--Definicion
DEFINE cCodigoRet CHAR(5);
DEFINE iSqlErr  INTEGER;
DEFINE bBanderaCofetel BOOLEAN;

--AsignaciÃ³n
LET cCodigoRet = '00000';
LET iSqlErr = 0;
LET bBanderaCofetel = 'F';

BEGIN 	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			  LET cCodigoRet = iSqlErr;
		RETURN cCodigoRet;
		END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO '/home/sysifx/Bryan/255/sp_registracitatramite.out'; --- MODIFICAR RUTA DEL ARCHIVO
		--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
			
	SELECT DISTINCT b.bandera
	INTO bBanderaCofetel
	FROM bdinteg:"informix".si_telefonos a,
		bdinteg:"informix".si_bitsmstels b
	WHERE a.numcte = pNumcte
	AND a.numcte = b.numcte
	AND a.telefono = pNumCelular
	AND a.telefono = b.telefono
	AND b.bandera = 'T';
	
	IF pOpcion = '1' THEN --INSERTA EL REGISTRO DE AGENDAR LA CITA
		IF Trim(pSucursal) = '' OR Trim(pNumcte) = '' OR Trim(pNum_cuenta) = '' OR Trim(pNombre_cte) = '' OR Trim(pFecha_cita) = '' OR Trim(pHora_cita) = '' OR Trim(pEmpleado) = '' OR Trim(pTramite) = '' THEN
			LET cCodigoRet = '00001';
		ELSE								
			INSERT INTO bdicheq:"informix".sc_citasagendadas (sucursal,numcte,num_cuenta,nombre_cte,status,fecha_cita,hora_cita,fecha_registro,empleado,tramite,observaciones) 
			VALUES (pSucursal,pNumcte,pNum_cuenta,pNombre_cte,4, pFecha_cita, pHora_cita,CURRENT,pEmpleado,pTramite,'');
			
			IF bBanderaCofetel = 'T' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CIT_PRO_CA','AGEN_CIT','000000000','','','1',pFecha_cita,pHora_cita,'','','','','','','','','',pNumCelular,1,0,0,0,0,'','')
				INTO cCodigoRet;
			END IF;		
		END IF;	
	ELIF pOpcion = '2' THEN --ACTUALIZA EL REGISTRO PARA REAGENDAR LA CITA
		IF Trim(pSucursal) = '' OR Trim(pNumcte) = '' OR Trim(pNum_cuenta) = '' OR Trim(pNombre_cte) = '' OR Trim(pFecha_cita) = '' OR Trim(pHora_cita) = '' OR Trim(pEmpleado) = '' OR Trim(pTramite) = '' THEN
			LET cCodigoRet = '00001';
		ELSE					
			UPDATE bdicheq:"informix".sc_citasagendadas 
			SET  fecha_cita = pFecha_cita, hora_cita = pHora_cita, fecha_registro = CURRENT, empleado = pEmpleado, tramite = pTramite, observaciones = '' 
			WHERE numcte = pNumcte
			AND num_cuenta = pNum_cuenta 
			AND sucursal = pSucursal
			AND secuencia = pSecuencia; 
			
			IF bBanderaCofetel = 'T' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CIT_PRO_CA','REAGEN_CIT','000000000','','','1',pFecha_cita,pHora_cita,'','','','','','','','','',pNumCelular,1,0,0,0,0,'','')
				INTO cCodigoRet;
			END IF;			
		END IF;
	END IF;
	RETURN cCodigoRet;
END
END PROCEDURE
DOCUMENT
'Folio: 255.1 - RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de Nomina en Sucursales',
'Autor: Bryan Limon',
'BD: bdicheq / Central',
'Fecha: 21/07/2017',
'Descripcion: se crea procedimiento para registrar y actualizar la solicitud del tramite cita.';

CREATE PROCEDURE "informix".sp_tarjetarelacion_cte(ptarjeta CHAR(20), pCuenta CHAR(11), pCuentaClabe CHAR(18),pProducto CHAR(30), pOpc CHAR(1))
RETURNING CHAR(5) AS cCodigoRet, CHAR(9) AS sNumCte;

--Definicion
DEFINE cCodigoRet 	CHAR(5);
DEFINE iSqlErr  	INTEGER;
DEFINE sNumCte 		CHAR(10);
DEFINE sTipoTarjeta CHAR(1);
DEFINE iStatus_cta  INTEGER;
DEFINE cRotornoSP	CHAR(5);
DEFINE iRotornoSP	SMALLINT;
DEFINE sEstatusTarjeta CHAR(1);
DEFINE cProdTarjeta    CHAR(4);

--AsignaciÃ³n
LET cCodigoRet = '00000';
LET iSqlErr = 0;
LET sNumCte = "";
LET sTipoTarjeta = "";
LET iStatus_cta = 0;
LET cRotornoSP	= '';
LET iRotornoSP	= 0;
LET sEstatusTarjeta = '';
LET cProdTarjeta = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodigoRet = iSqlErr;
			RETURN cCodigoRet,sNumCte;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Bryan/255/sp_tarjetarelacion_cte.out'; --- MODIFICAR RUTA DEL ARCHIVO
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	IF pOpc = '1' THEN -- NUMERO DE TARJETA
		IF Trim(ptarjeta) = '' THEN
			LET cCodigoRet = '00051';
			RETURN cCodigoRet,sNumCte;
		ELSE
			IF (SELECT count(a.numcte) FROM bdicheq:"informix".sc_tarjeta a,bdicheq:"informix".sc_maechq b
					WHERE num_tarjeta = ptarjeta AND a.cuenta = b.cuenta) > 0 THEN

					SELECT a.numcte,a.tipo_tarjeta,b.status_cta
					INTO sNumCte,sTipoTarjeta,sEstatusTarjeta
					FROM bdicheq:"informix".sc_tarjeta a,
						 bdicheq:"informix".sc_maechq b
					WHERE a.cuenta = b.cuenta
					AND num_tarjeta = ptarjeta
					AND b.status_cta = '1';

					IF TRIM(sTipoTarjeta) = 'A' THEN
						LET cCodigoRet = '00052';
						RETURN cCodigoRet,sNumCte;
					ELIF TRIM(sEstatusTarjeta) <> '1' THEN
						--Numero de tarjeta invalida o cuenta inactiva
						LET cCodigoRet = '00045';
						RETURN cCodigoRet,sNumCte;
					END IF;
			ELSE

					SELECT prodtarjeta
					INTO cProdTarjeta
					FROM bdicheq:"informix".sc_tarjeta
					WHERE num_tarjeta = ptarjeta;

					IF TRIM(pProducto) <> TRIM(cProdTarjeta) THEN
						IF NVL(sNumCte,'') = '' THEN
						--Numero de tarjeta invalida o cuenta inactiva
							LET cCodigoRet = '00045';
							RETURN cCodigoRet,sNumCte;
						END IF;
					ELIF TRIM(pProducto) = TRIM(cProdTarjeta) THEN
							LET cCodigoRet = '00858'; --El producto al cual pertenece la tarjeta es invalido,verifique"
							RETURN cCodigoRet,sNumCte;
					ELSE
						IF(SELECT count(numcte) FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = ptarjeta) > 0 THEN
							SELECT numcte INTO sNumCte FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = ptarjeta;
							LET cCodigoRet = '00000';
							RETURN cCodigoRet,sNumCte;
						ELSE
							LET cCodigoRet = '00047'; --Numero de tarjeta no existe.
							RETURN cCodigoRet,sNumCte;
						END IF;
					END IF;
			END IF
			RETURN cCodigoRet,sNumCte;
		END IF;
	ELIF pOpc = '2' THEN --NUMERO DE CUENTA
		IF Trim(pCuenta) = '' THEN
			LET cCodigoRet = '00051';
			RETURN cCodigoRet,sNumCte;
		ELSE
			IF (SELECT count(num_cte) FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta )> 0 THEN

				SELECT num_cte
				INTO sNumCte
				FROM bdicheq:"informix".sc_maechq
				WHERE cuenta = pCuenta
				AND status_cta = '1';

				IF NVL(sNumCte,'') = '' THEN
					--Numero de cuenta cancelada
					LET cCodigoRet = '00048';
					RETURN cCodigoRet,sNumCte;
				ELSE
					RETURN cCodigoRet,sNumCte;
				END IF;
			ELSE
				LET cCodigoRet = '00050'; --Numero de cuenta no existe, verifique
				RETURN cCodigoRet,sNumCte;
			END IF;
		END IF;

	ELIF pOpc = '3' THEN --CUENTA CLABE
		IF Trim(pCuentaClabe) = '' THEN
			LET cCodigoRet = '00051';
			RETURN cCodigoRet,sNumCte;
		ELSE
			EXECUTE PROCEDURE bdispei:"informix".sp_validadv(pCuentaClabe)
			INTO cRotornoSP, iRotornoSP;

			IF TRIM(NVL(cRotornoSP,'')) = '0' AND NVL(iRotornoSP,-1) = 1 THEN

				IF (SELECT count(num_cte) FROM bdicheq:"informix".sc_maechq WHERE cuenta_clabe = pCuentaClabe )> 0 THEN
					SELECT num_cte,status_cta
					INTO sNumCte , iStatus_cta
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta_clabe = pCuentaClabe;

					IF iStatus_cta = 0 THEN
						LET cCodigoRet = '01284'; --Numero de cuenta CLABE inactiva, verifique
						RETURN cCodigoRet,sNumCte;
					ELSE
						LET cCodigoRet = '00000';
						RETURN cCodigoRet,sNumCte;
					END IF;
				ELSE
					LET cCodigoRet = '00047';
					RETURN cCodigoRet,sNumCte;
				END IF;
			ELSE
				LET cCodigoRet = '01283'; --La cuenta CLABE es incorrecta; ultimo numero(dÃ­gito verificador) invalido.
				RETURN cCodigoRet,sNumCte;
			END IF;
		END IF;
	END IF;
END
END PROCEDURE
DOCUMENT
'Folio: 255.1 - RQM 10 610-4 Incluir cambios finales al servicio de Portabilidad de Nomina en Sucursales',
'Autor: Bryan Limon',
'BD: bdicheq / Central',
'Fecha: 20/07/2017',
'Descripcion: se crea procedimiento para consultar relacion de tarjeta de nomica y cliente.';

CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_cuenta( pEmpresa CHAR(3), pCuenta CHAR(20), pFechaFin DATE, pFechaEmision DATE, pTipo SMALLINT )
RETURNING CHAR(5), CHAR(5), CHAR(80);
    
    DEFINE vcodret                  CHAR(5);
    DEFINE vcodret2                 CHAR(5);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vNombre_cte              CHAR(150);
    DEFINE vCP                      CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    DEFINE vRFC_Cliente             CHAR(13);
    DEFINE vSucursal_num            CHAR(4);
    DEFINE vdescripcion             CHAR(180);
    DEFINE vDireccion_cte           CHAR(200);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vClabe                   CHAR(60);
    DEFINE vCurp                    CHAR(60);
    DEFINE vcortSig                 CHAR(255);
    DEFINE vDireccion_col           CHAR(120);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vcuenta                  CHAR(20);
    DEFINE vNum_cte                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
    DEFINE bInicia                  BOOLEAN;
    DEFINE viDias                   SMALLINT;
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    DEFINE vSaldoCorte              DECIMAL(18,2);
    DEFINE vSaldoPromedio           DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    DEFINE vSaldoAnterior           DECIMAL(18,2);
    DEFINE vDepositos               DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
    DEFINE vRetiros                 DECIMAL(18,2);
    DEFINE vOtrosCargos             DECIMAL(18,2);
    DEFINE vRetencionIsr            DECIMAL(18,2);
    DEFINE vTotRetirosEfec          DECIMAL(18,2);
    DEFINE vTotOtrosCargos          DECIMAL(18,2);
    DEFINE vcortSig2                INTEGER;
    DEFINE vsecuencia               INTEGER;
    DEFINE vnlinea                  INTEGER;
    DEFINE vidreg                   INTEGER;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    DEFINE vFechaAltaEnc            DATE;
    DEFINE vFechaInicio             DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
	DEFINE vestado 			        CHAR(4); 
	DEFINE vciudad 			        VARCHAR(60);  
	DEFINE vtelefono 		        CHAR(14);
	DEFINE vgerente 		        CHAR(40);
	DEFINE cNumProducto		        CHAR(4);
	DEFINE vGATReal                 DECIMAL(9,6);
	DEFINE vcorreo	                CHAR(100);
    DEFINE vEnvioMovtos             SMALLINT;
	
	
		---NUEVAS VARIABLES
	DEFINE vConfirmacion            CHAR(5);
	DEFINE vValor_tasa              DECIMAL(9, 6);
    DEFINE vValor_tasa_isr          DECIMAL(9, 6); 
	DEFINE vBaseisr                 MONEY (16,2);
	DEFINE vanio 					INTEGER;
	DEFINE vresiduo				    INTEGER;
	DEFINE vaniobase                INTEGER;
	DEFINE vbase_exenta             MONEY (16,2);
	DEFINE v_descuento              MONEY (16,2);
	DEFINE v_Subtotal				MONEY (16,2);
	DEFINE v_Total					MONEY (16,2);
	DEFINE v_secuencia              INTEGER;
	DEFINE v_tasa_isr               MONEY (16,2);
	DEFINE vtpo_persona             CHAR(2); 
	DEFINE ves_fisica               CHAR(1);
	DEFINE vexento_isr              CHAR(1); 
	DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
    DEFINE vfecha_hoy               DATE;
	DEFINE vfecha_ant               DATE;
	DEFINE v_Isr_valida             DECIMAL(18,2);
	DEFINE vSdoMesAnt               MONEY;
	DEFINE vTotRetiros              MONEY;
	DEFINE vTotDepositos            MONEY;
	DEFINE vSdoActual               MONEY;
	
	
	    
    LET vaniomes = "";                              
    LET vcodretDet = "";                        
    LET vcodretEnC = "";                          
    LET cErrorInfo="";                     
    LET vcodret = '000';
    LET vcodret2 = '000';
    LET vErrorInfo = 'PROCESO EXITOSO';
    LET vcortSig2 = 0;                              
    LET vcortSig = "";                          
    LET vsecuencia = 0;
    LET vnlinea =0;                                 
    LET vidreg = 0;                                               
    LET vsqlerr = 0;   
    LET visamerr = 0;    
    LET vdeposito = 0;
    LET vretiro = 0;                                
    LET vfechealt = "";                         
    LET vsdocuenta = 0;
    LET vdescripcion = "";                                                   
    LET vcuenta = "";                                                                                                                                                     
    LET bInicia = "F";                          
    LET vFecha_emision = "01-01-1900";              
    LET vNum_cte = "";                          
    LET vNum_Tarjeta = "";
    LET vNombre_cte = "";                           
    LET vDireccion_cte = "";                    
    LET vDireccion_col = "";
    LET vDireccion_del = "";                        
    LET vEdo_cd = "";                           
    LET vSucursal_nombre = "";                      
    LET vSucursal_num  = "";                    
    LET vRFC_Cliente = "";
    LET vCP = "";                                   
    LET vClabe = "";
    LET vCurp = "";                                                         
    LET vFechaInicio = "";                     
    LET vSaldoAnterior = 0;
    LET vDepositos = 0;                             
    LET vInteresesPagados = 0;                  
    LET vRetiros = 0;
    LET vOtrosCargos = 0;                           
    LET vIvaOtrosCargos = 0;                    
    LET vSaldoCorte = 0;
    LET vSaldoPromedio = 0;                         
    LET vRetencionIsr = 0;    
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;
    LET viDias = 0;                                 
    LET vTasaBruta = 0;     
    LET vGAT = 0;    
    LET vfechaFinal = "";                                  
    LET dFechaInicioMovimientos = '01-01-1900';     
    LET dFechaFinMovimientos = '01-01-1900';    
    LET vMensajeProducto = '';
    LET vPiePagina = "";
	LET vestado = ''; 
	LET vciudad = '';
	LET vtelefono = '';
	LET vgerente = '';
	LET cNumProducto = '';
	LET vGATReal = 0.0;
	LET vcorreo = "";
    LET vEnvioMovtos = 0;
	
	
		---NUEVAS VARIABLES
	LET vConfirmacion =  " ";
	LET vValor_tasa   =  0;
	LET vBaseisr      =  0.0;
	LET vaniobase     =  365;
	LET v_descuento   =  0.00;
	LET v_Subtotal    =  0.00;
	LET v_Total	      =  0.00;
	LET vfecha_hoy    = ""; 
	LET vfecha_ant    = ""; 
	LET vSdoMesAnt    = 0;
	LET vTotRetiros   = 0;
	LET vTotDepositos = 0;
	LET vSdoActual    = 0;
	

     --SET DEBUG FILE TO "/informix/rsv/edo_cuenta_05032018/pru.out";
     --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/tmp/sp_generaredoctaeje_factelect_cuenta.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vErrorInfo = cErrorInfo;
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pEmpresa is null OR pFechaFin is null OR pCuenta is null THEN
        LET vcodret = '110';
        LET vcodret2 = '110';
        LET vErrorInfo = 'DATOS INSUFICIENTES';
        RETURN vcodret, vcodret2, vErrorInfo;
    END IF; 
	
	-- SE OBTIENE EL MONTO EXENTO
	  SELECT valor::INT
	    INTO vbase_exenta 
        FROM sc_param
       WHERE empresa = '001'
         AND codparam ='baseexenta';

		 
	  SELECT fecha_hoy,fecha_ant 
        INTO vfecha_hoy,vfecha_ant 
        FROM sc_fechas
       WHERE empresa = pEmpresa; 
		 
	  
	  -- // CALCULA EL ANIO BASE 
	  
	  LET vanio    = YEAR(vfecha_hoy);
      LET vresiduo =  MOD(vanio, 4);
	  
      IF vresiduo  = 0 THEN 
         LET vaniobase = 366;
      END IF;
	  
		
      --SE OBTIENE EL ANIO MES 		
	  LET v_secuencia  =  year(vfecha_ant)||lpad(month(vfecha_ant),2,"0");
	
	
    
    -- // Obtener las cuentas 
    FOREACH WITH HOLD 
        SELECT mae.aniomes, mae.cuenta, mae.fechaini, mae.fechafin, mae.sdo_mes_ant, mae.totretiros,mae.totdepositos, mae.sdo_actual
          INTO vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros,vTotDepositos,vSdoActual
          FROM sc_maehis AS mae
         WHERE mae.aniomes is not null
           AND mae.cuenta = pCuenta
           AND mae.fechaini < pFechaFin
           AND mae.fechafin = pFechaFin
           AND mae.producto NOT IN('9901')
                
        BEGIN WORK;
        LET bInicia = "T";
        
        -- // Ejecutar el store para llenar el encabezado
        IF pTipo = 1 THEN
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta_factelect;
        ELIF pTIpo = 2 THEN
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta_factelect_old;
        END IF;
        
        EXECUTE PROCEDURE sp_generaredoctaejeencabezado_factelect(pEmpresa, vcuenta, vaniomes)
        INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, 
             vSucursal_nombre, vRFC_Cliente, vCP, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vfechaFinal, vSucursal_num, vSaldoAnterior, 
             vDepositos, vInteresesPagados, vRetiros, vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, 
             vInteresesNetos, viDias, vTasaBruta, vTotRetirosEfec, vTotOtrosCargos, vGAT, vMensajeProducto, vPiePagina,
			 vestado,vciudad, vtelefono, vgerente, cNumProducto, vGATReal, vEnvioMovtos;
        
        -- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
        IF trim(vcodretEnc) = '000' THEN 
        
            IF pTipo = 1 THEN
				IF vEnvioMovtos = 1 THEN
					SELECT correo_elec 
					  INTO vcorreo
					  FROM bdinteg:si_correos 
					 WHERE numcte = vNum_cte 
					   AND status_correo = 'A' 
					   AND tipo_correo = 1 
					   AND valido = 1
					   AND secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = vNum_cte AND status_correo = 'A' AND tipo_correo = 1 AND valido = 1 );
				ELSE
					LET vcorreo = '';
				END IF;
		      
			  IF vRetencionIsr > 0 THEN
			
			   --OBTIENE LA TASA-ISR
                SELECT first 1 tasa_isr
                  INTO v_tasa_isr
                  FROM sc_isr  
                 WHERE cuenta    = vcuenta
                   AND secuencia = v_secuencia
                   AND tasa_isr > 0;
				   
				   
				   IF v_tasa_isr IS NULL  THEN 
			           LET v_tasa_isr = 0;
			       END IF;
                   
                --TASA ISR 			
                LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  viDias) / vaniobase,6 ); 
			
		
                SELECT tpo_persona
                  INTO vtpo_persona
                  FROM bdinteg:si_cliente
                 WHERE numcte = vNum_cte;

                SELECT es_fisica, exento_isr
                  INTO ves_fisica, vexento_isr
                  FROM bdinteg:si_tipper
                 WHERE tpo_persona = vtpo_persona;

                IF vexento_isr = 'N' THEN
                   IF ves_fisica = 'S' THEN
				      IF  vSaldoPromedio > vbase_exenta THEN 
			              LET vBaseisr = vSaldoPromedio - vbase_exenta;
					      LET vValor_tasa_isr = vValor_tasa;
				      ELSE
                          LET vBaseisr = 0;
                          LET vValor_tasa_isr = 0.0;
					  END IF;
                   ELSE
				   	  LET vBaseisr = vSaldoPromedio;
					  LET vValor_tasa_isr = vValor_tasa;
				   END IF;
				ELSE   
                    LET vBaseisr = 0;
                    LET vValor_tasa_isr = 0.0;
                END IF;					
			ELSE  	  
			    LET vBaseisr = 0.0; 
                LET vValor_tasa_isr = 0.0;
			END IF;  

				
			-- INICIALIZAMOS LA VARIABLE v_descuento
			LET v_descuento = 0.0;	
			
				
			IF vIvaOtrosCargos = 0 AND vRetencionIsr > 0 THEN 
			   LET v_descuento = 0.00;
			END IF;  
			
			
			IF vOtrosCargos = 0 AND vIvaOtrosCargos = 0 AND vRetencionIsr = 0 THEN 
			   LET v_descuento = 0.01;
			END IF; 
			
			
			IF vIvaOtrosCargos > 0 AND vRetencionIsr > 0 THEN  
			   LET v_descuento = 0.00;
			END IF; 
			
			
			IF vIvaOtrosCargos > 0 AND vRetencionIsr =  0 THEN  
			   LET v_descuento = 0.00;
			END IF; 

			--DETERMINA EL TOTAL
			LET v_Subtotal =  ( vOtrosCargos + v_descuento + vRetencionIsr );
			--DETERMINA EL SUBTOTAL
			LET v_Total    =  ( vOtrosCargos + vIvaOtrosCargos );
			
			--VALIDA EL VALOR DE LAS COMISIONES	
			LET vres_iva_otros_cargos = 0;
			LET vres_iva_otros_cargos = TRUNC((vOtrosCargos * .16 ),2);
			
			IF vres_iva_otros_cargos <> vIvaOtrosCargos THEN 
			   LET vOtrosCargos = TRUNC((vIvaOtrosCargos /.16),2); 
            ELSE 
               LET vOtrosCargos = vOtrosCargos;
            END IF; 	
			
			--VALIDA VALOR DE RETENCION ISR
			LET v_Isr_valida  = 0;
			LET v_Isr_valida  = TRUNC((vBaseisr * vValor_tasa_isr ),2); 
			
			IF v_Isr_valida > 0 THEN 
			   IF v_Isr_valida <> vRetencionIsr THEN 
			      LET  vBaseisr  =  ROUND((vRetencionIsr / vValor_tasa_isr + .01 ),2);
			      LET  vSaldoPromedio = ROUND((vRetencionIsr / vValor_tasa_isr + .01 + vbase_exenta),2);
			   ELSE 
			      LET vBaseisr = vBaseisr; 
			      LET vSaldoPromedio = vSaldoPromedio; 
			   END IF; 
			END IF;
			
			
			--VALIDA LA BASE Y LA TASA
			IF vRetencionIsr > 0 AND vBaseisr = 0  AND vValor_tasa_isr = 0 THEN  
			    SELECT promedio, dia_promedio, promedio - vbase_exenta, TRUNC((((tasa_isr / 100) * dia_promedio) / vaniobase),6)
				  INTO vSaldoPromedio,viDias,vBaseisr,vValor_tasa_isr  
				  FROM sc_isr 
				 WHERE cuenta = vcuenta
				   AND tasa_isr IN (SELECT MAX(tasa_isr)  FROM sc_isr
                                     WHERE cuenta = vcuenta); 
            END IF;	
			
			
                INSERT INTO sc_encabezado_edocta_factelect
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo, confirmacion)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ', 
                 vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente, vcorreo, vConfirmacion);
                
                INSERT INTO sc_encabezado2_edocta_factelect
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
                otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta,baseisr,tasaisr,descuento,subtotal,total)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);
               
			    LET vsecuencia = 1;
                LET vnlinea = 1;
                
                INSERT INTO sc_piepagina_edocta_factelect 
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                
                INSERT INTO sc_mensajes_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automÃ¡tico no aceptes ayuda de nadie.');
                
                INSERT INTO sc_mensajes_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefÃ³nicas, mensajes por telÃ©fono o mensajes en su correo electrÃ³nico en los que se le solicite su nÃºmero de tarjeta de dÃ©bito.');
                
                INSERT INTO sc_mensajes_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de dÃ©bito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                
                INSERT INTO sc_grafica_fe
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
                
				
				INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
                VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);
				
				
				
				
				
            ELIF pTipo = 2 THEN
			
			
			 IF vRetencionIsr > 0 THEN
			
			   --OBTIENE LA TASA-ISR
                SELECT first 1 tasa_isr
                  INTO v_tasa_isr
                  FROM sc_isr  
                 WHERE cuenta    = vcuenta
                   AND secuencia = v_secuencia
                   AND tasa_isr > 0;
				   
				   
				   IF v_tasa_isr IS NULL  THEN 
			           LET v_tasa_isr = 0;
			       END IF;
                   
                --TASA ISR 			
                LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  viDias) / vaniobase,6 ); 
			
		
                SELECT tpo_persona
                  INTO vtpo_persona
                  FROM bdinteg:si_cliente
                 WHERE numcte = vNum_cte;

                SELECT es_fisica, exento_isr
                  INTO ves_fisica, vexento_isr
                  FROM bdinteg:si_tipper
                 WHERE tpo_persona = vtpo_persona;

                IF vexento_isr = 'N' THEN
                   IF ves_fisica = 'S' THEN
				      IF  vSaldoPromedio > vbase_exenta THEN 
			              LET vBaseisr = vSaldoPromedio - vbase_exenta;
					      LET vValor_tasa_isr = vValor_tasa;
				      ELSE
                          LET vBaseisr = 0;
                          LET vValor_tasa_isr = 0.0;
					  END IF;
                   ELSE
				   	  LET vBaseisr = vSaldoPromedio;
					  LET vValor_tasa_isr = vValor_tasa;
				   END IF;
				ELSE   
                    LET vBaseisr = 0;
                    LET vValor_tasa_isr = 0.0;
                END IF;					
			ELSE  	  
			    LET vBaseisr = 0.0; 
                LET vValor_tasa_isr = 0.0;
			END IF;  

				
			-- INICIALIZAMOS LA VARIABLE v_descuento
			LET v_descuento = 0.0;	
			
				
			IF vIvaOtrosCargos = 0 AND vRetencionIsr > 0 THEN 
			   LET v_descuento = 0.00;
			END IF;  
			
			
			IF vOtrosCargos = 0 AND vIvaOtrosCargos = 0 AND vRetencionIsr = 0 THEN 
			   LET v_descuento = 0.01;
			END IF; 
			
			
			IF vIvaOtrosCargos > 0 AND vRetencionIsr > 0 THEN  
			   LET v_descuento = 0.00;
			END IF; 
			
			
			IF vIvaOtrosCargos > 0 AND vRetencionIsr =  0 THEN  
			   LET v_descuento = 0.00;
			END IF; 

			--DETERMINA EL TOTAL
			LET v_Subtotal =  ( vOtrosCargos + v_descuento + vRetencionIsr );
			--DETERMINA EL SUBTOTAL
			LET v_Total    =  ( vOtrosCargos + vIvaOtrosCargos );
			
			--VALIDA EL VALOR DE LAS COMISIONES	
			LET vres_iva_otros_cargos = 0;
			LET vres_iva_otros_cargos = TRUNC((vOtrosCargos * .16 ),2);
			
			IF vres_iva_otros_cargos <> vIvaOtrosCargos THEN 
			   LET vOtrosCargos = TRUNC((vIvaOtrosCargos /.16),2); 
            ELSE 
               LET vOtrosCargos = vOtrosCargos;
            END IF; 

             
			 --VALIDA VALOR DE RETENCION ISR
			LET v_Isr_valida  = 0;
			LET v_Isr_valida  = TRUNC((vBaseisr * vValor_tasa_isr ),2); 
			

			IF v_Isr_valida > 0 THEN 
			   IF v_Isr_valida <> vRetencionIsr THEN 
			      LET  vBaseisr  =  ROUND((vRetencionIsr / vValor_tasa_isr + .01 ),2);
			      LET  vSaldoPromedio = ROUND((vRetencionIsr / vValor_tasa_isr + .01 + vbase_exenta),2);
			   ELSE 
			      LET vBaseisr = vBaseisr; 
			      LET vSaldoPromedio = vSaldoPromedio; 
			   END IF; 
			END IF;
			

			--VALIDA LA BASE Y LA TASA
			IF vRetencionIsr > 0 AND vBaseisr = 0  AND vValor_tasa_isr = 0 THEN  
			    SELECT promedio, dia_promedio, promedio - vbase_exenta, TRUNC((((tasa_isr / 100) * dia_promedio) / vaniobase),6)
				  INTO vSaldoPromedio,viDias,vBaseisr,vValor_tasa_isr  
				  FROM sc_isr 
				 WHERE cuenta = vcuenta
				   AND tasa_isr IN (SELECT MAX(tasa_isr)  FROM sc_isr
                                     WHERE cuenta = vcuenta); 
            END IF;	

            
                INSERT INTO sc_encabezado_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc,correo, confirmacion)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ', 
                 vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente,'',vConfirmacion);
                
                INSERT INTO sc_encabezado2_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta,baseisr,tasaisr,descuento,subtotal,total)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);
                LET vsecuencia = 1;
                LET vnlinea = 1;
                
                INSERT INTO sc_piepagina_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                
                INSERT INTO sc_mensajes_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automÃ¡tico no aceptes ayuda de nadie.');
                
                INSERT INTO sc_mensajes_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefÃ³nicas, mensajes por telÃ©fono o mensajes en su correo electrÃ³nico en los que se le solicite su nÃºmero de tarjeta de dÃ©bito.');
                
                INSERT INTO sc_mensajes_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de dÃ©bito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                
                INSERT INTO sc_grafica_fe_old
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                VALUES
                (vidreg, pFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
            
			    INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
                VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);
			
			
			
			
            END IF;
        ELSE  -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃÂÃÂ³n
            ROLLBACK WORK;
            LET bInicia = "F";
            LET vcodret = '003';
            LET vcodret2 = '003';
            LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
            RETURN vcodret, vcodret2, vErrorInfo;
        END IF;
        
        -- // Ejecutar store para el detalle
        LET vsecuencia = 0;
        
        FOREACH
            EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
            INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
            
            IF trim(vcodretDet) = '000' THEN -- // Si el resultado fue satisfactorio hacer las inserciones para los detalles
                LET vsecuencia = vsecuencia + 1;
                LET vnlinea = 0;
                
                FOREACH  -- // Cortar los detalles en lineas
                    EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
                    INTO vcortSig, vcortsig2

                    LET vnlinea = vnlinea + 1;

                    IF vnlinea > 1 THEN
                        LET vretiro = 0.00;
                        LET vdeposito = 0.00;
                        LET vsdocuenta = 0.00;
                        LET vfechealt = '01-01-1900';
                    END IF;
                    
                    IF pTipo = 2 THEN
                        INSERT INTO bdicheq:sc_detalle_edocta_factelect_old
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                        VALUES
                        (vidreg, pFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuenta);
                    END IF;
                END FOREACH;
            ELSE  -- // Si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃÂÃÂ³n
                IF trim(vcodretDet) <> '002' THEN  -- // Codigo de retorno diferente a 002 (la cuenta no tiene movimientos)
                    ROLLBACK WORK;
                    LET bInicia = "F";
                    LET vcodret = '004';
                    LET vcodret = '004';
                    LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                    RETURN vcodret, vcodret2, vErrorInfo;
                END IF;
            END IF;
        END FOREACH;
        
        COMMIT WORK;
        LET bInicia = "F";        
    END FOREACH;
    
    RETURN vcodret, vcodret2, vErrorInfo;
    
    END;
    
END PROCEDURE;