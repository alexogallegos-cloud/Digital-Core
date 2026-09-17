CREATE PROCEDURE "informix".sp_proac_buscaporapellidocliente (pApellidoPaterno CHAR(60),pApellidoMaterno CHAR(60),iRegistro  INTEGER)
RETURNING CHAR(5), CHAR(9), CHAR (200), CHAR(20),INTEGER;
--Regresa el número de cliente. nombre o razon social y rfc

DEFINE cCodRet		CHAR(5);
DEFINE cNumCte		CHAR(9);
DEFINE cNombreCte	CHAR(200);
DEFINE cRFC			CHAR(20);
DEFINE iSqlerr		INTEGER;

BEGIN
    ON EXCEPTION SET iSqlerr
      IF iSqlerr <> 0 THEN
         let cCodRet = iSqlerr;
         Return cCodRet, cNumCte, cNombreCte, cRFC, iRegistro;
      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_Proac_BuscaPorApellidoCliente.out";
--TRACE ON;

LET cCodRet = '00000';
LET cNumCte = '';
LET cNombreCte = '';
LET cRFC = '';
	
	IF pApellidoMaterno IS NULL AND pApellidoPaterno IS NULL OR iRegistro IS NULL THEN
		LET cCodRet = '08382';
		Return cCodRet, cNumCte, cNombreCte, cRFC, iRegistro;
	END IF
	FOREACH 
		SELECT SKIP iRegistro FIRST 5
		numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre, rfc 
		INTO cNumCte,cNombreCte,cRFC
	    FROM bdinteg:si_cliente
		WHERE apell_paterno = TRIM(pApellidoPaterno)
		AND apell_materno  = TRIM(pApellidoMaterno)
		
		IF cNumCte IS NULL OR cNombreCte IS NULL OR cRFC IS NULL THEN
			LET cCodRet = '08383';
		END IF
		LET iRegistro = iRegistro + 1;
		Return cCodRet, TRIM(cNumCte), TRIM(cNombreCte), TRIM(cRFC), iRegistro WITH RESUME;
	END FOREACH;
	
	
END 
END PROCEDURE
DOCUMENT
'Autor: Antonio Bastidas',
'Descripcion: Se creo proceso para consulta por apellido de clientes',
'Version: 20090701.1731',
'Fecha: 01/07/2009',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_calc_proximoanio(pFecha_hoy date)
Returning CHAR(5),DATE,CHAR(30),CHAR(30);

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE dFecha_prox_ano DATE;
DEFINE vAno,vAno2,vAno3		INTEGER;
DEFINE vMes,vMes2 	INTEGER;
DEFINE vDia,vDia2		Char(2);
DEFINE cNueFecha_hoy,cNueFecha_Prox CHAR(30);
DEFINE cMesNuevo CHAR(10);
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,dFecha_prox_ano,cNueFecha_hoy,cNueFecha_Prox;
      END IF;
