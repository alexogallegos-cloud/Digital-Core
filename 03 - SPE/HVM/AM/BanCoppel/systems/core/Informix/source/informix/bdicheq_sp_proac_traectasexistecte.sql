CREATE PROCEDURE "informix".sp_proac_traectasexistecte(pCuenta CHAR(11),pNum_Cte CHAR(9),pTarjeta CHAR (20),pRegistro smallint)
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

   --SET DEBUG FILE TO "/tmp/sp_PROAC_TraeCuentasExistentes.out";
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
		
		IF EXISTS (Select 1 FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = pCuenta AND status_cta <> '2') THEN
			
			Select cuenta,'PROAC_'||trim(producto),num_cte Into cCta_Eje, cProducto, pNum_Cte
			From sc_maechq WHERE empresa = '001' AND cuenta = pCuenta 	AND status_cta <> '2';
		ELSE
			LET vcodret = '08308';
			Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),NVL(dFecha_alta,""),NVL(dFecha_canc,""),NVL(cStatus_cta,"")
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
	
  -- TRAE CUENTAS POSIBLES A INSCRIPCIÃ? PROAC POR CLIENTE 
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
		Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),NVL(dFecha_alta,""),NVL(dFecha_canc,""),NVL(cStatus_cta,"")
					  ,NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,cNCuentas With Resume;
	Else
		If iExiste = 0 or iExiste Is Null THEN
			Continue ForEach;
		End IF;
	End If;
	
	LET cProducto = "";
	LET cDescripProd = "";
  End ForEach
  
  -- TRAE CUENTAS NO EXISTENTES AL PROAC PERO INSCRITAS POR CLIENTE 
  ForEach
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
		And status_cta = '1';
		LET iCiclo = iCiclo + 1;
		IF iCiclo <= pRegistro THEN
				-- PAGINACION
				CONTINUE FOREACH;
		END IF;
		Return vcodret,NVL(cCta_Eje,""),NVL(cDescripProd,""),NVL(dFecha_alta,""),NVL(dFecha_canc,""),NVL(cStatus_cta,"")
				  ,NVL(cApell_Paterno,""),NVL(cApell_Materno,""),NVL(cNombres,""),NVL(cRfc,""),pNum_Cte,cNCuentas With Resume;
	Else
	
		If iExiste = 0 or iExiste Is Null THEN
			Continue ForEach;
		End IF;
	End If;
		LET cProducto = "";
		LET cDescripProd = "";
	End ForEach

END
END PROCEDURE
DOCUMENT
    'AUTOR		: Jesus Antonio Bastidas Lopez',
	'DESCRIPCION: Calcular La fecha que recibe de parametro un aÃ±Ã¡considerando el aÃ±isiesto',
					'Y da la fecha_hoy y la fecha proximo aÃ±n el formato 01 de enero de 2009',
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

