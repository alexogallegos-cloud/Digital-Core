create procedure "informix".sp_consultatrancred(pfolio char(16),pfecha char(10), pnumero char(20), pimporte money(16,2))
RETURNING 	CHAR(5) 	as codret,
			CHAR(200)	as mensaje,
			CHAR(16) 	as folio_suc,
			CHAR(4) 	as suc_origen,
			CHAR(40)    as nombre_suc,
			MONEY(16,2)	as monto,
			date		as fecha_mov,
			DATETIME HOUR TO FRACTION(3) 	as hora_mov,
			CHAR(8)		as usuario,
			CHAR(1)		as reversado,
			integer		as registros;

	--Declaracion de variables
    DEFINE cCodRet          CHAR(5);
	DEFINE vMensaje			CHAR(200);
	DEFINE iSqlErr          INTEGER;
	DEFINE vFolio_Suc       CHAR(16);
	DEFINE vSuc_Origen      CHAR(4);
	DEFINE mMonto			MONEY(16,2);
	DEFINE dFecha_mov		DATE;
	DEFINE dHora_mov		DATETIME HOUR TO FRACTION(3);
	DEFINE vNombreSuc      CHAR(40);
	DEFINE vUsuario			CHAR(8);
	DEFINE vReversado		CHAR(1);

		--declaracion de variabels de trabajo
	DEFINE vcodSP 			CHAR(5);
	DEFINE dfechaSistema	date;
	DEFINE dfechaSp			date;
	DEFINE mMontoSP			MONEY(16,2);
	DEFINE vfechaValidar	CHAR(8);
	DEFINE vtipoconsulta	CHAR(1);
	DEFINE dFecha1			DATE;
	DEFINE dFecha2			DATE;
	DEFINE mImporte1 		MONEY(16,2);
	DEFINE mImporte2 		MONEY(16,2);
	DEFINE iContador		integer;
	DEFINE iregistros 		integer;

	--SET DEBUG FILE TO "/informixuc7/perifericos/sp_consultatrancred.out";
    --TRACE ON;

	---inicializacion de variables
	LET cCodRet = '00000';
	LET vMensaje 		= "PROCESO REALIZADO SATISFACTORIAMENTE";
	LET vFolio_Suc		= "";
	LET vSuc_Origen		= "";
	LET mMonto			= 0.00;
	LET dFecha_mov		= CURRENT;
	LET dhora_mov		= CURRENT HOUR TO FRACTION(3);
	LET vUsuario		= "";
	LET vReversado		= "";
	LET vfechaValidar 	= "";
	LET vtipoconsulta	= "";
	LET iContador		= 0;
	LET iregistros 		= 0;
	LET vNombreSuc="";


	---Inicializaciond e variables  de trabajo
	LET vcodSP = "00000";


    BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					LET vMensaje = "Error de Informix";
                    RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
									dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                END IF;
        END EXCEPTION;

		IF (pnumero = "") or (pnumero is null) THEN
			LET cCodRet = '00001';
			LET vMensaje = "El Número de crédito no debe ir en blanco";
                        RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
		ELSE

                   /* EXECUTE PROCEDURE bdidomi:sp_valida_cadena(pnumero,"N") into vcodSP;
                        IF vcodSP <> "00000" THEN
                            --1.b.- El Sistema validó que el Número de Cuenta no es numérica.
                            --1.b.1.- El Sistema muestra mensaje indicando que "El Número de cuenta debe ser solo números".
                            LET cCodRet = '00003';
                            LET vMensaje = "El Número de crédito debe ser solo números";
                            RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                  dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                            --El Sistema valida que el Número de Crédito existe y es Númerico.
                        END IF;*/

                    --El Sistema valida que el Número de Crédito existe y es Númerico.
                    IF EXISTS(select folio_suc from bdicred:sd_movhis  where empresa ='001'
					AND num_credito = pnumero and fecha_mov is not null  AND  reversado <> "") THEN
                    ELSE
                        --1.a.- El Sistema validó que el Número de Cuenta no existe.
                        --1.a.1.- El Sistema muestra mensaje indicando que "No existe el número de crédito capturado".
                        LET cCodRet = '00002';
                        LET vMensaje = "No existe el número de crédito capturado";
                        RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                    END IF;

		END IF;


		IF pfecha <> "" THEN
			LET vfechaValidar = substr(pfecha,7,4) ||  substr(pfecha,4,2) || substr(pfecha,1,2);
			 EXECUTE procedure intercard:sp_valida_fecha(vfechaValidar) into vcodSP;
			IF (vcodSP = "00000") or (vcodSP = "00002") THEN
				LET dfechaSp = substr(pfecha,4,2) || "/" || substr(pfecha,1,2) || "/" || substr(pfecha,7,4);
				select fecha_hoy INTO dfechaSistema from bdicred:sd_fechas;
				--El Sistema valida que la Fecha es menor a la actual
				IF dfechaSp > dfechaSistema THEN
					--3.a.- El Sistema validó que la Fecha es mayor a la actual.
					LET cCodRet = '00004';
					LET vMensaje = "La fecha no debe ser mayor a la actual";
					RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
				END IF;
			ELSE
				LET cCodRet = '00005';
				LET vMensaje = "La fecha no esta escrita correctamente";
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
			END IF;
			LET dFecha1 = dfechaSp;
			LET dFecha2 = dfechaSp;
		ELSE
			LET dFecha1 = '01/01/1900';
			LET dFecha2 = '01/01/3000';
		END IF;


		IF (pfolio = "") THEN
			LET vtipoconsulta = "A";
		ELSE
			LET vtipoconsulta = "B";
		END IF;


		IF (pimporte = "") or (pimporte is null)  or (pimporte = 0.00) THEN
			LET mImporte1 = 0;
			LET mImporte2 = 99999999999999.99;
		ELSE
			LET mImporte1 = pimporte;
			LET mImporte2 = pimporte;
		END IF;
		
		--Obtiene nombre de la sucursal 5005.
		select nombre into vNombreSuc from bdinteg:si_sucursales where sucursal='5005';
		LET vNombreSuc= TRIM(vNombreSuc);
		
		IF vtipoconsulta = "A" THEN
			select distinct count(folio_suc)
			INTO iregistros
			from bdicred:sd_movhis
			where empresa='001' 
			AND num_credito = pnumero AND sucursal='5005'
			AND fecha_mov between dFecha1 AND dFecha2
			AND monto between mImporte1 and mImporte2
			AND folio_suc <> "";

			FOREACH
				select distinct folio_suc, Substr(folio_suc,1,4), monto, fecha_mov, hora_mov, usuario, reversado
				INTO vFolio_Suc,vSuc_Origen,mMonto,dFecha_mov,dHora_mov,vUsuario,vReversado
				from bdicred:sd_movhis
				where empresa ='001' 
				AND num_credito = pnumero
				AND fecha_mov between dFecha1 AND dFecha2
				AND monto between mImporte1 and mImporte2
				AND sucursal='5005' AND folio_suc <> ""
				
				LET vSuc_Origen= TRIM(vSuc_Origen);
				--Busca Nombre de la sucursal de origen.
				SELECT nombre INTO vNombreSuc FROM bdinteg:si_sucursales where sucursal=vSuc_Origen;
				
				LET iContador = iContador + 1;
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
					dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros WITH RESUME;
				
			END FOREACH;


		ELIF vtipoconsulta = "B" THEN
		    select distinct count(folio_suc)
			INTO iregistros
			from bdicred:sd_movhis
			where empresa='001' 
			AND num_credito = pnumero AND sucursal='5005'
			AND fecha_mov between dFecha1 AND dFecha2
			AND monto between mImporte1 and mImporte2
			AND folio_suc = pfolio;
			FOREACH

				select distinct folio_suc, Substr(folio_suc,1,4), monto, fecha_mov, hora_mov, usuario, reversado
				INTO vFolio_Suc,vSuc_Origen,mMonto,dFecha_mov,dHora_mov,vUsuario,vReversado
				from bdicred:sd_movhis
				where empresa='001' 
				AND num_credito = pnumero and sucursal='5005'
				AND fecha_mov between dFecha1 AND dFecha2
				AND monto between mImporte1 and mImporte2
				AND folio_suc = pfolio
				
				LET vSuc_Origen= TRIM(vSuc_Origen);
				--Busca Nombre de la sucursal de origen.
				SELECT nombre INTO vNombreSuc FROM bdinteg:si_sucursales where sucursal=vSuc_Origen;
				
				LET iContador = iContador + 1;
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros WITH RESUME;
			END FOREACH;
		END IF;



		IF iContador = 0 THEN
			LET cCodRet =  "00006";
			LET vMensaje = "No existen movimientos para la consulta";
			RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros ;
		END IF;
	END;
