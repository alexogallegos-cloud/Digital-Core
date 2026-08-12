CREATE PROCEDURE "informix".sp_actualiza_sesion_bex_pba(pc_numero_cliente varchar(20), pc_canal varchar(20), pc_id_sesion char(500), key_old varchar(100), key_new varchar(100))
    RETURNING CHAR(5),CHAR(5);
	
	DEFINE resultado CHAR(5);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE exist     INTEGER;
    DEFINE vCountinactivas INTEGER;
	DEFINE dFecha	DATETIME YEAR TO SECOND;
	
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_actualiza_sesion_bex.out";
    --TRACE ON; 
	LET vcodret   = '00000';
	LET resultado = '00000';
    LET exist = 0;
    LET vCountinactivas = 0;
	LET dFecha = CURRENT;
	
	BEGIN	

	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
		--SELECT count(numcliente) 
		SELECT LIMIT 1 1, fecha
		INTO exist, dFecha
		FROM "informix".bpi_doblesesion 
		WHERE numcliente = pc_numero_cliente 
		AND canal = pc_canal 
		AND id_sesion = pc_id_sesion 
		AND llave = key_old;
			 
		IF exist > 0 THEN
--GM2 Juan Olivares: 25/10/2018 INI: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284
			/*SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
            INTO vCountinactivas
            FROM "informix".bpi_doblesesion 
            WHERE numcliente = pc_numero_cliente
            AND canal = pc_canal;
*/
           -- LET vCountinactivas = NVL(vCountinactivas,0);
		   IF ((CURRENT - dFecha) < '0 00:08:00.000') THEN
				LET vCountinactivas = 1;
		   ELSE
				LET vCountinactivas = 0;				
		   END IF;

			--IF ((SELECT (CURRENT - fecha) FROM "informix".bpi_doblesesion WHERE numcliente = pc_numero_cliente AND canal = pc_canal AND id_sesion = pc_id_sesion AND llave = key_old) <  '0 00:08:00.000')
                IF  (vCountinactivas = 1) THEN
					UPDATE "informix".bpi_doblesesion 
					SET fecha = CURRENT,
					    llave = key_new
					WHERE numcliente = pc_numero_cliente
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
							
					LET resultado = '00000';
				ELSE
					DELETE FROM "informix".bpi_doblesesion 
					WHERE numcliente = pc_numero_cliente 
					AND canal = pc_canal
					AND id_sesion = pc_id_sesion 
					AND llave = key_old;
--GM2 Juan Olivares: 25/10/2018 FIN: ModificaciÃÂ³n Validacion Doble SesiÃÂ³n para evitar error -284							
					LET resultado = '00001';
				END IF;
		ELSE			
			LET resultado = '00002';
		END IF;
END;		
	RETURN	vcodret, resultado;	
END PROCEDURE

DOCUMENT
'MODIFICADO POR: JUAN OLIVARES-GM2',
'VALIDACION FUNCIONALIDAD POR: PATRICIA DEL RAZO-GM3',
'FECHA DE MODIFICACION: 25 DE OCTUBRE DE 2018',
'OBJETIVO: CAMBIO: ELIMINAR ERROR -284, DOBLE SESION',
'FECHA DE ULTIMA MODIFICACION: 26 DE DICIEMBRE DE 2018',
'MODIFICADO POR: COPPEL',
'VALIDACION FUNCIONALIDAD POR:MARCELA PEREZ GM3',
'VoBo POR: ALEJANDRO SANCHEZ-GM1',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_consultasaldocorte_pba(pEmpresa  CHAR (3),pNumCredito CHAR (20), pTipoConsulta SMALLINT)
  RETURNING CHAR (5) AS CodRet, DECIMAL (14,2) AS saldototal;

--pTipoConsulta = 1  Cierre, 0 Para No generar Intereses  
--FMJ Febrero 2012
  
 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE vSaldoTotal DECIMAL (14,2);