END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_Calc_ProximoAnio.out";
--TRACE ON;
LET dFecha_prox_ano = '01-01-1900';
LET vAno3 = YEAR(pFecha_hoy);
LET vAno = MOD (YEAR(pFecha_hoy),4);
LET vMes = MONTH(pFecha_hoy);
LET vDia = LPAD(day(pFecha_hoy),2,0);

	IF vAno = 0 And vMes < 3 THEN
	IF vMes = 2 AND vDia = '29' THEN
		LET vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 365;
	END IF;
		let vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 366;
	ELSE
		LET vcodret = "00000";
		LET dFecha_prox_ano = pFecha_hoy + 365;
	END IF;
	LET vAno2 = YEAR(dFecha_prox_ano);
	LET vMes2 = MONTH(dFecha_prox_ano);
	LET vDia2 = LPAD (day(dFecha_prox_ano),2,0);


	If vMes = 1 Then
		LET cMesNuevo = 'Enero';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;

	End If;
	If vMes = 2 Then
		LET cMesNuevo = 'Febrero';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 3 Then
		LET cMesNuevo = 'Marzo';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 4 Then
		LET cMesNuevo = 'Abril';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 5 Then
		LET cMesNuevo = 'Mayo';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 6 Then
		LET cMesNuevo = 'Junio';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 7 Then
		LET cMesNuevo = 'Julio';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 8 Then
		LET cMesNuevo = 'Agosto';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 9 Then
		LET cMesNuevo = 'Septiembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 10 Then
		LET cMesNuevo = 'Octubre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 11 Then
		LET cMesNuevo = 'Noviembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0)||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;
	If vMes = 12 Then
		LET cMesNuevo = 'Diciembre';
		LET cNueFecha_hoy = LPAD(vDia,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno3;
		LET cNueFecha_Prox = LPAD(vDia2,2,0) ||' de '||Trim(cMesNuevo)||' de '||vAno2;
	End If;

	Return vcodret,dFecha_prox_ano,cNueFecha_hoy,cNueFecha_Prox;
END
END PROCEDURE
DOCUMENT

    'AUTOR      : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Calcular La fecha que recibe de parametro un año más considerando el año bisiesto',
	              'Y da la fecha_hoy y la fecha proximo año en el formato 01 de enero de 2009',
    'FECHA      : Febrero de 2009',
	'VERSION    : 200902',
	'MODIFICO   : JOSE ALMEIDA',
	'DESCRIPCION: SE CAMBIO DE MAyo A Mayo',
	'FECHA      : JULIO 10 de 2009',
    'BD         : BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_consultarincripcioncuentaproac(pCuenta CHAR(20))
Returning CHAR(5);

DEFINE vcodret 			CHAR(5);
DEFINE vsqlerr			INTEGER;


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret with resume;

      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ConsultarIncripcionCuentaProac";
--TRACE ON;
	LET vcodret = "00000"; -- si no existe manda 00000
	IF EXISTS (SELECT cta_eje FROM  bdicheq:sc_proac WHERE TRIM(sc_proac.cta_eje) = TRIM(pCuenta)) THEN----   si existe la cuenta manda 10000
		LET vcodret = "10000"; -- --- si existe la cuenta manda 10000
	END IF;
	Return vcodret;
END
END PROCEDURE
DOCUMENT
'Autor   		: César Valdéz Figueroa',
'DESCRIPCION		: Este procedimiento busca si existe una cuenta X en el campo cuenta_eje de la tabla PROAC',
'FECHA			: 01 de Julio 2009',
'VERSION		: 20090701',
'BD				: BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_reportectasinsocanc(pIndicador CHAR(1),pSucursal CHAR(4),pFechaIni CHAR(10),pFechaFin CHAR(10),pTipoCta CHAR(4),pStatus INTEGER)
Returning CHAR(5),CHAR(4),CHAR(20),DATE,CHAR(20),CHAR(4),CHAR(20),CHAR(20),CHAR(10);

DEFINE vcodret 						CHAR(5);
DEFINE vsqlerr,iExiste,iCteBusq		INTEGER;
DEFINE cCta_Eje,cNumCte,cTpoOpe		CHAR(20);
DEFINE dFecha_alta,dFecha_canc 		CHAR(10);
DEFINE iActiva,iCancelada,iBloqueada CHAR (1);
DEFINE cSucursal,cProducto			CHAR (4);
DEFINE cCuentaPROAC 				CHAR(20);
DEFINE cStatus_Cta					CHAR(1);
DEFINE cDescripcionStatus			CHAR(10);
DEFINE iSecuencia					INTEGER;
DEFINE iBand    					INTEGER;

BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with resume;

      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ReporteCtasInsOCanc.out";
--TRACE ON;
	LET vcodret = "00000";
	LET iSecuencia = 0;
	LET cCta_Eje = "";
	LET dFecha_alta = "";
	LET iActiva = "";
	LET iCancelada = "";
	LET iBloqueada = "";
	LET cSucursal = "";
	LET cProducto = "";
	LET cNumCte = "";
	LET cTpoOpe = "";
	LET dFecha_canc = "";
	LET cCuentaPROAC = "";
	LET cStatus_Cta = "";
	LET cDescripcionStatus = "";
	LET iBand = 0;
	If pIndicador = "1" THEN
		IF pStatus = 0 THEN
			LET iActiva = "1";
			LET iCancelada = "";
			LET iBloqueada = "3";
		ELIF pStatus = 1 OR pStatus = 4 THEN
			LET iActiva = "1";
			LET iCancelada = "";
			LET iBloqueada = "";
		ELIF pStatus = 3 THEN
			LET iActiva = "";
			LET iCancelada = "";
			LET iBloqueada = "3";
		END IF;
		LET cTpoOpe = "INSCRITAS";
		LET cTpoOpe= Trim(cTpoOpe);
	End if;
	If pIndicador = "2" THEN
		LET iActiva = "";
		LET iCancelada = "2";
		LET iBloqueada = "";
		LET cTpoOpe = "CANCELADAS";
		LET cTpoOpe= Trim(cTpoOpe);
	End if;
	IF pFechaIni Is Null Or pFechaIni = "" Then
		LET pFechaIni = "01/01/1900";
	End if;

	IF pFechaFin Is Null Or pFechaFin = ""  Then
		LET pFechaFin = "01/01/2999";
	End if;

	If pIndicador = "1" THEN----------         INSCRITAS
	  ForEach
		Select Distinct (pro.cta_eje),mae.producto,pro.sucursal,pro.fecha_alta,pro.num_cte ,pro.fecha_canc,pro.cuenta,pro.status_cta
		Into cCta_Eje,cProducto,cSucursal,dFecha_alta,cNumCte,dFecha_canc,cCuentaPROAC,cStatus_Cta
		From sc_proac as pro
		Inner Join sc_maechq as mae On mae.cuenta = pro.cta_eje
		Where pro.status_cta in (iActiva ,iCancelada,iBloqueada)
		And pro.sucursal =  CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTipoCta = "" THEN mae.producto  ELSE pTipoCta END
		And pro.fecha_alta >= trim(pFechaIni)
		And pro.fecha_alta <= trim(pFechaFin)
		Order by pro.sucursal,pro.fecha_alta,mae.producto,pro.num_cte ,pro.cta_eje
		---definir el status 1- Activa  3 - Bloqueada   Secuencia > 1 y Estado = 1 -- Reinscrita
		LET cDescripcionStatus = '';
		IF cStatus_Cta = 1 OR cStatus_Cta = 4 THEN ---si el status es 1
			LET cDescripcionStatus = 'INSCRITA';
			---Obtener la secuencia de la cuenta eje  si la tiene
			SELECT MAX(secuencia) into iSecuencia FROM sc_proac WHERE cta_eje = cCta_Eje;
			IF iSecuencia > 1 THEN ---si el status es 1 y la secuencia es  > a 1 es reincrita
				LET cDescripcionStatus = 'REINSCRITA';
			END IF;
			LET iBand = 0;
			IF  pStatus = 1 THEN --inscrita
				IF cDescripcionStatus = 'REINSCRITA' THEN
					LET iBand = 1;
				END IF;
			ELIF pStatus = 4 THEN --- reinscrita
				IF cDescripcionStatus = 'INSCRITA' THEN
					LET iBand = 1;
				END IF;
			END IF;
		ELSE---si no  el status es 3 bloqueada
			LET cDescripcionStatus = 'BLOQUEADA';
		END IF;
		IF iBand <> 1 THEN
			Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with Resume;
		END IF;
		LET iBand = 0;
	  End ForEach
	End if;
	If pIndicador = "2" THEN------------------------        CANCELADAS
	  ForEach
		Select Distinct (pro.cta_eje),mae.producto,pro.sucursal,pro.fecha_alta,pro.num_cte ,pro.fecha_canc,pro.cuenta
		Into cCta_Eje,cProducto,cSucursal,dFecha_alta,cNumCte,dFecha_canc,cCuentaPROAC
		From sc_proac as pro
		Inner Join sc_maechq as mae On mae.cuenta = pro.cta_eje
		Where pro.status_cta in (iActiva ,iCancelada,iBloqueada)
		And pro.sucursal =  CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTipoCta = "" THEN mae.producto  ELSE pTipoCta END
		And pro.fecha_canc >= trim(pFechaIni)
		And pro.fecha_canc <= trim(pFechaFin)
		Order by pro.sucursal,pro.fecha_alta,mae.producto,pro.num_cte ,pro.cta_eje
		LET dFecha_alta = dFecha_canc;
	  Return vcodret,cSucursal,cCta_Eje,dFecha_alta,cNumCte,cProducto,cTpoOpe,cCuentaPROAC,cDescripcionStatus with Resume;
	  End ForEach
	End if;
END
END PROCEDURE
DOCUMENT

    'AUTOR      : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Mostrar las cuentas PROAC Activas & Bloqueadas  si el parametro de entrada es "pIndicador = 1"',
					', si el parametro de entrada es "pIndicador = 2" entonces te muestra las canceladas. La Informacion la Pasa a un rpt',
					', Junto a esto se puede hacer un filtrado por sucursal, rango de fechas (y/o) producto de la cuenta',
    'FECHA		: Febrero 2009',
	'VERSION	: 200902',
    'BD			: BDICHEQ',
	'Modifico   : Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Se modifico el formato de la fecha el cual, en algunos servidores no funcionaba correctamente "MDY"',
    'FECHA		: Abril 2009',
	'VERSION	: 200904',
    'BD			: BDICHEQ',
	'Modifico   : César Valdéz Figueroa',
	'DESCRIPCION: Se modifico para que el reporte regresara unos datos mas como son cuenta PROAC y el estatus en lo que es cuentas inscritas',
	'             en cuentas canceladas solo regresara la cuenta PROAC, ademas se agrego un filtrado por status',
    'FECHA		: 30 de Junio 2009',
	'VERSION	: 20090630',
    'BD			: BDICHEQ';

CREATE PROCEDURE "informix".sp_proac_reportemovpremiosredondeo(pSucursal CHAR(4),pFechaIni CHAR(10),pFechaFin CHAR(10), pTpoCta CHAR(4))
Returning CHAR(5),CHAR(4),CHAR(4),CHAR(20),CHAR(20),DATE,MONEY(14,2),MONEY(14,2),MONEY(14,2),SMALLINT;
--cuenta,tipo de cuenta,fecha de inscripcion,fecha de cancelacion y status

DEFINE vcodret 						CHAR(5);
DEFINE vsqlerr,iExiste,iCteBusq		INTEGER;
DEFINE cCuenta_Eje,cNumCte,	cCuenta_PROAC		CHAR(20);
DEFINE cProducto,cSucursal			CHAR (4);
DEFINE cFecha_alta					CHAR (10);
DEFINE cTransaccCargoPROAC,cTransaccPremioPROAC,cReg1 SMALLINT;
DEFINE sPromedio		 		MONEY(14,2);
DEFINE mAhorro, mPremio				MONEY(14,2);

  


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         Return vcodret,cSucursal,cProducto,cNumCte,cCuenta_Eje,cFecha_alta,mAhorro,mPremio,sPromedio,cReg1;
		 
      END IF;
	END EXCEPTION;
--SET DEBUG FILE TO "/tmp/sp_PROAC_ReporteMovPremiosRedondeo.out";
--TRACE ON;
	LET vcodret = "00000";
	LET cCuenta_Eje = "";
	LET cProducto = "";
	LET cNumCte = "";
	LET cSucursal = "";
	LET cTransaccCargoPROAC = 0;
	LET cTransaccPremioPROAC = 0;
	LET sPromedio = 0;
	LET cReg1 = 0;
	LET cFecha_alta = "01/01/1900";
	LET mAhorro = 0;
	LET mPremio = 0;
	LET cCuenta_PROAC = "";
	
Select valor Into cTransaccCargoPROAC From sc_param Where codparam = 'PROACTRANSACCCARGO';
Select valor Into cTransaccPremioPROAC From sc_param Where codparam = 'PROACABONOPREMIO';

-- movimientos de los cargos por redondeo
	FOREACH --With Hold
	
		Select Distinct (pro.cta_eje),pro.num_cte,pro.sucursal,pro.fecha_alta,mae.producto,pro.cuenta
		Into cCuenta_Eje,cNumCte,cSucursal,cFecha_alta,cProducto,cCuenta_PROAC
		From sc_proac AS pro
		Inner Join sc_maechq  AS mae ON cta_eje = mae.cuenta
		Where pro.sucursal = CASE WHEN pSucursal = "" THEN pro.sucursal  ELSE pSucursal END
		And mae.producto = CASE WHEN pTpoCta = "" THEN mae.producto  ELSE pTpoCta END
		And pro.status_cta in ('1', '3')
	
		LET cReg1 = 0;
		LET mAhorro = 0;
		LET mPremio = 0;
		
		-- movimientos de los abonos por Ahorrado
		
		Select NVL(Sum(monto_tot),0.00),COUNT(cuenta)
		Into mAhorro,cReg1
		From sc_movhis 
		Where empresa = '001'
		And cuenta=   cCuenta_Eje
		And fech_alt >=  pFechaIni
		And fech_alt <= pFechaFin
		And transacc = cTransaccCargoPROAC;


		-- movimientos de los abonos por premio

		Select NVL(Sum(monto_tot),0.00)
		Into mPremio
		From sc_movhis 
		Where empresa = '001'
		And cuenta=   cCuenta_PROAC
		And fech_alt >= pFechaIni
		And fech_alt <= pFechaFin
		And transacc =  cTransaccPremioPROAC;
		
		IF cReg1 = 0 THEN
			LET sPromedio = 0;
			Continue ForEach;
		ELSE
			LET sPromedio = mAhorro / cReg1 ;
		END IF
		Return vcodret,cSucursal,cProducto,cNumCte,cCuenta_Eje,cFecha_alta,mAhorro,mPremio,sPromedio,cReg1 With Resume;
	End ForEach
END
END PROCEDURE
DOCUMENT
    
    'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Llenar los datos del reporte de movimientos de premios y ahorros del cliente PROAC"',
    'FECHA		: Febrero de 2009',
	'VERSION	: 200902',
    'BD			: BDICHEQ',
	'Modificó	: Jesus Antonio Bastidas Lopez, Abigail Vasavilbazo Cañedo',
	'DESCRIPCION: Se valido status cuenta y se trajo premios de cuenta proac',
    'FECHA		: Marzo de 2009',
	'VERSION	: 200903',
    'BD			: BDICHEQ';

Create procedure "informix".sp_proac_traeparametros()
returning char(5),char(100),money,money,money,money,integer,integer,money,money,char(7),money (14,2);
-- Declaración de variables:
DEFINE iSqlerr,iPorcPremio1,iPorcPremio4 			 			 INTEGER;
DEFINE cCodret										 			 CHAR(5);
DEFINE cRangoEdad									 			 CHAR(7);
DEFINE i,iMax,ProductoAux 							 			 INTEGER;
DEFINE Prod,Recb  									 			 CHAR(300);
DEFINE ProductoAuxstr, Producto			   			 			 CHAR(20);
DEFINE cProdProac						   			 			 CHAR(4);
DEFINE mCompMayor, mPremioMaximo, mMontoAhorrado1 	 			 MONEY;
DEFINE mMontoAhorrado4, mMtoPremio1,mMtoPremio4,mMontoPromedio 	 MONEY;

begin
   on exception set iSqlerr
      if iSqlerr <> 0 then
         let cCodret = iSqlerr;
		 LET Recb = "";
         return cCodret,Recb,mCompMayor,mPremioMaximo,mMontoAhorrado1,mMontoAhorrado4,
				iPorcPremio1,iPorcPremio4,mMtoPremio1,mMtoPremio4,cRangoEdad,mMontoPromedio;
      end if;
	end exception;

	--SET DEBUG FILE TO "/tmp//hass/sp_PROAC_TraeParametros.out";
	--TRACE ON;
	
	-- Asignación de variables:
	
	LET iSqlerr =0;
	LET cCodret ='00000';
	LET i = 1 ;
	LET Producto = "";
	LET ProductoAux =0;
	LET mCompMayor = 0.00;
	LET mPremioMaximo = 0.00;
	LET mMontoAhorrado1 = 0.00;
	LET mMontoAhorrado4 = 0.00;
	LET iPorcPremio1 = 0;
	LET iPorcPremio4 = 0;
	LET mMtoPremio1 = 0.00;
	LET mMtoPremio4 = 0.00;
	LET mMontoPromedio = 0.00;
	LET cRangoEdad = "";
	LET cProdProac = "";
	
	Select Count(valor) Into  iMax
	From sc_param 
	Where substr(codparam,1,6) = 'PROAC_' ;
	If  i <= iMax then
		ForEach	 
		Select valor Into ProductoAux
		From sc_param 
		Where substr(codparam,1,6) = 'PROAC_'
		LET ProductoAuxstr = ProductoAux;
		LET producto = 'Producto'||i;
		LET producto = producto;
			Select nombre into Prod
			From sc_producto pr
			Where pr.producto = ProductoAuxstr;
			LET Prod = Prod;
			if i = 1 then
				LET Recb = nvl(trim(Prod),'');
			end if;
			if i > 1 and i < iMax  then
				LET Recb = nvl(trim(Recb),'') ||', '|| nvl(trim(Prod),'') ;		
			end if;
			if i = iMax  then
				LET Recb = nvl(trim(Recb),'') ||' Y '|| nvl(trim(Prod),'') ;		
			end if;
			LET i = i +1;
		End Foreach	
		Select valor Into mCompMayor From sc_param where codparam = 'PROACCOMMAYOR';
		Select valor Into mMontoPromedio From sc_param where codparam = 'PROACPROMREDONDEO';
		Select valor Into mPremioMaximo From sc_param where codparam = 'PROACMAXPREMIO';
		Select valor Into mMontoAhorrado1 From sc_param where codparam = 'PROACMTOAHO1-3';
		Select valor Into mMontoAhorrado4 From sc_param where codparam = 'PROACMTOAHO4-12';
		Select valor Into iPorcPremio1 From sc_param where codparam = 'PROACPORCPREM1-3';
		Select valor Into iPorcPremio4 From sc_param where codparam = 'PROACPORCPREM4-12';
		-- Se añade parametro para el proyecto de Parametrizacion del PROAC
		Select valor Into cProdProac From sc_param where codparam = 'PROACPRODUCTO';
		LET cProdProac = cProdProac;
	If mMontoAhorrado1 Is Not Null And mMontoAhorrado4 Is Not Null And  iPorcPremio1 Is Not Null And  iPorcPremio1 Is Not Null Then
		LET mMtoPremio1 = (mMontoAhorrado1 * iPorcPremio1 )/100;
		LET mMtoPremio4 = (mMontoAhorrado4 * iPorcPremio4 )/100;
	End If;
	Select edad_minima ||'-'||edad_maxima Into cRangoEdad From sc_producto pr where pr.producto = cProdProac;
	return cCodret,Recb,mCompMayor,mPremioMaximo,mMontoAhorrado1,mMontoAhorrado4,
		   iPorcPremio1,iPorcPremio4,mMtoPremio1,mMtoPremio4,cRangoEdad,mMontoPromedio ;
	End if	

	End
	End Procedure
	DOCUMENT	
	'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Genera La validacion de las cuentas PROAC, respecto a las cuenta eje maximo de cuentas ',
					' por numero de cliente y si el producto de la cuenta es participante.',
	'FECHA		: Febrero 2009',
	'MODIFICO   : Clemente Angulo Ballardo',
	'DESCRIPCION: Se parametriza el producto del PROAC',	
	'VERSION	: 20100504.1050',
	'BD			: BDICHEQ';

CREATE PROCEDURE "informix".sp_registraencabezadoedocta
		( pEmpresa 			CHAR(3),
		  pUsuario 			CHAR(8),
		  pCuenta			CHAR(20),
		  pProducto			CHAR(45),
		  pNumTarjeta		CHAR(16),
		  pClabe			CHAR(18),
		  pFechaIni			DATE,
		  pFechaFin			DATE,
		  pSaldoAnterior	MONEY(16,2),
		  pDepositos		MONEY(16,2),
		  pInteresesPagados	MONEY(16,2),
		  pRetiros			MONEY(16,2),
		  pOtrosCargos		MONEY(16,2),
		  pIvaOtrosCargos	MONEY(16,2),
		  pSaldoCorte		MONEY(16,2),
		  pSaldoPromedio	MONEY(16,2),
		  pRetencionISR		MONEY(16,2),
		  pInteresesNetos	MONEY(16,2),
		  pDias				INTEGER,
		  pTasaBruta		MONEY(16,2),
		  pNumCte			VARCHAR(20),
		  pNombreCte		VARCHAR(107),
		  pNumExterior		VARCHAR(10),
		  pNumInterior		VARCHAR(10),
		  pCalle			VARCHAR(30),
		  pColonia			VARCHAR(30),
		  pCiudad			VARCHAR(30),
		  pEstado			VARCHAR(30),
		  pCodPostal		VARCHAR(5),
		  pRFC				VARCHAR(13),
		  pCURP				VARCHAR(20),
		  pFechaAlta		DATE,
		  pSucursal			VARCHAR(40),
		  pRetMesAnt		MONEY(16,2),
		  pCongMesAnt		MONEY(16,2),
		  pSaldoRetenido	MONEY(16,2),
		  pSaldoCongelado	MONEY(16,2),
		  pSobreGiro		MONEY(16,2),
		  ptotOtrosCargos	MONEY(16,2),
		  pGat 				DECIMAL(9,4),
		  pTotretirosefe	money(16,2))
		  
		  
RETURNING  CHAR(5), INTEGER;

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE iConsultaMaxima   INTEGER;
LET cCodRet 			= '00000';
LET iSqlErr				= 0;
LET iConsultaMaxima      = 0;

	--SET DEBUG FILE TO "/tmp/sp_RegistraEncabezadoEdoCta.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, iConsultaMaxima;
		END IF;
	END EXCEPTION;

	

	set isolation to dirty read;

	--DELETE {+ INDEX(bdicheq:vedocta idx_usu1)} FROM bdicheq:vedocta
	--WHERE cod_usuario = pUsuario;

	--DELETE {+ INDEX(bdicheq:vedoctamov idx_usu)} FROM bdicheq:vedoctamov
	--WHERE cod_usuario = pUsuario;

	SELECT MAX(consulta)
	INTO iConsultaMaxima
	FROM vedocta
	WHERE empresa = pEmpresa
	AND cod_usuario = pUsuario;
	--AND cuenta = pCuenta;
	
	IF iConsultaMaxima is null then
		LET iConsultaMaxima = 1 ;
	else
		LET iConsultaMaxima = iConsultaMaxima + 1;
	end if;	

	
	
	INSERT INTO vedocta
		(empresa, cod_usuario, Cuenta, Producto, tarjeta,Clabe, Fechaini, Fechafin, SaldoAnterior, Depositos,
		InteresesPagados, Retiros, OtrosCargos, IvaOtrosCargos, SaldoCorte,SaldoPromedio, RetencionIsr,
		InteresesNetos, Dias, TasaBruta,NumeroCliente, NombreCliente, NumeroExterior, NumeroInterior, Calle,
		Colonia, Ciudad, Estado, CodigoPostal, Rfc,CURP, FechaAlta, Sucursal,ret_mes_ant, cong_mes_ant,
		sdo_retenido, sdo_cong, sobregiro, consulta, tototroscargos, porcientogat, totretirosefec)
	VALUES
		(pEmpresa,pUsuario,pCuenta,pProducto,pNumTarjeta,pClabe,pFechaIni,pFechaFin,pSaldoAnterior,
		pDepositos,pInteresesPagados,pRetiros,pOtrosCargos,pIvaOtrosCargos,pSaldoCorte,pSaldoPromedio,
		pRetencionISR,pInteresesNetos,pDias,pTasaBruta,pNumCte,pNombreCte,pNumExterior,pNumInterior,
		pCalle,pColonia,pCiudad,pEstado,pCodPostal,pRFC,pCURP,pFechaAlta,pSucursal,pRetMesAnt,pCongMesAnt,
		pSaldoRetenido,pSaldoCongelado,pSobreGiro, iConsultaMaxima,ptotOtrosCargos, pGat, pTotretirosefe);

	IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet, iConsultaMaxima;
END
END PROCEDURE
Document
'DESCRIPCION: Procedimiento que genera el registro para el encabezado de estado de cuenta',
'AUTOR: Antonio Bastidas',
'FECHA: 06 de Enero de 2010',
'VERSION: 20100106.1031',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION: Se agrego validacion para que se obtenga el maximo de la consulta de la cuenta consultada, asi como tambien,  ',
'se agrego para que se regresara al termino del proceso ',
'AUTOR: Hector Bojorquez ',
'FECHA: 02 de Junio de 2010',
'VERSION: 20100602.1631',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION: Se agrego validacion para que se obtenga el maximo de la consulta de la cuenta consultada validando unicamente ',
'                          que la empresa y el usuario sean iguales a los de la consulta en proceso',
'AUTOR: Hector Bojorquez ',
'FECHA: 17 de Junio de 2010',
'VERSION: 20100617.1638',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION:Se agregaron los campos tototroscargos, totretirosefec y porcientogat en el insert a la tabla vedocta',
'AUTOR: Abigail Vasavilbazo Cañedo ',
'VERSION: 20101125.1109';

CREATE PROCEDURE "informix".sp_proac_edocta(pEvalua CHAR(1),pUsuario CHAR(8),pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT, pConsMax INTEGER)
RETURNING CHAR(5),CHAR(3), CHAR(10), CHAR(10), CHAR(20),CHAR(10), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),MONEY(14, 2),MONEY(14, 2),CHAR (10);
	--Declara las variables
	DEFINE vCodRet CHAR(5);
	DEFINE vSqlErr, vIsamErr, iAux INTEGER;
	DEFINE vCiclo SMALLINT;
	DEFINE sTransacAbonoRedondeo,sTransacAbonoPremio CHAR(4);
	DEFINE dFechaMov1 DATE;
	DEFINE dFechaMov,dFecha_canc CHAR(10);
	DEFINE cReferencia CHAR(40);
	DEFINE cDescripcion CHAR(50);
	DEFINE mRedondeo, mPremio, mSaldo, mMonto MONEY(14, 2);
	DEFINE mSaldo1, mSaldo2,mGranTotal,mSdo1,mSdo2 MONEY(14, 2);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cCuentaPROAC,cTransacc CHAR(20);

	--Inicializa las variables
	LET vCodRet = "000";
	LET dFechaMov = "";
	LET creferencia = "";
	LET cDescripcion = "";
	LET mRedondeo = 0;
	LET mPremio = 0;
	LET mSaldo = 0;
	LET vCiclo = 0;
	LET dFechaMov1 = "";
	LET cCuentaPROAC = "";
	LET sTransacAbonoRedondeo = "";
	LET sTransacAbonoPremio = "";
	LET cTransacc = "";
	LET mGranTotal = 0;
	LET mSaldo1 = 0;
	LET mSaldo2 = 0;
	LET mSdo1 = 0;
	LET mSdo2 = 0;
	LET dFecha_canc = '';
	
	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSaldo1,mPremio,
				mSaldo2,mGranTotal,dFecha_canc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_PROAC_edocta.out";
		--TRACE ON;

		--Limpia la tabla de movimientos para el reporte por el numero de usuario
		--Delete From vedoctamov_proac Where  cod_usuario = pUsuario;

		--consulta la cuenta proac y su fecha de cancelacion
		Select cuenta,fecha_canc INTO cCuentaPROAC,dFecha_canc From sc_proac Where cta_eje = pCuenta
		AND secuencia = (Select Max(secuencia)From sc_proac Where cta_eje = pCuenta And status_cta in ('1','3'))
		And status_cta in ('1','3');

		--valida que exista la cuenta proac.
		IF cCuentaPROAC is null THEN
			LET vCodRet = '10100';
			RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSaldo1,mPremio,
				mSaldo2,mGranTotal,dFecha_canc;
		End IF;

		Select valor INTO sTransacAbonoRedondeo From sc_param Where codparam = 'PROACTRANSACCABONO';
		Select valor INTO sTransacAbonoPremio   From sc_param Where codparam = 'PROACABONOPREMIO';
		LET pCuenta = pCuenta;
		LET pFechaInicial = pFechaInicial;
		LET pFechaFinal = pFechaFinal;

		--ciclo de busqueda de movimientos por la transaccion de redondeo y premio
		FOREACH
			SELECT
				mm.num_serial, mm.fech_alt,mm.monto_tot, tr.naturaleza, mm.sdo_cuenta,mm.transacc
			INTO
				iAux, dFechaMov1, mMonto, cNaturaleza, mSaldo,cTransacc
			FROM
				bdicheq:sc_movhis AS mm
				Inner Join  bdinteg:si_transacc AS tr ON mm.transacc = tr.numero
			WHERE
				mm.empresa = pEmpresa AND
				mm.cuenta = cCuentaPROAC  AND
				mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
				mm.cancelad <> "S" AND
				mm.empresa = tr.empresa AND
				mm.transacc = tr.numero  AND
				mm.transacc in (sTransacAbonoRedondeo,sTransacAbonoPremio) AND
				tr.se_emite_edocta = "S"
			ORDER BY
				mm.fech_alt ,
				mm.num_serial

			LET mRedondeo = 0;
			LET mPremio = 0;

			--valida si la transaccion es la de redondeo
			IF cTransacc = sTransacAbonoRedondeo  THEN
				LET mRedondeo = mMonto;
				IF mRedondeo = 0.00 THEN
				Else
					--suma todos los redondeos obtenidos con mSaldo1
					LET mSaldo1 = mSaldo1 + mRedondeo;
					If mSdo1 <> mSaldo1 THEN
						LET mSdo1 = mSaldo1;
						LET mPremio = 0;
						LET mSdo2 = 0;
					Else
						LET mSdo1 = 0.00;
					END IF;
				END IF;
			END IF;

			--valida si la transaccion es la de premio
			IF cTransacc = sTransacAbonoPremio  THEN
				LET mPremio = mMonto;
				IF mPremio = 0.00 THEN
				Else
					--suma todos los premios obtenidos con mSaldo2
					LET mSaldo2 = mSaldo2 + mPremio;
					If mSdo2 <>mSaldo2 THEN
						LET mSdo2 = mSaldo2;
						LET mRedondeo = 0;
						LET mSdo1 = 0;
					Else
						LET mSdo2 = 0.00;
					END IF;
				END IF;

			END IF;

			LET vCiclo = vCiclo + 1;

			-- Valida de donde se mando ejecutar el sistema "S" sucursal "C" Central
			IF pEvalua = 'S' THEN
				-- PAGINACION
				IF vciclo <= pRegistro THEN
					CONTINUE FOREACH;
				END IF;
				IF mSaldo1 > 0.00 Then
					LET mGranTotal = mSaldo + mPremio + mRedondeo;
				END If
				IF mSaldo2 > 0.00 Then
					LET mGranTotal = mSaldo + mPremio + mRedondeo;
				END If
				RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				mSdo2,mGranTotal,dFecha_canc WITH RESUME;
			END IF;

			-- Valida de donde se mando ejecutar el sistema "S" sucursal "C" Central
			IF pEvalua = 'C' THEN
				IF pConsMax = 0 OR pConsMax IS NULL THEN
					LET vCodRet = '00001';					
					RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
							mSdo2,mGranTotal,dFecha_canc;
					EXIT FOREACH;
				END IF;

				--Genera el monto acumulado de la cuenta
				LET mGranTotal = mSaldo + mPremio + mRedondeo;

				--inserta los registros obtenidos.
				Insert Into vedoctamov_proac (empresa,cod_usuario,secuencia,cuenta,fechamov,
				importe_redondeo,saldo_redondeo,importe_premio,saldo_premio,total_acumulado,Fecha_canc, consulta)
				Values (pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				mSdo2,mGranTotal,dFecha_canc, pConsMax);
				--RETURN vCodRet, pEmpresa,pUsuario,vCiclo,cCuentaPROAC,dFechaMov1,mRedondeo,mSdo1,mPremio,
				--mSdo2,mGranTotal,dFecha_canc WITH RESUME;
			END IF;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : JESUS ANTONIO BASTIDAS LOPEZ',