end procedure
/*DOCUMENT
'AUTOR : Alejandro Osuna Iza',
'DESCRIPCION: Se encarga de extraer los datos correspondientes de movimientos de corresponsales de credito',
'MODIFICADO POR :José de Jesús Nevarez',
'DESCRIPCION DEL CAMBIO: Se modifico busqueda por surcursal 5005 y se agrego nombre de sucursal.',
'EJECUTADO O LLAMADO POR:',
'concorr.exe',
'FECHA DEL CAMBIO: 24 Mayo de 2010',
'VERSION: 20100522',
'BD    : intercard'*/;

create procedure "informix".sp_consultatrandeb(pfolio char(16),pfecha char(10), pnumero char(20), pimporte money(16,2))
RETURNING 	CHAR(5) 	as codret,
			CHAR(200)	as mensaje,
			CHAR(16) 	as folio_suc,
			CHAR(4) 	as suc_origen,
			CHAR(40)    as nombre_suc,
			MONEY(16,2)	as monto,
			date		as fecha_mov,
			DATETIME HOUR TO FRACTION(3) 	as hora_mov,
			CHAR(8)		as usuario,
			CHAR(1)		as reversado,
			integer		as registros;

	--Declaracion de variables
    DEFINE cCodRet          CHAR(5);
	DEFINE vMensaje			CHAR(200);
	DEFINE iSqlErr          INTEGER;
	DEFINE vFolio_Suc       CHAR(16);
	DEFINE vSuc_Origen      CHAR(4);
	DEFINE mMonto			MONEY(16,2);
	DEFINE dFecha_mov		DATE;
	DEFINE dHora_mov		DATETIME HOUR TO FRACTION(3);
	DEFINE vNombreSuc		CHAR(40);
	DEFINE vUsuario			CHAR(8);
	DEFINE vReversado		CHAR(1);

		--declaracion de variabels de trabajo
	DEFINE vcodSP 			CHAR(5);
	DEFINE dfechaSistema	date;
	DEFINE dfechaSp			date;
	DEFINE mMontoSP			MONEY(16,2);
	DEFINE vfechaValidar	CHAR(8);
	DEFINE vtipoconsulta	CHAR(1);
	DEFINE dFecha1			DATE;
	DEFINE dFecha2			DATE;
	DEFINE mImporte1 		MONEY(16,2);
	DEFINE mImporte2 		MONEY(16,2);
	DEFINE iContador		integer;
	DEFINE iregistros 		integer;

	--SET DEBUG FILE TO "/informixuc7/perifericos/sp_consultatrandeb.out";
    --TRACE ON;

	---inicializacion de variables
	LET cCodRet = '00000';
	LET vMensaje 		= "PROCESO REALIZADO SATISFACTORIAMENTE";
	LET vFolio_Suc		= "";
	LET vSuc_Origen		= "";
	LET mMonto			= 0.00;
	LET dFecha_mov		= CURRENT;
	LET dhora_mov		= CURRENT HOUR TO FRACTION(3);
	LET vUsuario		= "";
	LET vReversado		= "";
	LET vfechaValidar 	= "";
	LET vtipoconsulta	= "";
	LET iContador		= 0;
	LET iregistros 		= 0;
	LET vNombreSuc		="";


	---Inicializaciond e variables  de trabajo
	LET vcodSP = "00000";


    BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
					LET vMensaje = "Error de Informix";
                    RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                           dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                END IF;
        END EXCEPTION;

		IF (pnumero = "") or (pnumero is null) THEN
			LET cCodRet = '00001';
			LET vMensaje = "El Número de cuenta no debe ir en blanco";
                        RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
		ELSE
                   /* EXECUTE PROCEDURE bdidomi:sp_valida_cadena(pnumero,"N") into vcodSP;
                        IF vcodSP <> "00000" THEN
                            --1.b.- El Sistema validó que el Número de Cuenta no es numérica.
                            --1.b.1.- El Sistema muestra mensaje indicando que "El Número de cuenta debe ser solo números".
                            LET cCodRet = '00003';
                            LET vMensaje = "El Número de cuenta debe ser solo números";
                            RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                  dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                            --El Sistema valida que el Número de Crédito existe y es Númerico.
                        END IF;*/

                    --El Sistema valida que el Número de Crédito existe y es Númerico.
                    IF EXISTS(SELECT  folio_suc FROM bdicheq:sc_movhis WHERE empresa = '001' AND cuenta = pnumero) THEN

                    ELSE
                            --1.a.- El Sistema validó que el Número de Cuenta no existe.
                                    --1.a.1.- El Sistema muestra mensaje indicando que "No existe el número de crédito capturado".
                            LET cCodRet = '00002';
                            LET vMensaje = "No existe el número de cuenta capturado";
                            RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                   dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
                    END IF;
		END IF;


		IF pfecha <> "" THEN
			LET vfechaValidar = substr(pfecha,7,4) ||  substr(pfecha,4,2) || substr(pfecha,1,2);
			 EXECUTE procedure intercard:sp_valida_fecha(vfechaValidar) into vcodSP;
			IF (vcodSP = "00000") or (vcodSP = "00002") THEN
				LET dfechaSp = substr(pfecha,4,2) || "/" || substr(pfecha,1,2) || "/" || substr(pfecha,7,4);
				select fecha_hoy INTO dfechaSistema from bdicheq:sc_fechas;
				--El Sistema valida que la Fecha es menor a la actual
				IF dfechaSp > dfechaSistema THEN
					--3.a.- El Sistema validó que la Fecha es mayor a la actual.
					LET cCodRet = '00004';
					LET vMensaje = "La fecha no debe ser mayor a la actual";
					RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""), vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                               dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
				END IF;
			ELSE
				LET cCodRet = '00005';
				LET vMensaje = "La fecha no esta escrita correctamente";
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros;
			END IF;
			LET dFecha1 = dfechaSp;
			LET dFecha2 = dfechaSp;
		ELSE
			LET dFecha1 = '01/01/1900';
			LET dFecha2 = '01/01/3000';
		END IF;


		IF (pfolio = "") THEN
			LET vtipoconsulta = "A";
		ELSE
			LET vtipoconsulta = "B";
		END IF;
		IF (pimporte = "") or (pimporte is null)  or (pimporte = 0.00) THEN
			LET mImporte1 = 0;
			LET mImporte2 = 99999999999999.99;
		ELSE
			LET mImporte1 = pimporte;
			LET mImporte2 = pimporte;
		END IF;


		IF vtipoconsulta = "A" THEN

			select distinct count(folio_suc)
			INTO iregistros
			from bdicheq:sc_movhis
			where empresa='001' AND cuenta = pnumero AND sucursal='5005'
			AND fech_alt between dFecha1 AND dFecha2
			AND monto_tot between mImporte1 and mImporte2
			AND folio_suc <> "";

			FOREACH
				select distinct folio_suc,monto_tot, substr(folio_suc,1,4),fech_alt,fech_hor,usuario,cancelad
				INTO vFolio_Suc,mMonto,vSuc_Origen,dFecha_mov,dHora_mov,vUsuario,vReversado
				from bdicheq:sc_movhis
				where empresa='001' AND cuenta = pnumero AND sucursal='5005'
				AND fech_alt between dFecha1 AND dFecha2
				AND monto_tot between mImporte1 and mImporte2
				AND folio_suc <> ""

				LET vSuc_Origen= TRIM(vSuc_Origen);
				--Busca Nombre de la sucursal de origen.
				SELECT nombre INTO vNombreSuc FROM bdinteg:si_sucursales where sucursal=vSuc_Origen;

				IF vReversado = "" THEN
					let vReversado = "N";
				END IF;

				LET iContador = iContador + 1;
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros WITH RESUME;
			END FOREACH;
		--END IF;


		ELIF vtipoconsulta = "B" THEN

		    select distinct count(folio_suc)
			INTO iregistros
			from bdicheq:sc_movhis
			where empresa='001' AND cuenta = pnumero and sucursal='5005'
			AND fech_alt between dFecha1 AND dFecha2
			AND monto_tot between mImporte1 and mImporte2
			AND folio_suc = pfolio;
			FOREACH

				select distinct folio_suc, monto_tot,substr(folio_suc,1,4),fech_alt,fech_hor,usuario,cancelad
				INTO vFolio_Suc,mMonto,vSuc_Origen,dFecha_mov,dHora_mov,vUsuario,vReversado
				from bdicheq:sc_movhis
				where empresa='001' AND cuenta = pnumero and sucursal='5005'
				AND fech_alt between dFecha1 AND dFecha2
				AND monto_tot between mImporte1 and mImporte2
				AND folio_suc = pfolio

				LET vSuc_Origen= TRIM(vSuc_Origen);
				--Busca Nombre de la sucursal de origen.
				SELECT nombre INTO vNombreSuc FROM bdinteg:si_sucursales where sucursal=vSuc_Origen;

				IF vReversado = "" THEN
					let vReversado = "N";
				END IF;

				LET iContador = iContador + 1;
				RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
                                       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros WITH RESUME;
			END FOREACH;
		END IF;


		IF iContador = 0 THEN
			LET cCodRet =  "00006";
			LET vMensaje = "No existen movimientos para la consulta";
			RETURN cCodRet, nvl(vMensaje,""),nvl(vFolio_Suc,""),NVL(vSuc_Origen,""),vNombreSuc,NVL(mMonto,""),dFecha_mov,
			       dHora_mov,NVL(vUsuario,""),NVL(vReversado,""),iregistros ;
		END IF;
	END;
