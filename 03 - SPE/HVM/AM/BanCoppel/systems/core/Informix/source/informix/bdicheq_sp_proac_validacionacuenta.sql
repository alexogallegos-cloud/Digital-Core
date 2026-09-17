Create procedure "informix".sp_proac_validacionacuenta(pNum_cte CHAR(20),pCuentaEje CHAR(20),pAltaoBaja CHAR(1))
returning char(5),char(50),char(100),money,money,money,money,Char (3),Char (3),money,
		  money,char(7),Char (3),char(100),char(100),Char(10),Char(10),Char(50),CHAR(30),CHAR(30);

-- Declaración de variables:
DEFINE iSqlerr,iContador,iContadorMx INTEGER;
DEFINE cCodret,cCodret2,cCodret3	 CHAR(5);
DEFINE iMaxCtas,iNCuentas,iExiste 	 INTEGER;
DEFINE cCtaclabe   					 CHAR(50);
DEFINE iEdad,iEdadMin,iEdadMax,iBandera		 Integer;
DEFINE cProducto,cRecValor 			 CHAR(20);
DEFINE Recb2,cTipoCta,cNomCte		 CHAR(100);
DEFINE mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
	   mMtoPremio12,mMtoPremio42		 MONEY;
DEFINE cRangoEdad2					 CHAR (7);
DEFINE cEdadCTe,cPorcPremio12,cPorcPremio42		 CHAR (3);
DEFINE cFechaInsc,cFechaProx 			CHAR(10);
DEFINE cUbicacion 			CHAR(50);
DEFINE cFecha1,cFecha2 CHAR(30);
DEFINE mMontoPromedio  MONEY (14,2);

begin
   on exception set iSqlerr
      if iSqlerr <> 0 then
         let cCodret = iSqlerr;
         return cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
      end if;
	end exception;

	--SET DEBUG FILE TO "/tmp/sp_PROAC_ValidacionACuenta.out";
	--TRACE ON;
	
	-- Asignación de variables:
	LET iSqlerr =0;
	LET cCodret ='00000';
	LET cCodret2 ='00000';
	LET cCodret3 ='00000';
	LET iMaxCtas = 0;
	LET iNCuentas = 0;
	LET iExiste = 0;
	LET cProducto = "";
	LET cRecValor = "";
	LET cCtaclabe = "";
	LET iEdad = 0;
	LET iEdadMin = 0;
	LET iEdadMax = 0;
	LET iContador = 1;
	LET iContadorMx = 1;
	LET iBandera = 0;
	LET mCompMayor2 = 0.00;
	LET mPremioMaximo2 = 0.00;
	LET mMontoAhorrado12 = 0.00;
	LET mMontoAhorrado42 = 0.00;
	LET cPorcPremio12 = 0;
	LET cPorcPremio42 = 0;
	LET mMtoPremio12 = 0.00;
	LET mMtoPremio42 = 0.00;
	LET cRangoEdad2 = "";
	LET Recb2 = "";
	LET cEdadCte = 0;
	LET cTipoCta = "";
	LET cNomCte ="";
	LET cUbicacion = "";
	LET cFechaInsc = "";
	LET cFechaProx = "";
	LET cFecha1 = "";
	LET cFecha2 = "";
	
	
	
	IF pAltaoBaja = 'A' Then 
	IF TRIM(pNum_cte) = ""  OR TRIM(pNum_cte) = 0 THEN
		LET cCodret = "90000";
		LET cCtaclabe = "Datos nulos";
		RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
	END IF;
	
	IF TRIM(pCuentaEje) = ""  OR TRIM(pCuentaEje) = 0 THEN
		LET cCodret = "90000";
		LET cCtaclabe = "Datos nulos";
		RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2;
	END IF;
	
	--Consulta cuantas cuentas por cliente puede tener el PROAC
	Select valor Into iMaxCtas From sc_param Where codparam = 'PROACMAXCTAS';

	Select Count(cuenta) Into iNCuentas
	From sc_proac
	Where num_cte = pNum_cte
	And status_cta in ('1','3') ;
		IF	iNCuentas >= iMaxCtas  THEN
			LET iExiste = 0;
			LET cCodret = "90001";
			LET cCtaclabe = "Cliente Con El Maximo De Cuentas Permitidas";
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2;
		END IF;

	--Valida que no exista la cuenta eje en alguna otra cuenta PROAC
	Select 1 Into iExiste
	From sc_proac
	Where cta_eje = pCuentaEje
	And status_cta in ('1','3');
		IF	iExiste = 1  THEN
			LET iExiste = 0;
			LET cCodret = "90002";
			LET cCtaclabe = "Cuenta Eje ya Tiene Cuenta PROAC";
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2;
		END IF;
	
	
	
	End if;
	--Consulta los datos que va a heredar de la cuenta eje
	Select  'PROAC_'|| trim(producto)
	Into cProducto
	From sc_maechq Mae
	Where mae.cuenta = pCuentaEje;

	--Consulta y valida el producto para verificar si participa o no en el PROAC
	LET cProducto = trim(cProducto) ;
	Select valor,descripcion Into cRecValor,cUbicacion From sc_param Where codparam = trim(cProducto);
	LET cRecValor = cRecValor;
		IF cRecValor is null THEN
			LET cCodret = "90003";
			LET cCtaclabe = "El Producto No Es Participante";
			IF cUbicacion IS NULL OR  cUbicacion = "" Then
			LET cUbicacion = 'C:\OFI\Reportes\';
		End IF;
			RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
		,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
			LET iExiste = 0;
		END IF;
	Call sp_PROAC_TraeParametros() Returning 