CREATE PROCEDURE "informix".sp_marcafecharetiro( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vcomienza        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    
    DEFINE vfechconmovhis           CHAR(10);
    DEFINE vfechconmovhisold        CHAR(10);
    DEFINE vfechconmovhisold2       CHAR(10);
    DEFINE vfechconmovhisold3       CHAR(10);
    DEFINE vctamin                  CHAR(20);
    DEFINE vctamax                  CHAR(20);
    DEFINE vcuenta                  CHAR(20);
    DEFINE vfecha_ultima_transacc   DATE;
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    
    LET vfechconmovhis         = '';
    LET vfechconmovhisold      = '';
    LET vfechconmovhisold2     = '';
    LET vfechconmovhisold3     = '';
    LET vctamin                = '';
    LET vctamax                = '';
    LET vcuenta                = '';                    
    LET vfecha_ultima_transacc = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcafecharetiro.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcafecharetiro.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor 
      INTO vfechconmovhisold2
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor 
      INTO vfechconmovhisold3
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld3';
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM sc_maechq;    
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta BETWEEN vctamin AND vctamax
           AND status_cta <> '2'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET ven_transacc = 1;
        END IF;
        
        SELECT MAX(mov.fech_alt)
          INTO vfecha_ultima_transacc
          FROM sc_movdia mov,
               bdinteg:si_transacc trx
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.cancelad <> 'S'
           AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
           AND trx.numero = mov.transacc
           AND trx.naturaleza = 'C';
           
        IF vfecha_ultima_transacc is null THEN
        
            SELECT {+INDEX(sc_movhis idx_movhisnew4)}
                   MAX(mov.fech_alt)
              INTO vfecha_ultima_transacc
              FROM sc_movhis mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pempresa
               AND mov.cuenta = vcuenta
               AND mov.fech_alt >= vfechconmovhis
               AND mov.cancelad <> 'S'
               AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
               AND trx.numero = mov.transacc
               AND trx.naturaleza = 'C';
               
            IF vfecha_ultima_transacc is null THEN
            
                SELECT {+INDEX(sc_movhis_old movhis1)}
                       MAX(mov.fech_alt)
                  INTO vfecha_ultima_transacc
                  FROM sc_movhis_old mov,
                       bdinteg:si_transacc trx
                 WHERE mov.empresa = pempresa
                   AND mov.cuenta = vcuenta
                   AND mov.fech_alt >= vfechconmovhisold
                   AND mov.fech_alt < vfechconmovhis
                   AND mov.cancelad <> 'S'
                   AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                   AND trx.numero = mov.transacc
                   AND trx.naturaleza = 'C';
                   
                IF vfecha_ultima_transacc is null THEN
                
                    SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
                           MAX(mov.fech_alt)
                      INTO vfecha_ultima_transacc
                      FROM sc_movhis_old2 mov,
                           bdinteg:si_transacc trx
                     WHERE mov.empresa = pempresa
                       AND mov.cuenta = vcuenta
                       AND mov.fech_alt >= vfechconmovhisold2
                       AND mov.fech_alt < vfechconmovhisold
                       AND mov.cancelad <> 'S'
                       AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                       AND trx.numero = mov.transacc
                       AND trx.naturaleza = 'C';
                       
                    IF vfecha_ultima_transacc is null THEN
                
                        SELECT {+INDEX(sc_movhis_old3 movhis1_old3)}
                               MAX(mov.fech_alt)
                          INTO vfecha_ultima_transacc
                          FROM sc_movhis_old3 mov,
                               bdinteg:si_transacc trx
                         WHERE mov.empresa = pempresa
                           AND mov.cuenta = vcuenta
                           AND mov.fech_alt >= vfechconmovhisold3
                           AND mov.fech_alt < vfechconmovhisold2
                           AND mov.cancelad <> 'S'
                           AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                           AND trx.numero = mov.transacc
                           AND trx.naturaleza = 'C';
                           
                        IF vfecha_ultima_transacc is null THEN
                            
                            SELECT {+INDEX(sc_movhis_old4 movhis1_old4)}
                                   MAX(mov.fech_alt)
                              INTO vfecha_ultima_transacc
                              FROM sc_movhis_old4 mov,
                                   bdinteg:si_transacc trx
                             WHERE mov.empresa = pempresa
                               AND mov.cuenta = vcuenta
                               AND mov.fech_alt < vfechconmovhisold3
                               AND mov.cancelad <> 'S'
                               AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                               AND trx.numero = mov.transacc
                               AND trx.naturaleza = 'C';
                            
                        END IF;
             
                    END IF;
                    
                END IF;
                
            END IF;
            
        END IF;
        
        IF vfecha_ultima_transacc is not null OR vfecha_ultima_transacc <> '' THEN
            UPDATE sc_maechq
               SET fecultret = vfecha_ultima_transacc
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;

        IF vcontador2 >= 7500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vfecha_ultima_transacc = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;