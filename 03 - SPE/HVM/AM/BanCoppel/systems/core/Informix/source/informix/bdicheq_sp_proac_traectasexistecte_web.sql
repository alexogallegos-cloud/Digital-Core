CREATE PROCEDURE "informix".sp_proac_traectasexistecte_web(pCuenta CHAR(11),pNum_Cte CHAR(9),pTarjeta CHAR (20),pRegistro smallint)
Returning CHAR(5),CHAR(20),CHAR(40),CHAR(10),CHAR(10),CHAR(1),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR (20),CHAR(10);
--cuenta,tipo de cuenta,fecha de inscripcion,fecha de cancelacion y status

DEFINE vcodret 						CHAR(5);
DEFINE vsqlerr,iExiste,iCteBusq		INTEGER;
DEFINE cCta_Eje 					CHAR(20);
DEFINE cProducto					CHAR(15);
DEFINE cDescripProd					CHAR(100);
DEFINE cNCuentas					CHAR(10);
DEFINE cStatus_cta					CHAR(1);
DEFINE cApell_Paterno,cApell_Materno CHAR(50);
DEFINE cNombres,cRfc 				 CHAR(50);
DEFINE iCiclo				 		INTEGER;
DEFINE iNCuentas 					Smallint;
DEFINE dFecha_alta,dFecha_canc		DATE;
DEFINE iLongitudCliente             Smallint;


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
        let vcodret = vsqlerr;
        Return vcodret,cCta_Eje,cDescripProd,dFecha_alta,dFecha_canc,cStatus_cta,
		cApell_Paterno,cApell_Materno,cNombres,cRfc,pNum_Cte,cNCuentas With Resume;
      END IF;
	END EXCEPTION;

   --SET DEBUG FILE TO "/informix/sp_PROAC_TraeCuentasExistentes.out";
   --TRACE ON;

	LET vcodret = "00000";
	LET cCta_Eje = "";
	LET cProducto = "";
	LET iExiste = 0;
	LET dFecha_alta = "01/01/1950";
	LET dFecha_canc = "01/01/1950";
	LET cStatus_cta = "";
	LET cDescripProd = "";
	LET cApell_Paterno = "";
	LET cApell_Materno = "";
	LET cNombres = "";
	LET iCteBusq = 0;
	LET cRfc = "";
	let iCiclo = 0;
	LET iNCuentas = 0;
	LET cNCuentas = "0";
    LET iLongitudCliente = 0;
	
    SET ISOLATION TO DIRTY READ;	
    SET LOCK MODE TO WAIT 3;
	
	--Obtengo el valor longitud del numero de cliente		
	SELECT Trim(valor)
	INTO iLongitudCliente 
	FROM bdinteg:si_param 
	WHERE empresa = '001' 
	AND descripcion = ('longitud cliente'); 
	--Se formatea el # de cliente por si envian cadena incompleta
	Let pNum_Cte = lpad(Trim(pNum_Cte),iLongitudCliente,'0');        

	-- Consulta por Tarjeta 
	IF Not pTarjeta = "" Then
		Select {+INDEX(sc_tarjeta ix_tarjeta2)} 
		cuenta
		Into pCuenta
		From sc_tarjeta
		Where  empresa = '001' and num_tarjeta = pTarjeta;
	End If;
	
	-- Consulta por Cuenta 	
	IF NOT TRIM(pCuenta) = '' THEN
		
		IF (Select 1 FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = pCuenta AND status_cta <> '2')> 0 THEN
			
			Select cuenta,'PROAC_'||trim(producto),num_cte Into cCta_Eje, cProducto, pNum_Cte
			From sc_maechq WHERE empresa = '001' AND cuenta = pCuenta 	AND status_cta <> '2';
		ELSE
			LET vcodret = '08308';
			Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),dFecha_alta,dFecha_canc,NVL(cStatus_cta,"")
			,NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,NVL(iCiclo,0) ;
		End If;
	END IF;
	-- Fin Consulta por Cuenta 

	IF iCteBusq = 0 THEN
		LET iCteBusq = 1;
		Select  trim(apell_paterno),trim(apell_materno),trim(nombre1) || ' ' || trim(nombre2) ,rfc
		Into cApell_Paterno,cApell_Materno,cNombres,cRfc
		From bdinteg:si_cliente
		Where numcte = pNum_Cte;
	End IF;
	
 -- TRAE CUENTAS POSIBLES A INSCRIPCION PROAC POR CLIENTE 
 IF (SELECT count(cuenta) From sc_maechq WHERE num_cte = pNum_Cte  AND cuenta = (CASE WHEN pCuenta = "" THEN cuenta else cCta_Eje END) AND status_cta <> '2')>0 THEN
	  ForEach
		 Select cuenta,'PROAC_'||trim(producto) Into cCta_Eje,cProducto
		 From sc_maechq
		 Where num_cte = pNum_Cte
		 AND cuenta = (case when pCuenta = "" then cuenta else cCta_Eje END)
		 And status_cta <> '2'
		

		Select count(cta_eje) into iNCuentas
		FROM sc_proac
		Where cta_eje = cCta_Eje;
		LET cNCuentas = iNCuentas;

		Select 1 Into iExiste
		From sc_param
		Where codparam = trim(cProducto);
		LET cProducto = trim(cProducto);

		If iExiste = 1 THEN
			LET iExiste = 0;

			Select nombre Into cDescripProd
			From sc_producto
			Where producto = substr(cProducto,7,4);

			If cProducto Is Null THEN
			Continue ForEach;
			End IF;

			Select fecha_alta,fecha_canc,status_cta
			Into dFecha_alta,dFecha_canc,cStatus_cta
			from sc_proac
			Where cta_eje = cCta_Eje
			And secuencia = (Select Max(secuencia) From sc_proac Where cta_eje = cCta_Eje);
			LET iExiste = 1;
			LET iCiclo = iCiclo + 1;
			
			
			
			IF iCiclo <= pRegistro THEN
				-- PAGINACION
				CONTINUE FOREACH;
			END IF;
			
			
			
			Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),nvl(dFecha_alta,"01/01/1950"),nvl(dFecha_canc,"01/01/1950"),NVL(cStatus_cta,"")
						  ,NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,cNCuentas With Resume;
		Else
			If iExiste = 0 or iExiste Is Null THEN
				Continue ForEach;
			End IF;
		End If;
		
		LET cProducto = "";
		LET cDescripProd = "";
	  End ForEach
  ELSE
	LET vcodret = '00001';
	Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),nvl(dFecha_alta,"01/01/1950"),nvl(dFecha_canc,"01/01/1950"),NVL(cStatus_cta,"")
						  ,NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,cNCuentas;
  END IF;
  -- TRAE CUENTAS NO EXISTENTES AL PROAC PERO INSCRITAS POR CLIENTE 
  IF (Select count(cta_eje) From sc_proac Where status_cta = '1' And num_cte = pNum_Cte)>0 THEN
		FOREACH
			Select cta_eje Into cCta_Eje
			From sc_proac
			Where status_cta = '1'
			And num_cte = pNum_Cte

			Select 'PROAC_'||trim(producto) Into cProducto
			From sc_maechq
			where empresa = '001'
			And cuenta = cCta_eje;

			Select 1 into iExiste
			From sc_fechas
			Where trim(cProducto) not in (select  codparam from sc_param Where substr(codparam,1,6) = 'PROAC_');
			LET cProducto = trim(cProducto);

			Select count(cta_eje) into iNCuentas
			FROM sc_proac
			Where cta_eje = cCta_Eje;
			LET cNCuentas = iNCuentas;


			IF iExiste = 1 THEN
				LET iExiste = 0;

				Select nombre Into cDescripProd
				From sc_producto
				Where producto = substr(cProducto,7,4);

				If cProducto Is Null THEN
					Continue ForEach;
				End IF;

				Select fecha_alta,fecha_canc,status_cta
				Into dFecha_alta,dFecha_canc,cStatus_cta
				from sc_proac
				Where cta_eje = cCta_Eje
				And status_cta = '1';
				LET iCiclo = iCiclo + 1;


				IF iCiclo <= pRegistro THEN
				-- PAGINACION
					CONTINUE FOREACH;
				END IF;

				Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),nvl(dFecha_alta,"01/01/1950"),nvl(dFecha_canc,"01/01/1950"),NVL(cStatus_cta,""),
				NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,cNCuentas With Resume;
			ELSE
				IF iExiste = 0 or iExiste Is Null THEN
					Continue ForEach;
				End IF;
			END IF;
			LET cProducto = "";
			LET cDescripProd = "";
		END FOREACH
	END IF;

