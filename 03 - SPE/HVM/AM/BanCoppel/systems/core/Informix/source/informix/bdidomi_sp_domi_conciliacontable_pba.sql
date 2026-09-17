CREATE PROCEDURE "informix".sp_domi_conciliacontable_pba(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini Char(10), pfecfin Char(10))
RETURNING 
    Char(5),       -- 00.- Codigo de Retorno	
    Date,          -- 01.- Fecha Presentacion
	Integer,       --02.- Cantidad de Registros Archivo Origuinal
	Money(18,2),   --03.- Sumatoria de Reguistros Archivo Origuinal
	Integer,       --04.- Cantidad de Registros Archivo Respuesta1
	Money(18,2),   --05.- Sumatoria de Reguistros Archivo Respuesta1
	Integer,       --06.- Cantidad de Registros Archivo Respuesta2 
	Money(18,2),   --07.- Sumatoria de Reguistros Archivo Respuesta2
	Char(14),      --08.- Cuenta Contable Cargos
	Money(18,2),   --09.- Sumatoria Cuenta Contable Cargos
	Char(14),      --10.- Cuenta Contable Cargos Deudora
	Money(18,2),   --11.- Sumatoria Cuenta Contable Cargos Deudora
	Char(14),      --12.- Cuenta Contable Abonos
	Money(18,2);   --13.- Sumatoria Cuenta Contable Abonos
    

-- Declaracion de Variables
Define iSQLerr                          Integer;
Define cCodRet                          Char(5);
Define cCodRet2                         Char(5);
Define cDescError                       Char(95);

Define dFechaPresentacion               Date;
Define iContRegOriginal                 Integer;
Define mSumRegOriguinal                 Money(18,2);
Define iContRegResp1                    Integer;
Define mSumRegResp1                     Money(18,2);
Define iContRegResp2                    Integer;
Define mSumRegResp2                     Money(18,2);
Define cCuentaContableCargo             Char(14);
Define mSumCuentaContableCargo          Money(18,2);
Define cCuentaContableCargoDeudora      Char(14);
Define mSumCuentaContableCargoDeudora   Money(18,2);
Define cCuentaContableAbono             Char(14);
Define mSumCuentaContableAbono          Money(18,2);
Define cCodParam01                      Char(2);
Define cCodParam02                      Char(2);
Define cCodParam03                      Char(2);
Define dFecha_Presentacion              Date;
Define dFechaHoy                        Date;
Define cTipoP                           Char(1);
Define cCodOperacion                    Char(2);
Define cFecIni                          Char(8);
Define cFecFin                          Char(8);
Define cFecha_Presentacion              Char(8);
Define iTipoOp                          Integer;

ON EXCEPTION SET iSQLerr
    IF iSQLerr <> 0 THEN
        LET cCodRet = iSQLerr; 
        RETURN cCodRet,dFecha_Presentacion,iContRegOriginal,mSumRegOriguinal,iContRegResp1,mSumRegResp1,iContRegResp2,mSumRegResp2,
			   cCuentaContableCargo,mSumCuentaContableCargo,cCuentaContableCargoDeudora,mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono,mSumCuentaContableAbono;   
	END IF
END EXCEPTION;

--Inicializacion de Variables
Let iSQLerr       					 = 0;
Let cCodRet        					 = '00000';
Let cCodRet2       					 = '00000';
Let cDescError     					 = '';

Let dFechaPresentacion               = '';
Let iContRegOriginal                 = 0;
Let mSumRegOriguinal                 = 0.00;
Let iContRegResp1                    = 0;
Let mSumRegResp1                     = 0.00;
Let iContRegResp2                    = 0;
Let mSumRegResp2                     = 0.00;
Let cCuentaContableCargo             = '';
Let mSumCuentaContableCargo          = 0.00;
Let cCuentaContableCargoDeudora      = '';
Let mSumCuentaContableCargoDeudora   = 0.00;
Let cCuentaContableAbono             = '';
Let mSumCuentaContableAbono          = 0.00;
Let cCodParam01                      = '';
Let cCodParam02                      = '';
Let cCodParam03                      = '';
Let dFecha_Presentacion              = '';
Let dFechaHoy                        = '';
Let cTipoP                           = '';
Let cCodOperacion                    = '';
Let cFecIni                          = '';
Let cFecFin                          = '';
Let cFecha_Presentacion              = '';
Let iTipoOp                          = 0;

	--SET DEBUG FILE TO "/tmp/sp_domi_ConciliaContable.out";
	--TRACE ON;	

Begin

	--Validacion de Parametros de entrada
	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02612"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02612"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet2, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
	END IF;	
	
	If Trim(pNomArchivo) <> "" or pNomArchivo is not null Then
		Select limit 1 cod_operacion 
		Into cCodOperacion		
		From dom_cce_detalle 
		Where nombre_arch = pNomArchivo;
		
		If substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '30' Then 
			Let pTpoProc = 1;
		Elif substr(pNomArchivo,1,1) = 'E' And cCodOperacion = '34' Then 
			Let pTpoProc = 2;
		Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '30' Then 
			Let pTpoProc = 4;
		Elif substr(pNomArchivo,1,1) = 'S' And cCodOperacion = '34' Then 
			Let pTpoProc = 5 ;
		End  if		
	End If
	
    IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
        Let cTipoP = 'E';
		Let cCodOperacion = '30';		
		Let cCodParam01 = '18';
		Let cCodParam02 = '19';
    ELIF pTpoProc = 2 THEN -- REPORTE PRESENTADO
		Let cTipoP = 'E';
		Let cCodOperacion = '34';		
		Let cCodParam01 = '20';
		Let cCodParam02 = '21';
    ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
		Let cTipoP = 'S';
		Let cCodOperacion = '30';		
		Let cCodParam01 = '22';
		Let cCodParam02 = '23';
    ELIF pTpoProc = 5 THEN -- REPORTE RECIBIDO    
		Let cTipoP = 'S';
		Let cCodOperacion = '34';		            
		Let cCodParam01 = '24';
		Let cCodParam02 = '25';
		Let cCodParam03 = '26';		
    ELSE
		LET cCodRet = '02600'; -- OPERACION DESCONOCIDA
		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
			   cCuentaContableAbono, mSumCuentaContableAbono;
    END IF
	
	--Obtengo las cuenta contables para la conciliación
	Select valor Into cCuentaContableCargo 
	From dom_parametros Where cod_param = cCodParam01;
	
	Select valor Into cCuentaContableAbono
	From dom_parametros Where cod_param = cCodParam02;
	
	If cCodParam03 <> '' then 
		Select valor Into cCuentaContableCargoDeudora 
		From dom_parametros Where cod_param = cCodParam03;
	End if

-- SE ELIMINA CONCILIACION CONTABLE	
	--Se validan los parametros obtenidos
