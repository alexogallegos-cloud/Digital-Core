Create Procedure "informix".sp_nominaconsultasaldoeje
(
pCuenta            Char(20),
pTotalRegistros    Integer,
pImporteTotal      Money(18,2),
pEmpresa           Char(3),
pConcepto          Smallint
)

RETURNING CHAR(5), Integer ;

DEFINE cCodRet                                              CHAR(5);
DEFINE vSqlErr                                                 INTEGER ;
DEFINE mSaldo                                                Money(16,2);
Define mValorIva                                                Money(4,2);
Define mMontoComisionDispercion                     Money(14,2);
Define mTotaliva                                                Money(14,2);
Define mTotalComision                                       Money(14,2);
Define cValorTransComiDisp                              Char(4);    --Aqui se traera el 0394
Define cValorTransIvaDisp                                  Char(4);    --Aqui se traera el 0396
Define cValorTransaccion                                   Char(4);
Define mMontoFijo                                             Money(16,2);
Define cValorTipoTransaccion                             Char(3);
Define siTipoEmpresa                                        Smallint ;
Define bParametroErroneo                                  Boolean  ;
Define iSaldo                                                     Integer ;

LET cCodRet = "000";
LET vSqlErr = 0;
LET mSaldo = 0;
Let mValorIva = 0;
Let mMontoComisionDispercion = 0;
Let mTotaliva = 0;
Let mTotalComision = 0;
Let cValorTransComiDisp = '';
Let cValorTransIvaDisp = '';
Let cValorTransaccion = '';
Let mMontoFijo = 0;
Let cValorTipoTransaccion = '';
Let siTipoEmpresa = 0;
Let bParametroErroneo = "F";
Let iSaldo = 0;

--set debug file to "/tmp/sp_obtieneSaldoCuenta.out";
--Trace on;

BEGIN
        ON EXCEPTION SET vSqlErr
                IF vSqlErr != 0 THEN
                        LET cCodRet = vSqlErr;
                        RETURN cCodRet, mSaldo;
                END IF;
        END EXCEPTION;
		
--VALIDACIONES DE PARAMETROS DE ENTRADA
If (pCuenta = "") Or (pCuenta = " ") Or (pCuenta Is Null) Then
    Let bParametroErroneo = "T";  
Elif (pTotalRegistros = 0) Or (pTotalRegistros = "") Or (pTotalRegistros Is Null) Then
    Let bParametroErroneo = "T";
Elif (pImporteTotal = 0) Or (pImporteTotal = "") Or (pImporteTotal Is Null) Then
    Let bParametroErroneo = "T";
Elif (pEmpresa = '000') Or (pEmpresa = "") Or (pEmpresa Is Null) Then
    Let bParametroErroneo = "T";
Elif (pConcepto = 0) Or (pConcepto = "") Or (pConcepto Is Null) Or (pConcepto = " ") Then
	Let bParametroErroneo = "T";
End If

If bParametroErroneo = "T" Then
     Let cCodRet = '800';
     Let iSaldo = 0;
     Return cCodRet, iSaldo;