END
END PROCEDURE
DOCUMENT
    'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Calcular La fecha que recibe de parametro un considerando el aÃ±o biciesto',
					'Y da la fecha_hoy y la fecha proximo aÃ±o el formato 01 de enero de 2009',
	'FECHA		: Febrero 2009',
	'VERSION	: 200902',
    'BD			: BDICHEQ',
	'Modificion : Armando Mercado F',
	'DESCRIPCION: Se modifico para obtener la longitud del num. cte. y formatear el numero de cliente',
	'FECHA		: Julio 2009',
	'VERSION	: 20090716',
	'BD         : BDICHEQ',
	'Modificion : Martin Eduardo Mirada',
	'DESCRIPCION: Se modifico para que no regrese las cuentas con status cancelada y que no puedan ser aperturadas o ligadas',
	'FECHA		: Febrero 2011',
	'VERSION	: 20110209',
    'BD			: BDICHEQ',    
	'Modificion : Martin Eduardo Mirada',
	'DESCRIPCION: Se modifico para que cuando se consulte por No. de Cuenta o No. de Tarjeta solo debe regresar la cuenta consultada',
	'FECHA		: Febrero 2011',
	'VERSION	: 20110215',
    'BD			: BDICHEQ';

CREATE PROCEDURE "informix".sp_obten_info_cancelacion_web(pEmpresa CHAR(3),pNumCta CHAR(20),pNumCte CHAR(20))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(40) AS cBancoOrdenante,
			CHAR(18) AS cCuentaCLABEOrdenante,
			CHAR(40) AS cBancoReceptor,
			CHAR(18) AS cCuentaCLAVEReceptor,
			CHAR(30) AS cFolioSolicitud;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 				CHAR(5);