--	If length(cCuentaContableCargo) <> 14 then
--		LET cCodRet = '02613'; -- 
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
--	
--	If length(cCuentaContableAbono) <> 14 then
--		LET cCodRet = '02613'; --
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
--	
--	If length(cCuentaContableAbono) <> 14 and cCodParam03 <> '' then
--		LET cCodRet = '02613'; --
--		RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--			   cCuentaContableCargo, mSumCuentaContableCargo,cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--			   cCuentaContableAbono, mSumCuentaContableAbono;
--	End if
	
	If pNomArchivo <> "" Then		
		Select fecha_presentacion 
		Into cFecha_Presentacion
		From dom_cce_encabezado		
		Where nombre_arch = pNomArchivo;
		
		--Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
		Let cFecIni = cFecha_Presentacion; 
		Let cFecFin = cFecha_Presentacion;			
	Else
		--Formateo la variable a tipo char en  yyyymmdd   de   mm/dd/yyyy
		Let cFecIni = substr(pfecini,7,4) || substr(pfecini,1,2) || substr(pfecini,4,2); 
		Let cFecFin = substr(pfecfin,7,4) || substr(pfecfin,1,2) || substr(pfecfin,4,2);	
	End IF	
	
	Let cCodOperacion = cCodOperacion;
	Let cTipoP  =cTipoP; 
	Let cFecIni = cFecIni;
	Let cFecFin = cFecFin;
	
	Foreach with hold
		Select Distinct(fecha_presentacion)
		Into cFecha_Presentacion
		From dom_cce_encabezado
		Where cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And fecha_presentacion Between cFecIni And cFecFin
		
		Let pNomArchivo = pNomArchivo;

		--Obtiene cantidad de reguistros del archivo y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegOriginal, mSumRegOriguinal
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP;
		
		--Obtiene cantidad de reguistros del archivo respuesta 1 y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegResp1, mSumRegResp1
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion 
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And cve_estatus = '02';
		
		--Obtiene cantidad de reguistros del archivo respuesta 2 y total en pesos del mismo
		Select Count(nombre_arch), nvl(Sum(importe::integer),0) / 100
		Into iContRegResp2, mSumRegResp2
		From dom_cce_detalle 
		Where fecha_presentacion = cFecha_Presentacion 
		And cod_operacion = cCodOperacion
		And Substr(nombre_arch,1,1) = cTipoP
		And cve_estatus = '01';
		
		--Obtengo la fecha de presentacion del archivo mm/dd/yyyy
		Let dFecha_Presentacion = substr(cFecha_Presentacion,5,2) || '/' || substr(cFecha_Presentacion,7,2) || '/' || substr(cFecha_Presentacion,1,4);		

		Select fecha_hoy Into dFechaHoy From bdicheq:sc_fechas;
		
--		If Month(dFecha_Presentacion) = Month(dFechaHoy) then
			
			--Obtengo la sumatoria de los cargos para la cuenta contable de Cargos
--			Select nvl(Sum(cargos_dia),0)
--			Into mSumCuentaContableCargo
--			From bdicont:co_sdodias
--			Where ccmayor = substr(cCuentaContableCargo,1,4)
--			And ccsub = substr(cCuentaContableCargo,5,2)
--			And ccsubsub = substr(cCuentaContableCargo,7,2)
--			And ccssubsub = substr(cCuentaContableCargo,9,2)
--			And ccsssubsub = substr(cCuentaContableCargo,11,2)
--			And sector = substr(cCuentaContableCargo,13,2)
--			And mes_dia = dFecha_Presentacion;
			
			--Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
--			Select nvl(Sum(abonos_dia),0)
--			Into mSumCuentaContableAbono
--			From bdicont:co_sdodias
--			Where ccmayor = substr(cCuentaContableAbono,1,4)
--			And ccsub = substr(cCuentaContableAbono,5,2)
--			And ccsubsub = substr(cCuentaContableAbono,7,2)
--			And ccssubsub = substr(cCuentaContableAbono,9,2)
--			And ccsssubsub = substr(cCuentaContableAbono,11,2)
--			And sector = substr(cCuentaContableAbono,13,2)
--			And mes_dia = dFecha_Presentacion;
			
--			If cCodParam03 <> '' then
--				--Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
--				Select nvl(Sum(abonos_dia),0)
--				Into mSumCuentaContableCargoDeudora
--				From bdicont:co_sdodias
--				Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
--				And ccsub = substr(cCuentaContableCargoDeudora,5,2)
--				And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
--				And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
--				And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
--			And sector = substr(cCuentaContableCargoDeudora,13,2)
--				And mes_dia = dFecha_Presentacion;
--			End IF	

			RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
				   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
				   cCuentaContableCargo, mSumCuentaContableCargo,
				   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
				   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;		   			
--		Else				
--			--Obtengo la sumatoria de los cargos para la cuenta contable de Cargos de Hist
--			Select nvl(Sum(cargos_dia),0)
--			Into mSumCuentaContableCargo
--			From bdicont:co_histsdodias
--			Where ccmayor = substr(cCuentaContableCargo,1,4)
--			And ccsub = substr(cCuentaContableCargo,5,2)
--			And ccsubsub = substr(cCuentaContableCargo,7,2)
--			And ccssubsub = substr(cCuentaContableCargo,9,2)
--			And ccsssubsub = substr(cCuentaContableCargo,11,2)
--			And sector = substr(cCuentaContableCargo,13,2)
--			And mes_dia = dFecha_Presentacion;
			
			--Obtengo la sumatoria de los abonos para la cuenta contable de Abonos
--			Select nvl(Sum(abonos_dia),0)
--			Into mSumCuentaContableAbono
--			From bdicont:co_histsdodias
--			Where ccmayor = substr(cCuentaContableAbono,1,4)
--			And ccsub = substr(cCuentaContableAbono,5,2)
--			And ccsubsub = substr(cCuentaContableAbono,7,2)
--			And ccssubsub = substr(cCuentaContableAbono,9,2)
--			And ccsssubsub = substr(cCuentaContableAbono,11,2)
--			And sector = substr(cCuentaContableAbono,13,2)
--			And mes_dia = dFecha_Presentacion;
			
--			If cCodParam03 <> '' then
				--Obtengo la sumatoria de los cargos para la cuenta contable Deudora de Cargos
--				Select nvl(Sum(abonos_dia),0)
--				Into mSumCuentaContableCargoDeudora
--				From bdicont:co_histsdodias
--				Where ccmayor = substr(cCuentaContableCargoDeudora,1,4)
--				And ccsub = substr(cCuentaContableCargoDeudora,5,2)
--				And ccsubsub = substr(cCuentaContableCargoDeudora,7,2)
--				And ccssubsub = substr(cCuentaContableCargoDeudora,9,2)
--				And ccsssubsub = substr(cCuentaContableCargoDeudora,11,2)
--				And sector = substr(cCuentaContableCargoDeudora,13,2)
--				And mes_dia = dFecha_Presentacion;
--			End IF	

