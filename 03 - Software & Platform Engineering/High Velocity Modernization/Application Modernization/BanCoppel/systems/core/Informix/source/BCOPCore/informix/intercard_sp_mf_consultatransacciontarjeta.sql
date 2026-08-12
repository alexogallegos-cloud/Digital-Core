create procedure "informix".sp_mf_consultatransacciontarjeta(pnumTarj varchar(16), p_Fecha DATETIME YEAR TO FRACTION (5))
	RETURNING 
	VARCHAR(6)						AS CodRetorno,
	VARCHAR(7)						AS Secuencia,		--SECUENCIA
	VARCHAR(2)						AS CodISO,     	--CODIGO ISO
	VARCHAR(4)						AS GiroNeg,			--COD. GIRO DE NEGOCIO
	VARCHAR(16)						AS Ntarjeta,		--NUM TARJETA
	VARCHAR(9)						AS TipoTransaccion,	---TIPO DE TRANSACCION (SE OBTIENE DEL CAMPO "EN LINEA")
	VARCHAR(4)						AS Formato, 		--FORMATO
	VARCHAR(2)						AS Pais,            --PAIS
	VARCHAR(2)						AS CodTrans, 		--COD. TRANSACCION
	VARCHAR(4)						AS FechaExpTarj, 		--FECHA DE EXPEDICION DE TARJETA
	VARCHAR(5)						AS Fechamov,		---FECHA MOVIMIENTO
	VARCHAR(8)						AS HoraMovi,       --HORA MOVIMIENTO
	VARCHAR(3)						AS Moneda,			--MONEDA
	VARCHAR(12)						AS Referencia, 	--REFERENCIA
	DECIMAL(19,4)					AS MONTO,			--MONTO 
	VARCHAR(40)						AS InfReceptor,    --INFRECEPTOR
	VARCHAR(4)						AS IDReceptor,		 --ID RECEPTOR
	VARCHAR(16)						AS IDTerminal,		 --ID TERMINAL
	DECIMAL(19,4)					AS MontoRealrevfzda, --MONTO REAL DEL REVERSO
	VARCHAR(7)						AS SecuenciaOrg,     --SECUENCIA ORIGINAL
	VARCHAR(1)						AS PreAutorizacion,     --PREAUTORIZACION
	VARCHAR(1)						AS MovReservado, 	--MOVIMIENTO RESERVADO
	VARCHAR(7)						AS FechaApliCentral, --FECHA APLICACIO
	VARCHAR(1)						AS EsNacional,       --Es Nacional
	VARCHAR(70)						AS Motivo, 		--MOTIVO
	DECIMAL(19,4)					AS MontoComi,		--MONTO COMISION
	VARCHAR(1)						AS CobroComision,		---COBRO COMISION
	VARCHAR(1)						AS MovConciliado,       --MOVIMIENTO CONCILIADO
	VARCHAR(4)						AS FechaLocalTransaccion,		--FECHA LOCAL TRANSACCION
	VARCHAR(4)						AS fechacaptura,		---FECHA DE CAPTURA
	MONEY(14,2)						AS MontoChBk, 		--MONTO CASH BACK
	DATETIME YEAR TO FRACTION(5)	AS FechaHoraAuto, 	--FECHA/ HORA AUTORIZACION
	VARCHAR(2)						AS ProdInd,		--ProdInd
	VARCHAR(6)						AS HoraLocalTransaccion,		--HoraLocalTransaccion
	VARCHAR(5)						AS codigocentral,		---CODIGO CENTRAL
	VARCHAR(1)						AS EnLinea;		--EnLinea

	--DEFINICION DE VARIABLES
	DEFINE SQL_ERR      		INTEGER;
    DEFINE ISAM_ERR     		INTEGER;
    DEFINE ERROR_INFO   		VARCHAR(80);
    DEFINE P_COD_RET   			VARCHAR(6);
	DEFINE vsCodISO      		VARCHAR(2);
	DEFINE vsNumTarjeta  		VARCHAR(16);
	DEFINE dMonto        		DECIMAL(19,4);
	DEFINE vsInfoReceptor 		VARCHAR(40);
	DEFINE vsFechaTransa  		VARCHAR(5);
	DEFINE dtFechaAuto   		DATETIME YEAR TO FRACTION(5);
	DEFINE vsMotivo      		VARCHAR(70);
	DEFINE vsMovReser    		VARCHAR(1);
	DEFINE vsGiroNeg     		VARCHAR(4);
	DEFINE vsSecuencia   		VARCHAR(7);
	DEFINE vsReferencia  		VARCHAR(12);
	DEFINE mMontoCB      		MONEY(14,2);
	DEFINE vsFormato     		VARCHAR(4);
	DEFINE vsCodTransa   		VARCHAR(2);
	DEFINE dMontoComision 		DECIMAL(19,4);
	DEFINE vsFechamov 			VARCHAR(5);
	DEFINE vsHoraMovi 			VARCHAR(8);
	DEFINE vsMoneda 			VARCHAR(3);
	DEFINE vsFechaApliCentral 	VARCHAR(7);
	DEFINE vsPais 				VARCHAR(2);
	DEFINE vsIDReceptor 		VARCHAR(4);
	DEFINE vsIDTerminal 		VARCHAR(16);
	DEFINE vsSecuenciaOrg 		VARCHAR(7);
	DEFINE vsPreautorizacion 	VARCHAR(1);
	DEFINE vsEsNacional 		VARCHAR(1);
	DEFINE vsCobroComision 		VARCHAR(1);
	DEFINE dMontoRealrevfzda 	DECIMAL(19,4);
	DEFINE vscodigocentral 		VARCHAR(5); 
	DEFINE vsfechacaptura 		VARCHAR(6);
	DEFINE sTipoTransaccion		CHAR(9);
	DEFINE sFechaExpTarj		VARCHAR(4);
	DEFINE sPreAutorizacion		VARCHAR(1);
	DEFINE sMovConciliado		VARCHAR(1);
	DEFINE sProdInd				VARCHAR(2);
	DEFINE sHoraLocalTransaccion VARCHAR(6);
	DEFINE sEnLinea				 VARCHAR(1);
	
	--ASIGNACION DE VARIABLES
	LET P_COD_RET = "00000";
	LET vsCodISO ="";      
	LET vsNumTarjeta ="";  
	LET dMonto =0;       
	LET vsInfoReceptor ="";
	LET vsFechaTransa = "";   
	LET vsMotivo ="";      
	LET vsMovReser ="";   
	LET vsGiroNeg ="";     
	LET vsSecuencia ="";   
	LET vsReferencia ="";  
	LET mMontoCB =0;     
	LET vsFormato ="";    
	LET vsCodTransa ="";
	LET dMontoComision=0;
	LET pnumTarj=pnumTarj;
	LET dtFechaAuto= "";
	LET vsFechamov=""; 
	LET vsHoraMovi=""; 
	LET vsMoneda ="";
	LET vsFechaApliCentral ="";
	LET vsPais ="";
	LET vsIDReceptor="";
	LET vsIDTerminal="";
	LET vsSecuenciaOrg="";
	LET vsPreautorizacion="";
	LET vsEsNacional="";  
	LET vsCobroComision="";
	LET dMontoRealrevfzda =0;
	LET vscodigocentral="";
	LET vsfechacaptura="";
	LET sTipoTransaccion = "";
	LET sFechaExpTarj = "";
	LET sPreAutorizacion = "";
	LET sMovConciliado = "";
	LET sProdInd = "";
	LET sHoraLocalTransaccion = "";
	LET sEnLinea = "";

	BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR
		LET P_COD_RET    = SQL_ERR;
	RETURN P_COD_RET, vsSecuencia, vsCodISO, vsGiroNeg, vsNumTarjeta, sTipoTransaccion, vsFormato, vsPais, vsCodTransa, sFechaExpTarj, vsFechamov
			, vsHoraMovi, vsMoneda, vsReferencia, dMonto, vsInfoReceptor, vsIDReceptor, vsIDTerminal, dMontoRealrevfzda, vsSecuenciaOrg
			, sPreAutorizacion, vsMovReser, vsFechaApliCentral, vsEsNacional, vsMotivo, dMontoComision, vsCobroComision, sMovConciliado
			, vsFechaTransa, vsfechacaptura, mMontoCB, dtFechaAuto, sProdInd, sHoraLocalTransaccion, vscodigocentral, sEnLinea;
    END EXCEPTION;
	
	---SET DEBUG FILE TO "/tmp/has/sp_mf_ConsultaTransaccionTarjeta.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} {+INDEX(intercard:movimiento idx_movimientonew1a)}
		FIRST 1 m.Secuencia,m.CodigoISO,m.CodGiroNeg,m.NumTarjeta
		,CASE WHEN m.enlinea= 1 THEN 'Normal'  WHEN m.enlinea=2 THEN 'Stan On' WHEN m.enlinea=3 THEN 'Host Down' END
		,m.Formato,m.pais,m.CodTran,m.FechaExpTarj,m.fechamov,m.horamov,m.moneda,m.Referencia,m.Monto,m.InfReceptor,m.idreceptor
		,m.idterminal,m.montorealrevfzda,m.secuenciaorig,m.PreAutorizacion,m.MovReversado,m.fechaapliccentral,m.esnacional,m.Motivo        
		,m.MontoComision,m.cobrocomision,m.MovConciliado,m.FechaLocalTransaccion,m.fechacaptura,m.MontoCashBack,m.FechaHoraInAuth
		,m.ProdInd, m.HoraLocalTransaccion ,m.codigocentral, m.enlinea
	INTO vsSecuencia, vsCodISO, vsGiroNeg, vsNumTarjeta, sTipoTransaccion, vsFormato, vsPais, vsCodTransa, sFechaExpTarj, vsFechamov
	, vsHoraMovi, vsMoneda, vsReferencia, dMonto, vsInfoReceptor, vsIDReceptor, vsIDTerminal, dMontoRealrevfzda, vsSecuenciaOrg
	, sPreAutorizacion, vsMovReser, vsFechaApliCentral, vsEsNacional, vsMotivo, dMontoComision, vsCobroComision, sMovConciliado
	, vsFechaTransa, vsfechacaptura, mMontoCB, dtFechaAuto, sProdInd, sHoraLocalTransaccion, vscodigocentral, sEnLinea
	FROM intercard:movimiento m 
	WHERE m.FechaHoraInAuth = p_Fecha AND m.NumTarjeta = pnumTarj;

	RETURN P_COD_RET, vsSecuencia, vsCodISO, vsGiroNeg, vsNumTarjeta, sTipoTransaccion, vsFormato, vsPais, vsCodTransa, sFechaExpTarj, vsFechamov
	, vsHoraMovi, vsMoneda, vsReferencia, dMonto, vsInfoReceptor, vsIDReceptor, vsIDTerminal, dMontoRealrevfzda, vsSecuenciaOrg
	, sPreAutorizacion, vsMovReser, vsFechaApliCentral, vsEsNacional, vsMotivo, dMontoComision, vsCobroComision, sMovConciliado
	, vsFechaTransa, vsfechacaptura, mMontoCB, dtFechaAuto, sProdInd, sHoraLocalTransaccion, vscodigocentral, sEnLinea;
	
END
	 --======================================================================     
	 -- AUTOR : Mohamed Carreon
	 -- FECHA : 3 Septiembre 2009.                                              
	 -- VERSION: 20090903.                                                  
	 -- BD: Intercard.                                                     
	 -- DESCRIPCION: CONSULTA EL MOVIMIENTO DE UNA TRANSACCION ESPECIFICO DE UN TARJETA
 --======================================================================
END PROCEDURE;