End If

        Select tipo_empresa Into siTipoEmpresa From bdicheq:sc_nominaempresas Where codigo = pEmpresa;
        
        If siTipoEmpresa <> 2 Then
			If Exists (Select 1 From bdicheq:sc_maechq Where empresa = '001' And cuenta = pCuenta) Then

				Select sdo_actual Into mSaldo From bdicheq:sc_maechq Where empresa = '001' And  cuenta = pCuenta;
	                        
	                         --CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES Y SE OBTIENEN LOS MONTOS
					ForEach
						Select nomina.tipo_transaccion, nomina.transacc, transacc.monto_fijo Into cValorTipoTransaccion,cValorTransaccion, mMontoFijo
						From bdicheq:sc_nominatransacciones as nomina
						inner join bdinteg:si_transacc as transacc on nomina.transacc = transacc.numero
						Where nomina.tipo_codigo = pConcepto And nomina.tipo_empresa = siTipoEmpresa
						Order By nomina.tipo_transaccion
														  
						If cValorTipoTransaccion = '003' Then
							Let cValorTransComiDisp = cValorTransaccion;   --Aqui me trae el 0394
							Let mMontoComisionDispercion = mMontoFijo;                            
						Elif cValorTipoTransaccion = '005' Then
							Let cValorTransIvaDisp = cValorTransaccion;   --Aqui me trae el 0396                                    
						End If

					End ForEach
										 
					If (cValorTransComiDisp = "") Or (cValorTransComiDisp = " ") Or (cValorTransComiDisp Is Null) Then
						Let cCodRet = '850';   --Dispercion No Ejecutada: El Numero de Transaccion de la ComisiÃ³o es Valido                       
						Return cCodRet, mSaldo;
					Elif (cValorTransIvaDisp = "") Or (cValorTransIvaDisp = " ") Or (cValorTransIvaDisp Is Null) Then
						Let cCodRet = '855';   --Dispercion No Ejecutada: El Numero de Transaccion del Iva No es Valido                           
						Return cCodRet, mSaldo;
					End If

					Select valor 
					  Into mValorIva 
					  From bdinteg:si_param   --Aqui se obtiene el valor del Iva
					 Where cod_param = 47
					   AND empresa = "001";
					   
					If (mValorIva = "") Or (mValorIva = " ") Or (mValorIva Is Null) Then
						Let cCodRet = '855';  --Dispercion No Ejecutada: El Numero de Transaccion del Iva No es Valido
						Let mSaldo = 0;
						Return cCodRet, mSaldo;
					End If

					--Let mTotalComision = pTotalRegistros * mMontoComisionDispercion;
					--Let mTotaliva = pTotalRegistros * mValorIva;
					Let mTotalComision = pTotalRegistros * mMontoComisionDispercion;
					Let mTotaliva = mTotalComision * mValorIva;  --Nueva Forma de Calcular el Iva

				Let mSaldo = mSaldo - (pImporteTotal + mTotalComision + mTotaliva);  --Aqui se suma el total del importe mas los costos de comision y de iva de todos los registros

				If mSaldo < 0 Then
					-- CUENTA CON SALDO INSUFICIENTE
					Let cCodRet = "006";
					Let mSaldo = mSaldo * -1;
	            Elif mSaldo >= 0 Then
					Let mSaldo = 0;    --Aqui se regresa 0, cuando hay saldo suficiente
				End If
			Else
				-- CUENTA NO ENCONTRADA
				Let cCodRet = "005";
			End If

                --se cambia a char por el inet
		Let iSaldo = Cast(round(mSaldo + 0.4) as char(20));

        Elif siTipoEmpresa = 2 Then   
            Let iSaldo = 0;    --Aqui se regresa 0, cuando hay saldo suficiente
        End If

        RETURN cCodRet, iSaldo;
End
End Procedure
DOCUMENT
'Modifico :Armando Mercado',
'DESCRIPCION: Se agrego un parametro mas "Concepto", asi se ya se va a considerar cual es el cobro de comision,',
'dado a que la consulta estaba fija hacia nomina "1"',
'FECHA : Abril de 2009',
'VERSION: 200904',
'BD    : BDICHEQ',
'Modifico :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se modifica la validacion para tipo de empresa externa y del grupo coppel "siTipoEmpresa <> 2" ',
'FECHA : mayo de 2009',
'VERSION: 200905',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_nominaprocesadanoprocesada(pNombreArchivo CHAR(17), pTpoOperacion  CHAR(1))
--valores a regresar
RETURNING   CHAR(5), CHAR(10), CHAR(30), CHAR(20), CHAR(30), CHAR (20), MONEY, CHAR(20), CHAR(4),
            CHAR(4), CHAR (50), CHAR(30),  INTEGER, INTEGER, CHAR(4);


--Declaracion de variables
DEFINE  v_cCodRet        CHAR(5);
DEFINE v_cNumEmp         CHAR(10);
DEFINE v_cApellPaterno   CHAR(30);
DEFINE v_cApellMaterno   CHAR(20);
DEFINE v_cNombres        CHAR(30);
DEFINE v_cCuentaAbono    CHAR(20);
DEFINE v_mImporte        MONEY;
DEFINE v_cConcepto       CHAR(30);
DEFINE v_cStatus         CHAR(1);
DEFINE v_cDescStatus     CHAR(30);
DEFINE v_cNumCte         CHAR(20);
DEFINE  v_cProducto      CHAR(4);
DEFINE v_cTransaccion    CHAR(4);
DEFINE v_cDesTransacc    CHAR(50);
DEFINE v_iPagadas        INTEGER;
DEFINE v_iNoPagadas      INTEGER;
DEFINE v_iSqlErr         INTEGER;
Define cEmpresa          Char(3);
DEFINE v_cSucursal       CHAR(4);
DEFINE cConcepto         CHAR(1);
DEFINE iTipoEmpresa      SMALLINT;
---Inicializacion de variables
LET v_cCodRet = "00000";
LET v_cNumEmp = "";
LET v_cApellPaterno = "";
LET v_cApellMaterno = "";
LET v_cNombres = "";
LET v_cCuentaAbono = "";
LET  v_mImporte  = 0;
LET  v_cConcepto  = "";
LET  v_cStatus  = "";
LET v_cDescStatus = "";
LET v_cNumCte = "";
LET  v_cProducto = "";
LET v_cDesTransacc = "";
LET  v_iPagadas  = 0;
LET v_iNoPagadas = 0;
LET  v_iSqlErr = 0;
Let cEmpresa = '';
LET v_cSucursal='';
LET cConcepto = '';
LET v_cTransaccion='';
LET iTipoEmpresa = 0;