DEFINE iDia_corte 	 INTEGER;
DEFINE vRevolvente	 SMALLINT;
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCentral DATE;

LET sSqlErr = 0;
LET cCodRet = '00000';

LEt iDia_corte = 0;
LET vRevolvente =0;
LET vSaldoTotal = 0;
LET dFechaCentral =date(1); 
LET dFechaMesiver =date(1); 
LET dFechaCorte = date(1); 

BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, vSaldoTotal;
        END EXCEPTION;

	set lock mode to wait 3;
	set isolation to dirty read;

	SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy
  	  INTO dFechaCentral
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;

	SELECT dia_corte  INTO iDia_corte  
	  FROM bdicred:"informix".sd_maecredanexo     
	 WHERE empresa = pEmpresa  AND num_credito = pNumCredito;		

	LET iDia_corte = nvl(iDia_corte,0);
	 
	if iDia_corte <> 0 then   	
	  Let vRevolvente = 1;	
	  if day(dFechaCentral) <= iDia_corte then
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
		else
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
		end if;	  
    else     
		Let vRevolvente = 0;

        SELECT nvl(dia_corte,0)  INTO iDia_corte  
          FROM bdicred:"informix".sd_maecredanexocrd     
         WHERE empresa = pEmpresa  
           AND num_credito = pNumCredito;	
	LET iDia_corte = nvl(iDia_corte,0);

        EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(pEmpresa,iDia_corte)
        into cCodRet, dFechaMesiver, dFechaCorte;

        if (cCodRet <> '00000') then
          let cCodRet = '00002';  -- ERROR EN RUTINA DE CALCULO DE MESIVERSARIO
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 
       end if;

	end if;	
		
	--If  ( iDia_corte =0) and (nvl(dFechaCorte,date(1)) =date(1)) then 
	LET dFechaCorte = NVL(dFechaCorte, date(1));	
	If  ( iDia_corte =0) and (dFechaCorte = date(1)) then 	
          let cCodRet = '00001';  -- CREDITO NO EXISTE
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 	
    end if;
	
	If (vRevolvente = 1) Then
	
		select nvl(( case when (nvl(sdo_cap_insoluto,0) < 0) then decode( pTipoConsulta,1, nvl(sdo_cap_insoluto,0),0)  
		             else  Nvl(sdo_cap_insoluto,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +			
					 
							case when (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0) >=0) then  ---
									  (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0)) else NVL(int_tra_no_exig,0) end + 
									  
						   (select nvl(campo_trabajo1 ,0)
							from bdicred:"informix".sd_amortiza_credito 
							where a.empresa = empresa 
							  and a.num_credito = num_credito 
							  and b.fecha = fecha_cuota 
							)end),0)   														
							into vSaldoTotal				 
		from bdicred:"informix".sd_maecred a 				
		join bdicred:"informix".sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dFechaCorte  and a.num_credito = b.num_credito) 				 
		join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
        where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;	  
		
	Elif (vRevolvente = 0) then
	
		select (sdo_cap_insoluto     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)) into vSaldoTotal
		from bdicred:"informix".sd_maecredcrd a 				
		join bdicred:"informix".sd_maesdoshistcrd b on (a.empresa = b.empresa and b.fecha =dFechaCorte and a.num_credito = b.num_credito)                  
		join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
		where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;
	End If;
	Let vSaldoTotal =nvl(vSaldoTotal,0);


RETURN cCodRet, vSaldoTotal;

END;


---Saldo para no generar intereses , o saldo al cierre

END PROCEDURE

DOCUMENT
'FECHA MODIFICACION: 26/12/2018',
'Modificacion : Coppel',
'ValidaciÃ³n : Marcela PÃ©rez-GM3',
'ValidaciÃ³n : Alejandro SÃ¡nchez-GM1',
'ValidaciÃ³n : Juan Olivarez-GM2',
'VoBo : Alejandro SÃ¡nchez-GM1',
'VoBo : Juan Olivarez-GM2',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultasaldocorte_pba1(pEmpresa  CHAR (3),pNumCredito CHAR (20), pTipoConsulta SMALLINT)
  RETURNING CHAR (5) AS CodRet, DECIMAL (14,2) AS saldototal;

