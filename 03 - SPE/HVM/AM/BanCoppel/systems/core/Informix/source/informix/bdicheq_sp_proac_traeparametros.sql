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