'DESCRIPCION : LLENA SUB-REPORTE DEL ESTADO DE CUENTA PARA PROAC',
'FECHA       : MARZO DE 2009',
'VERSION     : 200903',
'BD          : BDICHEQ',
'CAMBIO      : JESUS ANTONIO BASTIDAS LOPEZ',
'DESCRIPCION : CORRECCION DEL MONTO ACUMULADO DE LA CUENTA EL CUAL NO SE CALCULABA CORRECTAMENTE',
'FECHA       : ABRIL DE 2009',
'CAMBIO      : CÉSAR ANDRÉS DE ANDA ALCÁNTARA',
'DESCRIPCION : CORRECIÓN EN LA VALIDACIÓN DONDE SE MANDA EJECUTAR EL SISTEMA, EN CASO DE SER "C" (CENTRAL)',
'FECHA       : SEPTIEMBRE DEL 2009',
'VERSION     : 200909',
'BD          : BDICHEQ',
'MODIFICO    : ABIGAIL VASAVILBAZO CAÑEDO',
'MODIFICACION: SE AGREGA PARAMETRO DE ENTRADA (PCONSMAX) Y SE ELIMINA CODIGO DE BORRADO DE LA TABLA VEDOCTAMOV_PROAC',                                                        
'FECHA		 : NOVIEMBRE 2010',
'VERSION	 : 20101103.1242';