end procedure
/*DOCUMENT
'AUTOR : Alejandro Osuna Iza',
'DESCRIPCION: Se encarga de extraer los datos correspondientes de movimientos de corresponsales de cheques',
'MODIFICADO POR :José de Jesús Nevarez',
'DESCRIPCION DEL CAMBIO: Se modifico busqueda por surcursal 5005 y se agrego nombre de sucursal.',
'EJECUTADO O LLAMADO POR:',
'concorr.exe',
'FECHA : 20 Abril de 2010',
'FECHA DEL CAMBIO: 24 Mayo de 2010',
'VERSION: 20100522',
'BD    : intercard'*/;

CREATE PROCEDURE "informix".sp_valida_cadena(p_Cadena LVARCHAR(345),p_tipo CHAR(1))


	RETURNING CHAR(5);
	--Elaboró: Alejandro Osuna Iza
   --Actividad: Valida que la cadena no contenga caracteres especiales
   --Solicito: Hector Casanova
   --Fecha: 13 de julio de 2009


	DEFINE v_sCodRet  CHAR(5);
	DEFINE longitud integer;
	DEFINE cadenados CHAR(20);
	DEFINE inicio integer;
	DEFINE finciclo char(1);
	DEFINE valor CHAR(1);


	LET cadenados = "";
	LET finciclo = "";
	LET v_sCodRet = "";
	LET valor = "";

	--SET DEBUG FILE TO "/tmp/sp_valida_cadena.out";
    --TRACE ON;

	IF 	(p_tipo = "A")  OR (p_tipo = "N") OR (p_tipo = "B") OR (p_tipo = "P") OR (p_tipo = "T") THEN
	ELSE
		LET v_sCodRet = "00608";
            RETURN v_sCodRet;
	END IF;
	IF (p_tipo = "N") OR (p_tipo = "A") OR (p_tipo = "T") THEN
		IF (p_Cadena is null) OR (p_Cadena = "")THEN
			LET v_sCodRet = "00608";
	            RETURN v_sCodRet;
		END IF;
	END IF;
	--Se valida QUE LA CADENA SEA ALFANUMERICO
	IF p_tipo = "A" then
       --LET cadena = p_sreferencia1;
       LET longitud = length(p_Cadena);
       LET inicio = 1;
       LET finciclo = 'F';
       while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= 'A') and (cadenados <= 'Z')) or ((cadenados >= 'a') and (cadenados <= 'z')) or ((cadenados >= '0')  and (cadenados <= '9'))THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;
        IF valor = 'B' THEN
			LET v_sCodRet = "00609";
            RETURN v_sCodRet;
        END IF;
	END if;
	--Se valida QUE LA CADENA SEA NUMERICO
	IF p_tipo = "N" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= '0')  and (cadenados <= '9'))THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00610";
			RETURN v_sCodRet;
        END IF;
	END IF;
	IF p_tipo = "B" then
        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF (cadenados = ' ') THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00612";
			RETURN v_sCodRet;
        END IF;
	END IF;
	--Se valida CON LA TABLA DE CARACTERES VALIDOS EN LA CCE(CHEQUES,TEF, DOMI)
	IF p_tipo = "T" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= ' ') and (cadenados <= ';'))
				or ((cadenados >= '?')  and (cadenados <= 'Z'))
				or (cadenados >= '\')
				or (cadenados >= '_')
				or ((cadenados >= 'a')  and (cadenados <= 'z'))
				or (cadenados >= 'é')
				or ((cadenados >= 'á')  and (cadenados <= 'Ñ'))
				or (cadenados >= '¿')
				or (cadenados >= '¡') THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00614";
			RETURN v_sCodRet;
        END IF;
	END IF;
	--SE VALIDA CON RESPECTO A LOS CARACTERES PERMITIDOS EN LA NOMENCLATURA DE ARCHIVOS DE ENTRADA
	IF p_tipo = "P" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= '0') and (cadenados <= 'z'))
				or (cadenados >= '.') --and (cadenados <= 'z'))
				/*or ((cadenados >= 'á')  and (cadenados <= 'Ñ'))
				or ((cadenados >= '¿')
				or ((cadenados >= '¡')
				/*or ((cadenados >= ' ')  and (cadenados <= '/'))
				or ((cadenados >= ' ')  and (cadenados <= '/'))*/
				THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00615";
			RETURN v_sCodRet;
        END IF;
	END IF;

	LET v_sCodRet = "00000";
	RETURN v_sCodRet;


END PROCEDURE;