cCodret2,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,mMontoPromedio;
	LET cRangoEdad2 = nvl(cRangoEdad2,"18-85");
	LET iContadorMx = LENGTH(cRangoEdad2);
	Select (fecha_hoy -Fecha_nac)/365 Into iEdad
	From bdinteg:si_ctepf , bdicheq:sc_fechas  
	Where numcte = pNum_cte;
	LET cEdadCte = iEdad;
	For iContador = 1 to iContadorMx 
	
		If substr(cRangoEdad2,icontador,1) = '-' And iBandera = 0 Then
			LET iEdadMin = substr(cRangoEdad2,1,icontador-1);
			LET iEdad = iEdad;
			If iEdad < iEdadMin Then
				LET cCodret = "90004";
				LET cCtaclabe = "La Edad Del Cliente Es Menor A la del Programa";
				LET iBandera = 1;
				RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
				cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
				,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
				Exit For;
			End if;
			LET iEdadMax = substr(cRangoEdad2,icontador+1);
			LET iEdad = iEdad;
				If iEdad > iEdadMax Then
					LET cCodret = "90005";
					LET cCtaclabe = "La Edad Del Cliente Es Mayor a la del Programa";
					LET iBandera = 2;
					RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
					cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte,cFechaInsc
					,cFechaProx,cUbicacion,cFecha1,cFecha2 ;
					Exit For;
				End if;
		End if;
	End For;
	If  iBandera <>1 And  iBandera <> 2 Then
	
	LET cCodret = "00000"; 
	LET cCtaclabe = "Los datos del cliente y cuenta estan OK";

	Select Trim(nombre1) || ' ' || Trim(nombre2)  ||' ' || Trim(apell_paterno) || ' ' || Trim(apell_materno)
	Into cNomCte
	From bdinteg:si_cliente where numcte = pNum_cte;
	
	Select trim(nombre) 
	Into cTipoCta
	From sc_producto pr 
	Where pr.producto = substr(cproducto,7);

	Select fecha_hoy Into cFechaInsc
	From sc_fechas 
	Where Empresa = '001';
	End If;
	Call sp_PROAC_Calc_ProximoAnio(cFechaInsc) returning cCodret3,cFechaProx,cFecha1,cFecha2;
	RETURN cCodret,cCtaclabe,Recb2,mCompMayor2,mPremioMaximo2,mMontoAhorrado12,mMontoAhorrado42,
		cPorcPremio12,cPorcPremio42,mMtoPremio12,mMtoPremio42,cRangoEdad2,cEdadCte,cTipoCta,cNomCte
		,cFechaInsc,cFechaProx,cUbicacion,cFecha1,cFecha2 with Resume;
	End
	End Procedure
	DOCUMENT
	
	'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Genera La validacion de las cuentas PROAC, respecto a las cuenta eje maximo de cuentas ',
					' por numero de cliente y si el producto de la cuenta es participante.',
	'FECHA		: Febrero 2009',
	'VERSION	: 200902',
	'BD			: BDICHEQ';

CREATE PROCEDURE "informix".obtienecuentaclabe (sEmpresa CHAR(3), sNumCte CHAR(20), sNumCuenta CHAR(20))
    RETURNING CHAR(5), CHAR(20);

--DEFINICIÓN DE VARIABLES
    DEFINE iSqlErr            INTEGER;
    DEFINE sCodRet        CHAR(5);
    DEFINE sClabe           CHAR(20);

--INICIALIZACIÓN DE VARIABLES
    LET sCodRet = "000";
    LET sClabe = "";

--SET DEBUG FILE TO '/tmp/ObtieneCuentaClabe.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET sCodRet = iSqlErr;
                        RETURN sCodRet, sClabe;
                END IF;
        END EXCEPTION;

        SELECT cuenta_clabe INTO sClabe
        FROM sc_maechq
        WHERE num_cte = sNumCte
        AND cuenta = sNumCuenta;
        
        IF sClabe = '' or sClabe is null THEN
                LET sCodRet = "001"; -- NO ESISTE LA CUENTA CLABE
                RETURN sCodRet, sClabe;
        END IF;

        RETURN sCodRet, sClabe;

    END;
--*************************************************************************
--| Procedimiento   : ObtieneCuentaClabe
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Junio de 2009
--| Descripción     : Realiza una consulta en la tabla sc_maechq para 
--|				      obtener la cuenta clabe del cliente cuando se le
--|					  otorga una cuenta efectiva.
--*************************************************************************
END PROCEDURE;