--pTipoConsulta = 1  Cierre, 0 Para No generar Intereses  
--FMJ Febrero 2012
  
 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE vSaldoTotal DECIMAL (14,2);

DEFINE iDia_corte 	 INTEGER;
DEFINE vRevolvente	 SMALLINT;
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCentral DATE;

LET sSqlErr = 0;
LET cCodRet = '00000';

LEt iDia_corte = 0;
LET vRevolvente =0;
LET vSaldoTotal = 0;
LET dFechaCentral =date(1); 
LET dFechaMesiver =date(1); 
LET dFechaCorte = date(1); 

BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, vSaldoTotal;
        END EXCEPTION;

	set lock mode to wait 3;
	set isolation to dirty read;

	SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
  	  INTO dFechaCentral
      FROM bdicred:sd_fechas
     WHERE empresa = pEmpresa;

	SELECT dia_corte  INTO iDia_corte  
	  FROM bdicred:sd_maecredanexo     
	 WHERE empresa = pEmpresa  AND num_credito = pNumCredito;		

	LET iDia_corte = nvl(iDia_corte,0);
	 
	if iDia_corte <> 0 then   	
	  Let vRevolvente = 1;	
	  if day(dFechaCentral) <= iDia_corte then
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
		else
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
		end if;	  
    else     
		Let vRevolvente = 0;

        SELECT nvl(dia_corte,0)  INTO iDia_corte  
          FROM bdicred:sd_maecredanexocrd     
         WHERE empresa = pEmpresa  
           AND num_credito = pNumCredito;	
	LET iDia_corte = nvl(iDia_corte,0);

        EXECUTE PROCEDURE "informix".sp_fecha_plazo(pEmpresa,iDia_corte)
        into cCodRet, dFechaMesiver, dFechaCorte;

        if (cCodRet <> '00000') then
          let cCodRet = '00002';  -- ERROR EN RUTINA DE CALCULO DE MESIVERSARIO
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 
       end if;

	end if;	
		
	If  ( iDia_corte =0) and (nvl(dFechaCorte,date(1)) =date(1)) then   
          let cCodRet = '00001';  -- CREDITO NO EXISTE
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 	
    end if;
	
	If (vRevolvente = 1) Then
	
		select nvl(( case when (nvl(sdo_cap_insoluto,0) < 0) then decode( pTipoConsulta,1, nvl(sdo_cap_insoluto,0),0)  
		             else  Nvl(sdo_cap_insoluto,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +			
					 
							case when (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0) >=0) then  ---
									  (NVL(int_tra_no_exig,0) -NVL(sdo_acum_mes_int,0)) else NVL(int_tra_no_exig,0) end + 
									  
						   (select nvl(campo_trabajo1 ,0)
							from bdicred:sd_amortiza_credito 
							where a.empresa = empresa 
							  and a.num_credito = num_credito 
							  and b.fecha = fecha_cuota 
							)end),0)   														
							into vSaldoTotal				 
		from bdicred:sd_maecred a 				
		join bdicred:sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dFechaCorte  and a.num_credito = b.num_credito) 				 
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
        where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;	  
		
	Elif (vRevolvente = 0) then
	
		select (sdo_cap_insoluto     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)) into vSaldoTotal
		from bdicred:sd_maecredcrd a 				
		join bdicred:sd_maesdoshistcrd b on (a.empresa = b.empresa and b.fecha =dFechaCorte and a.num_credito = b.num_credito)                  
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
		where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;
	End If;
	Let vSaldoTotal =nvl(vSaldoTotal,0);


RETURN cCodRet, vSaldoTotal;

END;


---Saldo para no generar intereses , o saldo al cierre

END PROCEDURE;