BEGIN
    ON EXCEPTION SET v_iSqlErr
        IF v_iSqlErr <> 0 THEN            
            LET v_cCodRet  = v_iSqlErr;
            RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,  
                    v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
        END IF;
    END EXCEPTION

    --SET DEBUG FILE TO  "/tmp/sp_NominaProcesadaNoProcesada.out";
    --TRACE ON;

    IF pNombreArchivo = "" OR pTpoOperacion = "" THEN
        LET  v_cCodRet  = "00110"; --datos insufucientes
        RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,  
                v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
    END IF;

    --Se obtiene la Empresa Cliente
    SELECT empresa INTO cEmpresa 
    FROM bdicheq:sc_nominaencabezadosumariohist
    WHERE nombre_archivo = pNombreArchivo;
    
    SELECT tipo_empresa into iTipoEmpresa
      FROM bdicheq:sc_nominaempresas
     WHERE codigo = cEmpresa;

   IF pTpoOperacion = '1' THEN --Nominas Procesadas
   
      FOREACH	  
			
			SELECT nommov.num_empleado, nommov.apell_paterno, nommov.apell_materno, nommov.nombres, nommov.cuenta_abono, nommov.importe, 
                   NVL(nom.descripcion, ''), NVL(mae.num_cte, ''), NVL(mae.producto,'0'), NVL(transacc.descripcion, ''),NVL(mae.sucursal,'0'),transacc.numero			  
			INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
                  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion
            FROM bdicheq:sc_nominamovimientoshist nommov,
                Outer bdicheq:sc_nominaestatus nom,
                Outer bdicheq:sc_maechq mae,		
                bdinteg:si_transacc transacc
            WHERE  nom.cod_status  = nommov.status
               AND nommov.cuenta_abono=mae.cuenta            
               AND transacc.numero = ( SELECT transacc FROM bdicheq:sc_nominatransacciones WHERE tipo_transaccion = '001'  --Identificador del Abono
                                                                                            AND tipo_codigo = nommov.concepto  
                                                                                            AND tipo_empresa = iTipoEmpresa )
               AND nom.tpo_status = 2   --Es el status de los movimientos
               AND nommov.status = '1'
               AND nommov.nombre_archivo = pNombreArchivo 
			  			   
            RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,  
                    v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;        
      END FOREACH;

   ELIF pTpoOperacion = '2' THEN --Nominas no procesadas

      FOREACH
			   SELECT nommov.num_empleado, nommov.apell_paterno, nommov.apell_materno, nommov.nombres, nommov.cuenta_abono, nommov.importe, 
                   NVL(nom.descripcion, ''), NVL(mae.num_cte, ''), NVL(mae.producto,'0'), NVL(transacc.descripcion, ''),NVL(mae.sucursal,'0'),transacc.numero	
				INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
                  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion				   
			   FROM bdicheq:sc_nominamovimientoshist nommov,
                Outer bdicheq:sc_nominaestatus nom,
                Outer bdicheq:sc_maechq mae,		
                bdinteg:si_transacc transacc
               WHERE  nom.cod_status  = nommov.status
               AND nommov.cuenta_abono=mae.cuenta            
               AND transacc.numero = ( SELECT transacc FROM bdicheq:sc_nominatransacciones WHERE tipo_transaccion = '001'  --Identificador del Abono
                                                                                            AND tipo_codigo = nommov.concepto  
                                                                                            AND tipo_empresa = iTipoEmpresa )
               AND nom.tpo_status = 2   --Es el status de los movimientos
               AND nommov.status > '1'
               AND nommov.nombre_archivo = pNombreArchivo 

            RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,  
                    v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;
      END FOREACH;

   END IF;
 END;