Create Procedure "informix".sp_nominatotalivacomision( cNombreArchivo           Char(17),
                                                       mValorIva                Money(14,2),
                                                       mValorComisionDispercion Money(14,2) )
Returning Char(3), 
          Char(100), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3), 
          Money(14,3);
          
    --- Realizo   : Martín Valenzuela Ojeda
    --- Proyecto  : Dispercion Nomina BanCoppel
    --- Actividad : Calcula el Total del Iva y de la Comision de Disperción para todos los Empleados que hayan sido Aplicados (status = 1,3)
    --- Fecha     : Abril-2008
    
    Define mImporteTotalAplicado        Money(14,3);
    Define cCodRet                      Char(3);
    Define cMensaje                     Char(100);
    Define iNumeroRegistrosAplicados    Integer ;
    Define mTotaliva                    Money(14,3);
    Define mTotalComision               Money(14,3);
    Define mTotalPagado                 Money(14,3);
    Define mTotalCargo                  Money(14,3);
    Define mTotalNoPagado			    Money(14,3);
    DEFINE  vsqlerr                     Integer ;

    Let cCodRet = '000';
    Let cMensaje = "";
    Let mImporteTotalAplicado = 0;
    Let iNumeroRegistrosAplicados = 0;
    Let mTotaliva = 0;
    Let mTotalComision = 0;
    Let mTotalPagado = 0;
    Let mTotalCargo = 0;
    Let mTotalNoPagado = 0;

    --- Set debug file to "/tmp/sp_nominatotalivacomision.out";
    --- Trace on;

    Begin

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            Let cCodRet = vsqlerr;
            Let cMensaje  = "Error Marcado Por Informix";
            Return cCodRet, cMensaje, null, null, null, null, null;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    If (Trim(cNombreArchivo) <> "") And (mValorIva is not Null Or mValorComisionDispercion is not Null ) Then
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(Count(*),0) 
          Into iNumeroRegistrosAplicados
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And (status = '1' Or status = '3');  /* El valor 1 es de Aplicados y el 3 de Cuentas Bloqueadas */

        --- Let mTotaliva = iNumeroRegistrosAplicados * mValorIva;
        --- Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
        
        Let mTotalComision = iNumeroRegistrosAplicados * mValorComisionDispercion;
        Let mTotaliva = mTotalComision * mValorIva; /* Nueva Forma de Calcular el Iva */
        Let cMensaje = "Calculos de Iva y Comision Efectuados Correctamente";

        /* Se saca el importe abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(sum(importe),0) 
          Into mTotalPagado
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And status = '1';

        /* Se saca el importe No abonado a cuentas */
        Select {+INDEX(bdicheq:sc_nominamovimientos idx_nominamovimientos2)}
               NVL(sum(importe),0) 
          Into mTotalNoPagado
          From bdicheq:sc_nominamovimientos
         Where nombre_archivo = cNombreArchivo
           And status > '1';

        /* Se saca el cargo total, para evaluar el saldo */
        Let mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
    Else
        Let cCodRet = '170';
        Let cMensaje = "Error: Nombre de Archivo No Valido";
        Let mTotaliva = 0;
        Let mTotalComision = 0;
        
        Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
    End If

    Return cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
    
    End
    
End Procedure;