DEFINE  cBancoOrdenante			CHAR(40);
DEFINE  cCuentaCLABEOrdenante	CHAR(18);
DEFINE  cBancoReceptor			CHAR(40);
DEFINE  cCuentaCLAVEReceptor	CHAR(18);
DEFINE  cFolioSolicitud			CHAR(30);
DEFINE  iSqlErr					INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 				= '00000';
LET cBancoOrdenante			= '';
LET cCuentaCLABEOrdenante	= '';
LET cBancoReceptor			= '';
LET cCuentaCLAVEReceptor	= '';
LET cFolioSolicitud			= '';
LET iSqlErr					= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_obten_info_cancelacion.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCta,'') <> '' AND NVL(pNumCte,'') <> '' THEN

	SELECT cta_ordenante, bco_ordenante, cta_receptora, bco_receptor, folio_solicitud
		INTO cCuentaCLABEOrdenante,cBancoOrdenante,cCuentaCLAVEReceptor,cBancoReceptor,cFolioSolicitud
		FROM bdicheq:"informix".sc_portacec_solicitud
		WHERE empresa = pEmpresa AND num_cte = pNumCte AND cta_ordenante = pNumCta
            and folio_solicitud = (
            SELECT max(folio_solicitud)
               FROM bdicheq:"informix".sc_portacec_solicitud
               WHERE empresa = pEmpresa 
                 AND num_cte = pNumCte
                 AND cta_ordenante = pNumCta
                  AND clave_sentido in ('1', '0')
                   And estatus_portabilidad = '1'
            );

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01289';
		ELSE
			SELECT descripcion INTO cBancoOrdenante FROM bdinteg:"informix".si_bancos
			WHERE cvecesif = cBancoOrdenante;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '01289';
			ELSE
				SELECT descripcion INTO cBancoReceptor FROM bdinteg:"informix".si_bancos
				WHERE cvecesif = cBancoReceptor;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '01289';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01288';
	END IF
	RETURN cCodRet,cBancoOrdenante,cCuentaCLABEOrdenante,cBancoReceptor,cCuentaCLAVEReceptor,cFolioSolicitud;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Datos',
'001289 - No existe el Cliente',
'001288 - Parametros incompletos',
'DESCRIPCION: obtener la informaciÃ³n de la orden de cancelaciÃ³n de transferencia',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo GÃ³mez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_marcacancelacionadn_web(pEmpresa char(3), pCuenta char(20))

--DATOS A REGRESAR---
RETURNING
char(5)  as Cod_Ret	--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         char(5);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00000";
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Actualiza bandera para identificar que cliente solicito su portabilidad a otro banco
    update  bdisolic:ss_adn_solicitudcuenta set flag_porta=1
    where empresa= pEmpresa and num_solicitud=pCuenta;
    
    RETURN Vcod_Ret; 

END PROCEDURE;