END PROCEDURE
    DOCUMENT
    'DESCRIPCION: Programa que genera informacion para los reportes de procesados y no procesados',
    'EJECUTADO O LLAMADO POR: Dispersion de Nomina Manual',
    'AUTOR: Armando Mercado Figueroa',
    'FECHA: 00/2008',
    'BD: BDCHEQ',
    'CAMBIOS: Se agrego validacion para tomar transaccion de los diferentes conceptos como: nomina,gastos,fondo,capacitacion',
    'AUTOR: Armando Mercado Figueroa',
    'Fecha: 17/Enero/2009',
	'MODIFICÓ :Maria Elena Angulo Aispuro',
	'DESCRIPCION:  Se reemplazan las consultas a las tablas principales sc_nominamovimientos y sc_nominaencabezadosumario por sus tablas historicas (sc_nominamovimientoshist,sc_nominaencabezadosumario) con el fin de regresar la información de cuentas al reporte de dispersion manual que se encuentran en la historica,',
	'además se agregó una mejora al realizar cambio para que realice con éxito la consulta a un archivo con mas de un concepto diferente ya que este devolvía un error si se presentabá este caso.',
	'FECHA : 24/Enero/2011',
	'BD    : BDICHEQ',
	'VERSION: 20110124.1706';

CREATE PROCEDURE "informix".sp_nominaprocesadanoprocesada_bei(pIdEmp CHAR(3), pFecDisp date,pTipoOpe char(1),psNombreArchivo CHAR(17),pRegistro smallint)
--valores a regresar
RETURNING   CHAR(5), CHAR(10), CHAR(30), CHAR(20), CHAR(30), CHAR (20), MONEY(16,2), CHAR(20), CHAR(4),
            CHAR(4), CHAR (50), CHAR(30),  INTEGER, INTEGER, CHAR(4);


	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene los registros procesados y no procesados de nomina
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdicheq
	-- SOLICITO :Mauricio León
	--
	-- DESCRIPCION:  Se agregó el filtrado por nombre de archivo y orden por numero de empleado
	-- AUTOR : Alfonso Antonio Cruz Alvarez
	-- FECHA : 07/01/2013
	-- BD: bdicheq
	-- SOLICITO :	José de Jesus Nevarez
	--***************************************************************************************************


	--Declaracion de variables
	DEFINE v_cNomArchivo	 CHAR(17);
	DEFINE  v_cCodRet        CHAR(5);
	DEFINE v_cNumEmp         CHAR(10);
	DEFINE v_cApellPaterno   CHAR(30);
	DEFINE v_cApellMaterno   CHAR(20);
	DEFINE v_cNombres        CHAR(30);
	DEFINE v_cCuentaAbono    CHAR(20);
	DEFINE v_mImporte        MONEY;
	DEFINE v_cConcepto       CHAR(30);
	DEFINE v_cStatus         CHAR(1);
	DEFINE v_cDescStatus     CHAR(30);
	DEFINE v_cNumCte         CHAR(20);
	DEFINE  v_cProducto      CHAR(4);
	DEFINE v_cTransaccion    CHAR(4);
	DEFINE v_cDesTransacc    CHAR(50);
	DEFINE v_iPagadas        INTEGER;
	DEFINE v_iNoPagadas      INTEGER;
	DEFINE v_iSqlErr         INTEGER;
	Define cEmpresa          Char(3);
	DEFINE v_cSucursal       CHAR(4);
	DEFINE cConcepto         CHAR(1);
	DEFINE  iCont  			 INTEGER;
	DEFINE  iContReg  		 INTEGER;
    DEFINE iTipoEmpresa      SMALLINT;
	
	---Inicializacion de variables
	LET v_cCodRet = "00000";
	LET v_cNomArchivo="";
	LET v_cNumEmp = "";
	LET v_cApellPaterno = "";
	LET v_cApellMaterno = "";
	LET v_cNombres = "";
	LET v_cCuentaAbono = "";
	LET  v_mImporte  = 0;
	LET  v_cConcepto  = "";
	LET  v_cStatus  = "";
	LET v_cDescStatus = "";
	LET v_cNumCte = "";
	LET  v_cProducto = "";
	LET v_cDesTransacc = "";
	LET  v_iPagadas  = 0;
	LET v_iNoPagadas = 0;
	LET  v_iSqlErr = 0;
	Let cEmpresa = '';
	LET v_cSucursal='';
	LET cConcepto = '';
	LET v_cTransaccion='';
	LET iCont=0;
	LET iContReg=0;
    LET iTipoEmpresa = 0;

	BEGIN
    ON EXCEPTION SET v_iSqlErr
        IF v_iSqlErr <> 0 THEN
            LET v_cCodRet  = v_iSqlErr;
            RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
                    v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
        END IF;
    END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;

	   IF (TRIM(NVL(pIdEmp,"")) = "") OR (TRIM(NVL(pTipoOpe,"")) = "") OR (TRIM(NVL(psNombreArchivo,"")) = "") THEN
	        LET  v_cCodRet  = "00001";
	        RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
	                v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
	   END IF;
       
       SELECT tipo_empresa 
         INTO iTipoEmpresa
         FROM bdicheq:sc_nominaempresas
        WHERE codigo = pIdEmp;
	   
	  		 IF pTipoOpe = '1' THEN --Nominas Procesadas

			  FOREACH
					SELECT SKIP pRegistro FIRST 10 nommov.num_empleado, nommov.apell_paterno, nommov.apell_materno, nommov.nombres, nommov.cuenta_abono, nommov.importe,
						   NVL(nom.descripcion, ''), NVL(mae.num_cte, ''), NVL(mae.producto,'0'), NVL(transacc.descripcion, ''),NVL(mae.sucursal,'0'),transacc.numero
					INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion
					FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa
					WHERE  nom.cod_status = nommov.status
					   AND nommov.cuenta_abono = mae.cuenta
					   AND transacc.numero = ( SELECT transacc 
                                                 FROM bdicheq:"informix".sc_nominatransacciones 
                                                WHERE tipo_transaccion = '001'  --Identificador del Abono
                                                  AND tipo_codigo = nommov.concepto
                                                  AND tipo_empresa = iTipoEmpresa )
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status = '1'
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND dispersa.f_dispersion=pFecDisp
					   AND dispersa.id_empresa =pIdEmp
					   AND nommov.nombre_archivo = psNombreArchivo    --Filtrado por nombre de archivo
					   ORDER BY nommov.num_empleado
					--LET iContReg = iContReg + 1;

					LET iCont=1;
					RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;

		   ELIF pTipoOpe = '2' THEN --Nominas no procesadas

			  FOREACH
					   SELECT SKIP pRegistro FIRST 10 nommov.num_empleado, nommov.apell_paterno, nommov.apell_materno, nommov.nombres, nommov.cuenta_abono, nommov.importe,
						   NVL(nom.descripcion, ''), NVL(mae.num_cte, ''), NVL(mae.producto,'0'), NVL(transacc.descripcion, ''),NVL(mae.sucursal,'0'),transacc.numero
						INTO  v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cDescStatus,  v_cNumCte,
						  v_cProducto, v_cDesTransacc, v_cSucursal,v_cTransaccion
					   FROM bdicheq:"informix".sc_nominamovimientoshist nommov,
						Outer bdicheq:"informix".sc_nominaestatus nom,
						Outer bdicheq:"informix".sc_maechq mae,
						bdinteg:"informix".si_transacc transacc,
						bdibpi:"informix".bpi_dispersarchivo dispersa
					   WHERE  nom.cod_status  = nommov.status
					   AND nommov.cuenta_abono=mae.cuenta
					   AND transacc.numero = ( SELECT transacc 
                                                 FROM bdicheq:"informix".sc_nominatransacciones 
                                                WHERE tipo_transaccion = '001'  --Identificador del Abono		
                                                  AND tipo_codigo = nommov.concepto
                                                  AND tipo_empresa = iTipoEmpresa )
					   AND nom.tpo_status = 2   --Es el status de los movimientos
					   AND nommov.status > '1'
					   AND nommov.nombre_archivo =dispersa.nombre_archivo
                       AND  dispersa.f_dispersion=pFecDisp
					   AND dispersa.id_empresa =pIdEmp
					   AND  nommov.nombre_archivo = psNombreArchivo 	--Filtrado por nombre de archivo
						ORDER BY nommov.num_empleado
						
						LET iCont=1;
						RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
							v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal WITH RESUME;

			  END FOREACH;

		   END IF;
        
		IF(iCont = 0) THEN
				LET v_cCodRet='00002';
				 RETURN  v_cCodRet, v_cNumEmp, v_cApellPaterno, v_cApellMaterno, v_cNombres, v_cCuentaAbono, v_mImporte,  v_cNumCte,  v_cTransaccion,
	                v_cProducto, v_cDesTransacc,  v_cDescStatus, v_iPagadas, v_iNoPagadas, v_cSucursal;
		END IF;

	END;
END PROCEDURE;