--			RETURN cCodRet, dFecha_Presentacion, iContRegOriginal, mSumRegOriguinal,
--				   iContRegResp1, mSumRegResp1, iContRegResp2, mSumRegResp2,
--				   cCuentaContableCargo, mSumCuentaContableCargo,
--				   cCuentaContableCargoDeudora, mSumCuentaContableCargoDeudora,
--				   cCuentaContableAbono, mSumCuentaContableAbono WITH RESUME;		   			
--		End IF	
	End Foreach
	
		
End 
End Procedure
DOCUMENT
'AUTOR: Armando Mercado Figueroa',
'Descripcion: Sumatoria por dia segun cuenta contable, las cuentas contables se encuentran parametrizadas',
'Fecha: 2009/09/02',
'Version: 20090902.1246',
'BD: BDIDOMI';

CREATE PROCEDURE "informix".sp_domi_procesararchivo10(pNombreArchivo CHAR(20),pNombreArchivo11 CHAR(20))
	RETURNING CHAR(5);

---Agregar un nombre de archivo 11
---- VARIABLES  GENERALES---
DEFINE  cSqlerr		INTEGER;
DEFINE  cCodret     CHAR(5);
DEFINE  cCodret2     CHAR(5);
DEFINE  cMensaje     CHAR(200);
DEFINE  cCuenta		 CHAR(11);
DEFINE  cStatus		 CHAR(1);
DEFINE  cFisica		 CHAR(2);
DEFINE  cListaProductosPermitidos		 CHAR(100);
DEFINE  cNombreArchivoSAlida CHAR(20);
DEFINE  cProducto CHAR(4);
DEFINE dFecha date;
DEFINE iExiste 		INTEGER;
DEFINE d_Fech_prox DATE;
DEFINE c_Fech_prox CHAR(8);
---- VARIABLES   ---
DEFINE cPrefijoCLABE 	CHAR(6);
DEFINE cPrefijoTarjeta 	CHAR(6);
DEFINE cPrefijoTarjNuevo CHAR(6);
DEFINE cTarjeta_NumCta	CHAR(20);

---- VARIABLES ENCABEZADO -----
DEFINE cNombre_archE CHAR(20);
DEFINE cFecha_presentacionE CHAR(8);
DEFINE cTpo_registro CHAR(2);
DEFINE cNum_secuenciaE CHAR(7);
DEFINE cCod_operacionE CHAR(2);
DEFINE cCve_banco CHAR(3);
DEFINE cSentido CHAR(1);
DEFINE cServicio CHAR(1);
DEFINE cNum_bloque CHAR(7);
DEFINE cCod_divisaE CHAR(2);
DEFINE cCve_rechazo_bl CHAR(2);
DEFINE cModalidad CHAR(1);
DEFINE cUso_futuro_ccenE CHAR(41);
DEFINE cUso_futuro_bancoE CHAR(345);
DEFINE cUser_insertE CHAR(8);
DEFINE dFecha_insertE date;

---- VARIABLES DETALLE -----
DEFINE cNombre_archD CHAR(20);
DEFINE cFecha_presentacionD CHAR(8);
DEFINE cTipo_registro CHAR(2);
DEFINE cNum_secuenciaD CHAR(7);
DEFINE cCod_operacionD CHAR(2);
DEFINE cCod_divisaD CHAR(2);
DEFINE cFecha_trans CHAR(8);
DEFINE cBanco_presentador CHAR(3);
DEFINE cBanco_receptor CHAR(3);
DEFINE cImporte CHAR(15);
DEFINE cUso_futuro_ccenD CHAR(16);
DEFINE cTipo_operacion CHAR(2);
DEFINE cFecha_aplica CHAR(8);
DEFINE cTipo_cta_ord CHAR(2);
DEFINE cNum_cta_ord CHAR(20);
DEFINE cNombre_ord CHAR(40);
DEFINE cRfc_ord CHAR(18);
DEFINE cTipo_cta_rec CHAR(2);
DEFINE cNum_cta_rec CHAR(20);
DEFINE cNombre_rec CHAR(40);
DEFINE cRfc_rec CHAR(18);
DEFINE cRef_servicio CHAR(40);
DEFINE cNombre_titular_serv CHAR(40);
DEFINE cImporte_iva CHAR(15);
DEFINE cRef_numerica CHAR(7);
DEFINE cRef_leyenda CHAR(40);
DEFINE cClave_rastreo CHAR(30);
DEFINE cMotivo_dev CHAR(2);
DEFINE cFecha_pres_ini CHAR(8);
DEFINE cUso_futuro_bancoD CHAR(12);
DEFINE cCve_estatus CHAR(2);
DEFINE cFolio_suc CHAR(16);
DEFINE cUser_insertD CHAR(8);
DEFINE dFecha_insertD DATE;

---- VARIABLES SUMARIO -----
DEFINE cNombre_archS CHAR(20);
DEFINE cFecha_presentacionS CHAR(8);
DEFINE cTipo_registroS CHAR(2);
DEFINE cNum_secuenciaS CHAR(7);
DEFINE cCod_operacionS CHAR(2);
DEFINE cNum_bloqueS CHAR(7);
DEFINE cNum_operaciones CHAR(7);
DEFINE cImp_operaciones CHAR(18);
DEFINE cUso_futuro_ccenS CHAR(40);
DEFINE cUso_futuro_bancoS CHAR(339);
DEFINE cUser_insertS CHAR(8);
DEFINE dFecha_insertS DATE;


DEFINE cFechaSinFormato CHAR(8);
DEFINE cFechaFormateada date;
DEFINE cCodSpFecha CHAR(5);
DEFINE dFechaHabil DATE;
DEFINE iContador INTEGER;
DEFINE cFecha_Hoy DATE;
DEFINE cStatus_tar CHAR(1);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET iContador = 0;
LET cStatus_tar = '';

----INICIALIZAR  VARIABLES ENCABEZADO -----
LET cNombre_archE ='';
LET cProducto = '';
LET cFecha_presentacionE='';
LET cTpo_registro ='';
LET cNum_secuenciaE ='';
LET cCod_operacionE ='';
LET cCve_banco ='';
LET cSentido ='';
LET cServicio ='';
LET cNum_bloque ='';
LET cCod_divisaE ='';
LET cCve_rechazo_bl ='';
LET cModalidad ='';
LET cUso_futuro_ccenE ='';
LET cUso_futuro_bancoE ='';
LET cUser_insertE ='';
LET dFecha_insertE ='';

---INICIALIZAR VARIABLES DETALLE
LET cNombre_archD ='';
LET cFecha_presentacionD ='';
LET cTipo_registro ='';
LET cNum_secuenciaD ='';
LET cCod_operacionD ='';
LET cCod_divisaD ='';
LET cFecha_trans ='';
LET cBanco_presentador ='';
LET cBanco_receptor ='';
LET cImporte ='';
LET cUso_futuro_ccenD ='';
LET cTipo_operacion ='';
LET cFecha_aplica ='';
LET cTipo_cta_ord ='';
LET cNum_cta_ord ='';
LET cNombre_ord ='';
LET cRfc_ord ='';
LET cTipo_cta_rec ='';
LET cNum_cta_rec ='';
LET cNombre_rec ='';
LET cRfc_rec ='';
LET cRef_servicio ='';
LET cNombre_titular_serv ='';
LET cImporte_iva ='';
LET cRef_numerica ='';
LET cRef_leyenda ='';
LET cClave_rastreo ='';
LET cMotivo_dev ='';
LET cFecha_pres_ini ='';
LET cUso_futuro_bancoD ='';
LET cCve_estatus ='';
LET cFolio_suc ='';
LET cUser_insertD ='';
LET dFecha_insertD ='';

----INICIALIZAR VARIABLES SUMARIO -----
LET cNombre_archS='';
LET cFecha_presentacionS ='';
LET cTipo_registroS ='';
LET cNum_secuenciaS ='';
LET cCod_operacionS ='';
LET cNum_bloqueS ='';
LET cNum_operaciones ='';
LET cImp_operaciones ='';
LET cUso_futuro_ccenS ='';
LET cUso_futuro_bancoS ='';
LET cUser_insertS ='';
LET dFecha_insertS ='';
LET iExiste =0;
LET c_Fech_prox = '';

		

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret;
        END IF;
    END EXCEPTION;

	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoTarjeta FROM Dom_Parametros WHERE cod_param = '06';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoTarjNuevo FROM Dom_Parametros WHERE cod_param = '43';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO cPrefijoCLABE FROM Dom_Parametros WHERE cod_param = '05';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT fecha_hoy INTO cFecha_hoy FROM bdicheq:sc_fechas;

	-- VALIDACIONES   EN ORDEN --
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		--Selecciona la cuenta a validar
		SELECT  Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Cod_divisa,
				Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen, Tipo_operacion, Fecha_aplica, Tipo_cta_ord,
				Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec, Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv,
				Importe_iva, Ref_numerica, Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus,
				Folio_suc, User_insert, Fecha_insert
		INTO    cNombre_archD, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
				cFecha_trans, cBanco_presentador, cBanco_receptor, cImporte, cUso_futuro_ccenD, cTipo_operacion, cFecha_aplica, cTipo_cta_ord,
				cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec, cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,
				cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo, cMotivo_dev, cFecha_pres_ini, cUso_futuro_bancoD, cCve_estatus,
				cFolio_suc, cUser_insertD, dFecha_insertD
		FROM Dom_cce_detalle_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10'
		LET cTarjeta_NumCta = cNum_cta_rec;
		---- si no entra a ningun error pues se queda el 99 de archivo paso  las validaciones
		-- 6.- VALIDACION DE  Motivo 99 "Cuenta correcta en la verificacion de cuentas" --
		LET cMensaje = 'Cuenta correcta en la verificación de cuentas';
		--Inserto en la de detalle_paso con codigo de operacion 11 almacenar clave 01 en motivo de devolucion
		LET cCod_operacionD = '11';
		LET cImporte = '000000000000000';
		--LET cRef_leyenda = 'Cuenta para Verificar';
		LET cMotivo_dev = '99';

		-- VALIDACIONES   EN ORDEN --
		-- 1.- VALIDACION DE  Motivo 06 "Cuenta no pertenece al Banco Receptor" --
		IF NOT (SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjeta) OR SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjNuevo) OR SUBSTR(cNum_cta_rec,3,3) = TRIM(cPrefijoCLABE)) THEN----si la cuenta es un a  Tarjeta  06      OR    ----si la cuenta es un a  CLABE   07
			--- ERROR MARCAR EL ERROR 06
			LET cMensaje = 'Cuenta no pertenece al banco receptor';
			LET cMotivo_dev = '06';
		END IF;
		---se valida si es tarjeta o cuenta CLABE, si es una tarjeta obtengo la CLABE para usar la cuenta
		IF SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjeta) OR SUBSTR(cNum_cta_rec,5,6) = TRIM(cPrefijoTarjNuevo) AND cMotivo_dev = '99' THEN  --Es una Tarjeta
			--- Si me dan la tarjeta obtengo la  cuenta para hacer una busqueda mas rapida
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT NVL(cuenta,'') INTO cCuenta FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16);  --- INDEX (empresa,num_tarjeta)
			IF  (cCuenta = '') THEN
				--marco el error en el registro    --- ERROR MARCAR EL ERROR 01
				LET cMensaje = 'Cuenta inexistente';
				LET cMotivo_dev = '01';
			ELSE
				-- validar que la tarjeta sea la titular
				----  si la tarjeta no es la titular marcar el error de servisio no permitido
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS (SELECT tipo_tarjeta FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16) AND tipo_tarjeta = 'T' AND status_tar = 'A') THEN
					-- VALIDAR SI ESTA EN LA MAESTRO DE CHEQUES
					IF EXISTS (SELECT cuenta_clabe FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = cCuenta)THEN
						--Obtener la cuenta clabe para que funcione el codigo siguiente de la cual se tomara la cuenta del cliente
						SELECT LPAD(cuenta_clabe,20,'0') INTO cNum_cta_rec FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = cCuenta; --- INDEX (empresa, cuenta)
					ELSE
						---la tarjeta no es la titular marcar el error de servicio no permitido
						LET cMensaje = 'Cuenta inexistente';
						LET cMotivo_dev = '01';
					END IF;
				ELSE
					---la tarjeta no es la titular marcar el error de servicio no permitido
					LET cMensaje = 'La tarjeta no es titular';
					LET cMotivo_dev = '02';
					SELECT status_tar INTO cStatus_tar FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = SUBSTR(TRIM(cNum_cta_rec),5,16) AND tipo_tarjeta = 'T';
					IF cStatus_tar <> 'A' THEN
						---la tarjeta no es la titular marcar el error de servicio no permitido
						LET cMensaje = 'La tarjeta esta cancelada';
						LET cMotivo_dev = '03';
					END IF;
				END IF;
			END IF;
		END IF;
		---Al final de cada validacion se valida q   cMotivo_dev = '99' para asegurar q si entro aun error de registro ya no entre a otro y regrese el primer ) cMotivo_dev
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		IF((SUBSTR(cNum_cta_rec,3,3) = TRIM(cPrefijoCLABE)) AND cMotivo_dev = '99') THEN--- Es una cuenta CLABE
			--- SE OBTIENE SI ES UNA PERSONA FISICA
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT cte.tpo_persona INTO cFisica FROM bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
			WHERE mae.cuenta = SUBSTR(cNum_cta_rec,9,11);
			--- SE VALIDA  Q SEA UN PERSONA FISICA
			IF (cFisica <> '01' AND cMotivo_dev = '99')THEN
				--marco el error en el registro  --- PERSONA NO FISICA
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
			--- SE VALIDA Q EL PRODUCTO ESTE  EN LA LISTA DE PRODUCTOS DE LA TABLA PARAMETROS CON LA COD_PARAM = 12
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT valor INTO cListaProductosPermitidos FROM dom_parametros WHERE cod_param = '12';
			--Se obtiene el producto de la cuenta para validar si es un producto permitido
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT producto INTO cProducto FROM bdicheq:sc_maechq ma WHERE ma.empresa = '001' AND ma.cuenta = SUBSTR(cNum_cta_rec,9,11);
			--validar que exista en la lista de productos permitidos
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF NOT( cListaProductosPermitidos LIKE '%'|| cProducto || '%' ) AND cMotivo_dev = '99'  THEN
				--marco el error en el registro  --- El producto no esta en la lista de productos permitidos
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
			-- 2.- VALIDACION DE  Motivo 01 "Cuenta inexistente" --
			IF (NOT EXISTS (SELECT cuenta_clabe FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = SUBSTR(cNum_cta_rec,9,11))) AND cMotivo_dev = '99' THEN  --INDEX EMPRESA  cuenta
				--marco el error en el registro  --- ERROR MARCAR EL ERROR 01
				LET cMensaje = 'Cuenta inexistente';
				LET cMotivo_dev = '01';
			END IF;
			-- 3.- VALIDACION DE  Motivo 02 "Cuenta Bloqueada" --
			-- 4.- VALIDACION DE  Motivo 03 "Cuenta Cancelada" --
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF (EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdicheq:sc_maechq.status_cta IN(2,3) )) AND cMotivo_dev = '99' THEN-- validar que no este bloqueada 2   INDEX  empresa cuenta
				-- SE OBTIENE EL ESTADA PARA VALIDARLO
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT status_cta INTO cStatus FROM bdicheq:sc_maechq WHERE empresa = '001' AND bdicheq:sc_maechq.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdicheq:sc_maechq.status_cta IN(2,3);
				-- 3.- VALIDACION DE  Motivo 02 "Cuenta Bloqueada" --
				IF cStatus = '3' THEN
					---Cuenta Bloqueada marcar con 02  --marco el error  en el registro
					LET cMensaje = 'Cuenta Bloqueada';
					LET cMotivo_dev = '02';
				ELIF cStatus = '2' THEN  -- 4.- VALIDACION DE  Motivo 03 "Cuenta Cancelada" --
					--Cuenta Cancelada marcar con 03   --marco el error  en el registro
					LET cMensaje = 'Cuenta Cancelada';
					LET cMotivo_dev = '03';
				END IF;
			END IF;
			-- 5.- VALIDACION DE  Motivo 11 "Cliente no tiene autorizado el Servicio" --
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			IF( EXISTS (SELECT cuenta FROM bdidomi:dom_autorizaciones  WHERE bdidomi:dom_autorizaciones.cuenta = SUBSTR(cNum_cta_rec,9,11)  AND bdidomi:dom_autorizaciones.cve_estatus = '02') ) AND cMotivo_dev = '99'THEN
				--Cuenta no Autorizada marcar con 11   --marco el error  en el registro
				LET cMensaje = 'Cliente no tiene autorizado el Servicio';
				LET cMotivo_dev = '02';
			END IF;
		END IF;
		--Inserto en la de detalle_paso con codigo de operacion 11 almacenar clave  en motivo de devolucion
		LET cFechaFormateada = SUBSTR(cFecha_presentacionD,5,2) ||'/'|| SUBSTR(cFecha_presentacionD,7,2) ||'/'|| SUBSTR(cFecha_presentacionD,1,4);
		--- se obtendra el dia siguente habil para validar las fechas de cFecha_trans y la cFecha_aplica ya que estas deben ser el dia siguiente habil a la fecha cFecha_presentacion
		EXECUTE FUNCTION bdinteg:splvalfecha('001',(cFechaFormateada) + 1 ,0)INTO cCodSpFecha,dFechaHabil; --a qui ya tengo el dias siguiente habil
		--NOTA.- Se agrego la validacion de la fecha dado que se puede presentar el caso que la fecha sea habil para la banca e inabil para el banco.
		--Solicitada por jaime gonzales el dia 15/09/2008
		--Realizada por Alejandro Osuna
        SELECT fecha_prox INTO d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = dFechaHabil;
        IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
           LET dFechaHabil = dFechaHabil;
        ELSE
           LET dFechaHabil = d_Fech_prox;
           LET cFecha_trans = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
           LET cFecha_aplica = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
        END IF;
		-- se manda mes dia año
		LET cFechaSinFormato = year(dFechaHabil) || LPAD(month(dFechaHabil),2,'0')|| LPAD(day(dFechaHabil),2,'0');
		--comparacion con tra los fechas   Fecha_trans   cFecha_aplica
		IF NOT (cFecha_trans = cFechaSinFormato AND cFecha_aplica = cFechaSinFormato) THEN
			--Marco el error , Guardar en bitacora y rechazar el archivo por motivo  uno o mas registros de la aplicacion tienen una fecha no valida
			LET cCodRet = '00801';
			RETURN cCodRet;
		END IF;
		---SI EL MOTIVO ES DIFERENTE DE 99 SE ACTUALIZA EL CAMPO CVE_EESTATUS = 02 DELA DETALLE PASO
		IF cMotivo_dev <> '99' THEN
			UPDATE dom_cce_detalle_paso SET dom_cce_detalle_paso.cve_estatus = '02'
			WHERE Nombre_arch = cNombre_archD AND Fecha_presentacion = cFecha_presentacionD
			AND Tipo_registro = cTipo_registro AND Num_secuencia = cNum_secuenciaD AND cod_operacion = '10';
		ELSE
			UPDATE dom_cce_detalle_paso SET dom_cce_detalle_paso.cve_estatus = '01'
			WHERE Nombre_arch = cNombre_archD AND Fecha_presentacion = cFecha_presentacionD
			AND Tipo_registro = cTipo_registro AND Num_secuencia = cNum_secuenciaD AND cod_operacion = '10';
		END IF;
		--Nombrar al archivo de salida para que deje insertar en la tabla de paso
		LET cNombreArchivoSAlida = pNombreArchivo11;
		LET cNum_cta_rec = cTarjeta_NumCta;
		LET cFecha_presentacionD = cFechaSinFormato;

		INSERT INTO dom_cce_detalle_paso(Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion,
							Cod_divisa, Fecha_trans, Banco_presentador, Banco_receptor, Importe, Uso_futuro_ccen,
							Tipo_operacion, Fecha_aplica, Tipo_cta_ord, Num_cta_ord, Nombre_ord, Rfc_ord, Tipo_cta_rec,
							Num_cta_rec, Nombre_rec, Rfc_rec, Ref_servicio, Nombre_titular_serv, Importe_iva, Ref_numerica,
							Ref_leyenda, Clave_rastreo, Motivo_dev, Fecha_pres_ini, Uso_futuro_banco, Cve_estatus, Folio_suc,
							User_insert, Fecha_insert)
		Values (cNombreArchivoSalida, cFecha_presentacionD, cTipo_registro, cNum_secuenciaD, cCod_operacionD, cCod_divisaD,
				cFecha_trans, cBanco_receptor,/* <--Aqui se intercambian los bancos para el 11 -->*/cBanco_presentador , cImporte, cUso_futuro_ccenD,
				cTipo_operacion, cFecha_aplica,cTipo_cta_ord,cNum_cta_ord, cNombre_ord, cRfc_ord, cTipo_cta_rec, cNum_cta_rec,
				cNombre_rec, cRfc_rec, cRef_servicio, cNombre_titular_serv,cImporte_iva, cRef_numerica, cRef_leyenda, cClave_rastreo,
				cMotivo_dev,cFecha_pres_ini, cUso_futuro_bancoD, cCve_estatus, cFolio_suc, cUser_insertD, dFecha_insertD);
		---Contador de los registros de detalle  para una validacion en la parte de abajo
		LET iContador = iContador + 1;
	END FOREACH;
		----Hacer el insert de  encabezado y sumario
		--Selecciona El registro de Encabezado
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT  Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio, Num_bloque,
				Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
		INTO    cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
				cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE
		FROM Dom_cce_encabezado_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10';
		---Llenar la variables q se ban a modificar antes del insert del codigo 11 para la tabla
		LET cTpo_registro = '01';
		LET cNum_secuenciaE = '0000001';
		LET cCod_operacionE = '11';
		LET cSentido = 'E';
		LET cFecha_presentacionE = cFechaSinFormato;
		-- Insertar en encabezado el 11
		LET cNombre_archE = cNombreArchivoSalida;
		--cNum_bloque  al momento de crear el archivo 11 el numero de bloque cambia a DDCCCCCCC  donde CCCCCCC  = 000001
		LET cNum_bloque = LPAD(SUBSTR(cFecha_presentacionE,7,2),2,'0') || LPAD(SUBSTR(pNombreArchivo11,16,2),5,'0');
		INSERT INTO Dom_cce_encabezado_paso( Nombre_arch, Fecha_presentacion, Tpo_registro, Num_secuencia, Cod_operacion, Cve_banco, Sentido, Servicio,
		        Num_bloque, Cod_divisa, Cve_rechazo_bl, Modalidad, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
		Values( cNombre_archE, cFecha_presentacionE, cTpo_registro, cNum_secuenciaE, cCod_operacionE, cCve_banco, cSentido, cServicio, cNum_bloque,
				cCod_divisaE, cCve_rechazo_bl, cModalidad, cUso_futuro_ccenE, cUso_futuro_bancoE, cUser_insertE, dFecha_insertE);

		--Selecciona El registro de Sumario
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque, Num_operaciones,
		       Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert
		INTO   cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
		       cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS
		FROM Dom_cce_sumario_paso WHERE nombre_arch = pNombreArchivo AND Cod_operacion = '10';

		---Llenar la variables q se ban a modificar antes del insert
		LET cTipo_registroS = '09';
		LET cCod_operacionS = '11';
		IF LPAD(iContador,7,'0') <> cNum_operaciones THEN
			LET cCodRet = '00802';
			--LET cMensaje = 'El Numero de operaciones en sumario no corresponde al numero de detalles';
			RETURN cCodRet;
		END IF;
		-- Insertar en encabezado el 11
		LET cNombre_archS = cNombreArchivoSalida;
		LET cFecha_presentacionS = cFechaSinFormato;
		--cNum_bloque  al momento de crear el archivo 11 el numero de bloque cambia a DDCCCCCCC  donde CCCCCCC  = 000001
		LET cNum_bloqueS = LPAD(SUBSTR(cFecha_presentacionS,7,2),2,'0') || LPAD(SUBSTR(pNombreArchivo11,16,2),5,'0');
		INSERT INTO Dom_cce_sumario_paso( Nombre_arch, Fecha_presentacion, Tipo_registro, Num_secuencia, Cod_operacion, Num_bloque,
		        Num_operaciones, Imp_operaciones, Uso_futuro_ccen, Uso_futuro_banco, User_insert, Fecha_insert)
		VALUES( cNombre_archS, cFecha_presentacionS, cTipo_registroS, cNum_secuenciaS, cCod_operacionS, cNum_bloqueS, cNum_operaciones,
		        cImp_operaciones, cUso_futuro_ccenS, cUso_futuro_bancoS, cUser_insertS, dFecha_insertS);
	RETURN cCodret;
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION: Este procedimiento se encarga de procesar y validar los datos de las cuentas del archivo 10 para generar el 11',
'           : tambien inserta los registros en las tablas de paso de sumario, detalle, encabezado',
'FECHA : Julio de 2009',
'BD    : BDIDOMI',
'VERSION: 20090729';

CREATE PROCEDURE "informix".sp_domi_genrep30_pba(pNomArchivo CHAR(20), pTpoProc INTEGER, pfecini CHAR(10), pfecfin CHAR(10))
RETURNING
         CHAR(5),       -- 001.- Codigo de Retorno
		 CHAR(130),     -- 002.- Descripcion del Error
		 CHAR(10),      -- 01.- Fecha Presentacion
		 CHAR(20),      -- 02.- Nombre Archivo
		 CHAR(40),      -- 03.- Nombre Ordenante
		 CHAR(60),      -- 04.- Servicio
		 CHAR(7),       -- 05.- Referencia Numerica
		 MONEY(15, 2),  -- 06.- Importe
		 CHAR(20),      -- 07.- Cuenta Destino
		 CHAR(7),       -- 08.- Sec
		 CHAR(20),      -- 09.- Tipo de Cuenta
		 CHAR(20),      -- 10.- Banco Destino
		 CHAR(20),      -- 11.- Estatus
		 CHAR(60),      -- 12.- Causa Rechazo
		 CHAR(2);       -- 13.- Codigo de Respuesta

-- Declaracion de Variables
DEFINE iSQLerr        INTEGER;
DEFINE cCodRet        CHAR(5);        -- 001
DEFINE cDescError     CHAR(130);      -- 002
DEFINE cFechPresFinR  CHAR(10);       -- 01
DEFINE cNomArch       CHAR(20);       -- 02
DEFINE cNomOrd        CHAR(40);       -- 03
DEFINE cServ          CHAR(60);       -- 04
DEFINE cRef           CHAR(7);        -- 05
DEFINE mImp2          MONEY(15, 2);   -- 06
DEFINE cCtaDest       CHAR(20);       -- 07
DEFINE cSec           CHAR(7);        -- 08
DEFINE cTpoCta        CHAR(20);       -- 09
DEFINE cBancDest      CHAR(20);       -- 10
DEFINE cStatus        CHAR(20);       -- 11
DEFINE cCausaRech     CHAR(60);       -- 12
DEFINE cCodResp       CHAR(2);        -- 13
DEFINE cImp           CHAR(15);
DEFINE cFechPresS	  CHAR(8);
DEFINE cFecInicioW    CHAR(8);
DEFINE cFecFinW       CHAR(8);
DEFINE cTipoP         CHAR(1);
DEFINE cStat_val      CHAR(2);
DEFINE cTipoCtaCod    CHAR(30);
DEFINE cCodRet2       CHAR(5);
DEFINE cBancDestCod   CHAR(3);
DEFINE iTipoOp        INTEGER;
DEFINE cClave_Rastreo CHAR(30);



ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET cCodRet = iSQLerr;
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_domi_genrep30.out";
--	TRACE ON;	

-- Inicializacion de Variables
LET iSQLerr        = 0;
LET cCodRet        = "00000"; -- 001
LET cDescError     = "";      -- 002
LET cFechPresFinR  = "";      -- 01
LET cNomArch       = "";      -- 02
LET cNomOrd        = "";      -- 03
LET cServ          = "";      -- 04
LET cRef           = "";      -- 05
LET mImp2          = 0.00;    -- 06
LET cCtaDest       = "";      -- 07
LET cSec           = "";      -- 08
LET cTpoCta        = "";      -- 09
LET cBancDest      = "";      -- 10
LET cStatus        = "";      -- 11
LET cCausaRech     = "";      -- 12
LET cCodResp       = "";      -- 13
LET cImp           = "";
LET cFechPresS	   = "";
LET cFecInicioW    = "";
LET cFecFinW       = "";
LET cTipoP         = "";
LET cStat_val      = "";
LET cTipoCtaCod    = "";
LET cCodRet2       = "";
LET cDescError     = "";
LET cBancDestCod   = "";
LET iTipoOp        = 0;
LET cClave_Rastreo = "";

BEGIN

	IF pfecini = "01/01/1900" OR pfecfin = "01/01/1900" THEN
		LET pfecini = "";
		LET pfecfin = "";		
	END IF;	
	
	IF ((pTpoProc = "") OR (pTpoProc IS NULL)) THEN	
		LET iTipoOp = -1;		
	ELSE
		LET iTipoOp = pTpoProc;		
	END IF;
	
	IF ((pfecini IS NULL) OR (pfecfin IS NULL)) THEN			
		LET pfecini = "";
		LET pfecfin = "";
	ELSE		
		LET pfecini = pfecini;
		LET pfecfin = pfecfin;
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO wait 4;

	IF pNomArchivo = "" AND iTipoOp = -1 THEN 
		LET cCodRet = "02600"; -- FALTAN PARAMETROS: NOMBRE DEL ARCHIVO O TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
	
	IF (pNomArchivo <> "") AND (iTipoOp >= 0) THEN -- CON EL NOMBRE DEL ARCHIVO Y  TIPO DE PROCESO
		LET cCodRet = "02601"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR NOMBRE + TIPO DE PROCESO
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;
	
	IF pNomArchivo <> "" AND iTipoOp = -1 THEN -- CONSULTA POR NOMBRE DEL ARCHIVO
		IF pfecini = "" AND pfecfin = "" THEN
			IF (SUBSTR(pNomArchivo, 1, 1) = 'E' AND SUBSTR(pNomArchivo, 14, 2) = 30 AND LENGTH(pNomArchivo) = 17) OR
			   (SUBSTR(pNomArchivo, 1, 1) = 'S' AND SUBSTR(pNomArchivo, 11, 2) = 30 AND LENGTH(pNomArchivo) = 16) THEN
				
				IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = pNomArchivo) THEN 
						LET cCodRet = "02602"; -- EL ARCHIVO NO EXISTE
						EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
						RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
				END IF;
	
				FOREACH WITH HOLD	
				
					SELECT 
						 TRIM(det.fecha_presentacion), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
						 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
						 CASE WHEN SUBSTR(pNomArchivo, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
						 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
					INTO cFechPresS, cNomOrd, cServ, cRef,
					     cImp, cCtaDest, cSec, cTipoCtaCod, 
						 cBancDestCod, 
						 cStatus, cCausaRech, cStat_val, cClave_Rastreo
					FROM bdidomi:dom_cce_detalle det
					INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc
					INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
					INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status			
					WHERE nombre_arch = pNomArchivo
					AND cod_operacion = '30'
						LET cCodResp = '';
					SELECT TRIM(descripcion)
					INTO cTpoCta
					FROM bdidomi:dom_tipo_cta
					WHERE tipo_cta = cTipoCtaCod;
					
					SELECT TRIM(vchrnombrecorto)
					INTO cBancDest
					FROM bdinteg:si_bancos
					WHERE banco = cBancDestCod;
								
					IF cStat_val = '01' THEN
						LET cCodResp = '32';
						LET cCausaRech = "";
					ELIF cStat_val = '02' THEN
						LET cCodResp = '31';
					ELIF cStat_val = '03' OR cStat_val = '00' THEN
						LET cCodResp = "";
						LET cCausaRech = "";
					END IF;
					
					IF cCodResp = '31' THEN
						SELECT dev.descripcion 
						INTO cCausaRech
						FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
						WHERE clave_rastreo = cClave_Rastreo
						AND cod_operacion = '31'
						AND det.motivo_dev = dev.motivo_dev;
					END IF;
					
					LET mImp2 = cImp / 100;					
					LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
					
					RETURN cCodRet, TRIM(cDescError), cFechPresFinR, pNomArchivo, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = "02604"; -- ERROR EN LA ESTRUCTURA DEL NOMBRE DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
		ELSE
			LET cCodRet = "02605"; -- ERROR EN LA ASIGNACION DE PARAMETROS: NO SE PUEDE GENERAR POR ARCHIVO + FECHA(S) -- no se puede ejecutar nombre de archivo con fechaS
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;		
			
	ELIF iTipoOp = 1 OR iTipoOp = 4 THEN -- CONSULTA POR NOMBRE DEL PROCESO		
		IF pfecini <> "" AND pfecfin <> "" THEN 
		
			-- SE FORMATEAN LAS FECHAS RECIBIDAS PARA CAMBIARLAS A 'YYYYMMDD' (SIN DIAGONALES) PARA INCLUIRLAS EN EL WHERE
			LET cFecInicioW = SUBSTR(pfecini, 7, 4) || SUBSTR(pfecini, 1, 2) || SUBSTR(pfecini, 4, 2);
			LET cFecFinW = SUBSTR(pfecfin, 7, 4) || SUBSTR(pfecfin, 1, 2) || SUBSTR(pfecfin, 4, 2);
		
			IF pTpoProc = 1 THEN -- REPORTE PRESENTADO
				LET cTipoP = 'E';
			ELIF pTpoProc = 4 THEN -- REPORTE RECIBIDO
				LET cTipoP = 'S';			
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE cod_operacion = '30' AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
																						    AND nombre_arch LIKE cTipoP || '%') THEN
				LET cCodRet = "02603"; -- EL ARCHIVO NO EXISTE
				EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
			END IF;
				
			FOREACH WITH HOLD
			
				SELECT		
					 TRIM(det.fecha_presentacion), TRIM(nombre_arch), TRIM(nombre_rec), TRIM(ser.razon_social), TRIM(det.ref_numerica),				
					 TRIM(det.importe), TRIM(det.num_cta_rec), TRIM(det.num_secuencia), TRIM(det.tipo_cta_rec),
					 CASE WHEN SUBSTR(nombre_arch, 1,1) = 'E' THEN TRIM(det.banco_receptor) ELSE TRIM(det.banco_presentador) END,
					 TRIM(stap.descripcion), TRIM(dev.descripcion), TRIM(det.cve_estatus), det.clave_rastreo
				INTO cFechPresS, cNomArch, cNomOrd, cServ, cRef,
				     cImp, cCtaDest, cSec, cTipoCtaCod, 
					 cBancDestCod, 
					 cStatus, cCausaRech, cStat_val, cClave_Rastreo
				FROM bdidomi:dom_cce_detalle det
				INNER JOIN bdidomi:dom_cat_servicios ser ON det.rfc_ord = ser.rfc			
				INNER JOIN bdidomi:dom_cat_devoluciones dev ON det.motivo_dev = dev.motivo_dev
				INNER JOIN bdidomi:dom_status_pago stap ON det.cve_estatus = stap.cve_status
				WHERE cod_operacion = '30'
				AND fecha_presentacion BETWEEN cFecInicioW AND cFecFinW
				AND nombre_arch LIKE cTipoP || '%'
				
				SELECT TRIM(descripcion)
				INTO cTpoCta
				FROM bdidomi:dom_tipo_cta
				WHERE tipo_cta = cTipoCtaCod;
				
				SELECT TRIM(vchrnombrecorto)
				INTO cBancDest
				FROM bdinteg:si_bancos
				WHERE banco = cBancDestCod;
				
				IF cStat_val = '01' THEN
					LET cCodResp = '32';
					LET cCausaRech = "";
				ELIF cStat_val = '02' THEN
					LET cCodResp = '31';
				ELIF cStat_val = '03' OR cStat_val = '00' THEN
					LET cCodResp = "";
					LET cCausaRech = "";
				END IF;
				
				IF cCodResp = '31' THEN
					SELECT dev.descripcion 
					INTO cCausaRech
					FROM bdidomi:dom_cce_detalle AS det,bdidomi:dom_cat_devoluciones AS dev 
					WHERE clave_rastreo = cClave_Rastreo
					AND cod_operacion = '31'
					AND det.motivo_dev = dev.motivo_dev;
				END IF;
				
				LET mImp2 = cImp / 100;				
				LET	cFechPresFinR = TRIM(SUBSTR(cFechPresS, 7, 2) || '/' || SUBSTR(cFechPresS, 5, 2) || '/' || SUBSTR(cFechPresS, 1, 4));
				
				RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, mImp2, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cCodRet = '02606'; -- ERROR EN LA GENERACION DEL REPORTE POR TIPO DE PROCESO: FALTAN FECHA INICIO Y/O FECHA FINAL
			EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
			RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
		END IF;	
	ELSE
		LET cCodRet = '02608'; -- TIPO DE OPERACION NO VALIDA PARA LA GENERACION DE REPORTES ARCHIVO 30 - VALORES 1 o 4
		EXECUTE PROCEDURE bdidomi:sp_ObtenerMensajeError(cCodRet) INTO cCodRet2, cDescError;
		RETURN cCodRet, TRIM(cDescError), cFechPresFinR, cNomArch, cNomOrd, cServ, cRef, cImp, cCtaDest, cSec, cTpoCta, cBancDest, cStatus, cCausaRech, cCodResp;
	END IF;	
END
END PROCEDURE
DOCUMENT
'AUTOR: Clemente Angulo Ballardo',
'DESCRIPCION: Procedimiento que genera el reporte de los archivos codigo 30, ya sean presentados o recibidos',
'FECHA: 13/08/2009',
'VERSION: 20090813.1730',
'BD: Bdidomi',

'MODIFICO: Cesar Valdez Figueroa',
'DESCRIPCION: para que regresara la descrimcion del codigo 31',
'FECHA: 10/11/2009',
'VERSION: 20091110.1200',
'BD: Bdidomi';

CREATE PROCEDURE "informix".sp_domi_buscararchivo(p_Ruta VARCHAR(100), p_NombreArchivo VARCHAR(50))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(1); ---Bandera   *** V > Existe el Archivo en la Ruta, *** F > No existe el Archivo

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE bBandera				CHAR(1);
	DEFINE sCadSql				LVARCHAR(500);
	DEFINE sLinea				VARCHAR(50);
	
	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;

	---INICIALIZACIONES
	LET sCadSql				= "";
	LET bBandera			= "F";
	LET sLinea				= "";

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret,NULL;
    END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET iSqlErr
		IF iPaso NOT IN (4,5,6) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret,NULL;
		END IF;
	END EXCEPTION WITH RESUME;


	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_BuscarArchivo.out";
	--TRACE ON;

	LET v_cod_ret = '00000';

	IF (p_Ruta = "") OR (p_Ruta  IS NULL) THEN
		RETURN "00450", NULL;
	END IF

	IF (p_NombreArchivo = "") OR (p_NombreArchivo  IS NULL) THEN
		RETURN "00451", NULL;
	END IF

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_busca_archivo') THEN
		DROP TABLE dom_tmp_busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE dom_tmp_busca_archivo
	(linea LVARCHAR(50));

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.bus
	LET iPaso = 1;
	LET sCadSql = 'ls ' || TRIM(p_Ruta) || ' > ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus';
	SYSTEM sCadSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET iPaso = 2;
	LET sCadSql = 'echo "LOAD FROM ' || TRIM(p_Ruta) || cFechaArchivoOUT|| '.bus' || ' INSERT INTO dom_tmp_busca_archivo" > '|| TRIM(p_Ruta) || cFechaArchivoOUT|| '.sql';
	SYSTEM sCadSql;

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET iPaso = 3;
	--Produccion
	LET sCadSql = '/ifxsif01/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--Desarrollo
	--LET sCadSql = '/informix/bin/dbaccess  bdidomi ' || TRIM(p_Ruta) || cFechaArchivoOUT||'.sql > '||TRIM(p_Ruta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	SYSTEM sCadSql;
	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BARRER  LA TABLA DE TRABAJO Y BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea
		INTO sLinea
		FROM dom_tmp_busca_archivo

		IF sLinea = p_NombreArchivo THEN
			LET bBandera = "V";
			EXIT FOREACH;
		END IF;
	END FOREACH;
	
	LET iPaso = 4;	
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.bus';
	SYSTEM sCadSql;

	LET iPaso = 5;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.sql';
	SYSTEM sCadSql;	

	LET iPaso = 6;
	LET sCadSql = 'rm ' || TRIM(p_Ruta) ||cFechaArchivoOUT||'.out';
	SYSTEM sCadSql;	
	
	DROP TABLE dom_tmp_busca_archivo;

	RETURN v_cod_ret, bBandera;
END;
--##############################################################################
--## Procedimiento   : sp_Domi_BuscarArchivo
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para buscar un archivo en una ruta proporcionada
--##############################################################################
END PROCEDURE;