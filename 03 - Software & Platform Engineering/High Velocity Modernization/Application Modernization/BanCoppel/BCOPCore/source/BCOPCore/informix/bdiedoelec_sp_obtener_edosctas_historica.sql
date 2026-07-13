CREATE PROCEDURE "informix".sp_obtener_edosctas_historica
(
	pEmpresa CHAR(3),
	pNoCliente CHAR(9),
	pNoCuenta CHAR(20),
	pFechaInicio DATE,
	pFechaHoy DATE
)
RETURNING 
CHAR(6) AS codRetorno,
CHAR(20) AS cuenta,
CHAR(20) AS tarjeta,
CHAR(4) AS sucursal,
CHAR(45) AS producto,
DATE AS fecha_emision,
CHAR(20) AS estatus;


DEFINE cCodRet CHAR(6);
DEFINE cCuenta CHAR(20);
DEFINE cTarjeta CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE cProducto  CHAR(45);
DEFINE dFecha_emision DATE;
DEFINE cEstatus CHAR(20);
DEFINE iSql_err INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cTipoCuenta CHAR(2);

LET cCodRet = '000000';
LET cCuenta = '';
LET cTarjeta = '';
LET cSucursal = '';
LET cProducto  = '';
LET dFecha_emision = TODAY;
LET cEstatus = '';
LET cTipoCuenta = '';
LET iSql_err	 = 0;
LET iIsamErr	 = 0;


BEGIN
    
    ON EXCEPTION SET iSql_err,iIsamErr
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
        END IF;
    END EXCEPTION;  
    
      --SET DEBUG FILE TO "/respaldosbd/mario/sp_obtener_edosctas_historica.out";
      --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	IF NVL(pEmpresa,'') <> '' AND NVL(pNoCliente,'') <> '' AND NVL(pNoCuenta,'') <> '' AND NVL(pFechaInicio,'') <> '' AND NVL(pFechaHoy,'') <> '' THEN	
		LET cTipoCuenta = SUBSTR(pNoCuenta,1,2);
		IF cTipoCuenta = '60' THEN	
		
			FOREACH SELECT a.cuenta, c.num_tarjeta, e.sucursal, a.producto||' '||d.nombre_prod, b.fecha_emision, 'EMITIDO' as estatus 
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
			FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred@pld_tcp:sd_encabezado2_edocta 
			b, bdicred:"informix".sd_tarjeta c, bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecred e 
			WHERE a.empresa = pEmpresa AND  c.empresa = pEmpresa AND  d.empresa = pEmpresa AND e.empresa = pEmpresa AND a.cuenta = b.num_credito 
			AND b.num_credito = a.cuenta AND b.num_credito = c.num_credito AND a.producto = d.num_producto 
			AND e.num_credito = a.cuenta AND a.cuenta = pNoCuenta AND c.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = pNoCliente AND num_credito = pNoCuenta AND tipo_tarjeta = 'T')
			AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy ORDER BY b.fecha_emision
			
				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
				
		ELIF cTipoCuenta = '61' OR cTipoCuenta = '63' THEN
		
			FOREACH SELECT a.cuenta, e.sucursal, a.producto||' '||d.nombre_prod,b.fecha_emision, 'EMITIDO' as 
			estatus INTO cCuenta,cSucursal,cProducto,dFecha_emision,cEstatus FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred@pld_tcp:sd_encabezado2_edoctacrd b, 
			bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecredcrd e  WHERE a.cuenta = b.num_credito AND b.num_credito 
			= a.cuenta  AND a.producto = d.num_producto AND e.num_credito = a.cuenta  AND a.cuenta =pNoCuenta   AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy ORDER BY b.fecha_emision 

				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
			
		ELIF cTipoCuenta <> '61' AND cTipoCuenta <> '63' AND cTipoCuenta <> '60' THEN
		
			FOREACH SELECT UNIQUE a.cuenta,b.num_tarjeta,a.sucursal,a.producto||' '||c.nombre,b.fechafin,'EMITIDO' as estatus 
			INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_maehis b, bdicheq:"informix".sc_producto c WHERE a.num_cte = b.num_cte AND a.cuenta = b.cuenta AND a.producto = c.producto AND a.status_cta IN (1,3,4,5) AND a.num_cte = pNoCliente AND b.cuenta = pNoCuenta AND b.fechafin BETWEEN pFechaInicio AND pFechaHoy ORDER BY fechafin ASC
			
				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
			
		END IF
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000003';
		END IF;
		
	ELSE
		LET cCodRet = '000002';
	END IF;
	IF cCodret <> '000000' THEN
		RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
	END IF;

END;
END PROCEDURE
DOCUMENT
"Folio:",
"Autor:95142134 Mario Gallardo",
"Fecha:15/04/2014",
"Modificaci??",
"Sustento: ",
"Solicita:  ",
"BD:bdiedoelec";

CREATE PROCEDURE "informix".sp_consulta_solic(pEmpresa char(3),pCuenta char(20))
	RETURNING 	VARCHAR(5) as  codret,
				Integer as  id, 
				VARchar(20) as numcte,
				varchar(60) as nomcte,
				varchar(20) as cuenta,
				varchar(4) as  producto,
				varchar(100) as Correo,
				date 	as  Fecha_corte,
				date 	as  Fecha_modif;

-- ****************************************************************************
-- Permite consultar los datos de las solicitudes para los estados de cuenta que han sido enviadas
-- ****************************************************************************
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Realizó: Richar 
--Fecha: 31/07/2015
--Fecha de mofidicacion:
--Descripcion del cambio:
--------------------------------------------------------------------			

DEFINE iSqlErr  	   INTEGER;	
DEFINE cod_ret char(5);
DEFINE Vid integer;
DEFINE Vnumcte varchar(20);
DEFINE Vnombrecte varchar(60);
DEFINE Vcuenta varchar(20);
DEFINE Vproducto varchar(4);
DEFINE Vfecha_corte date;
DEFINE Vfecha_modificacion date;
DEFINE Vvalor char(3);
DEFINE pFechaSol date;

--***** Variables para el correo del cliente ***---

DEFINE vcodret_correo char(5);
DEFINE vcorreocte		  varchar(100);
DEFINE vTipoCorreocte 	  SMALLINT;
DEFINE vstatuscorreocte  CHAR(1);
DEFINE vEnviados 	  SMALLINT;
DEFINE vReenviados 	  SMALLINT;

--////*****Banderas--
DEFINE VbCorreo boolean;


LET Vid					=0;
LET Vnumcte 			='';
LET Vnombrecte  		='';
LET Vcuenta  			='';
LET Vproducto 			='';
LET Vfecha_corte		='';
LET Vfecha_modificacion	='';
LET Vvalor 				='';
LET pFechaSol 			='';



set isolation to dirty read;

Begin

			-- MANEJADOR DE ERRORES	
				ON EXCEPTION SET iSqlErr
					--LET cod_ret = v_sql;
					LET cod_ret = iSqlErr;
					Return cod_ret, '','','','','','','','';
				END EXCEPTION;		

	LET cod_ret = '001';
	LET vcorreocte = '';
	LET Vnombrecte='';
	
	
	--set debug file to "sp_consulta_solic.out";
	--trace on;
	
		select trim(valor)
		into Vvalor
		from bdiedoelec:edelec_param
		where cod_param=7;
		
		LET pFechaSol = today - cast(Vvalor as integer);	
		--Validaciones
		
		select count(*)
			INTO vEnviados
			from bdiedoelec:edelec_log_serv_solic 
			where status_envio_edocta='AE' and cuenta=pCuenta and fecha_modificacion>=pFechaSol;
		
		IF (vEnviados = 0) then --No hay registros por reenviar
			LET cod_ret='001';
			
			select count(*)
				INTO vReenviados
				from bdiedoelec:edelec_log_serv_solic 
				where status_envio_edocta='AR' and cuenta=pCuenta and fecha_modificacion>=pFechaSol;
			
			IF (vReenviados > 0) then --Se reenviaron todos los registros
				LET cod_ret='002';
			End if;
			
			Return cod_ret, Vid,trim(Vnumcte),Vnombrecte,trim(Vcuenta),trim(Vproducto),trim(vcorreocte),Vfecha_corte,Vfecha_modificacion;
			
		End if;
		--Validaciones
		
		
		FOREACH
			select id,numcte,cuenta,producto,fecha_corte,fecha_modificacion
			INTO Vid,Vnumcte,Vcuenta,Vproducto,Vfecha_corte,Vfecha_modificacion
			from bdiedoelec:edelec_log_serv_solic 
			where status_envio_edocta='AE' and cuenta=pCuenta and fecha_modificacion>=pFechaSol
			
			if trim(vcorreocte) ='' then
				execute procedure bdinteg:"informix".sp_consulta_correos('001',Vnumcte,1,'0')
				INTO vcodret_correo,vcorreocte,vTipoCorreocte,vstatuscorreocte;
			End if;
			
			if Trim(Vnombrecte)='' then
				select 
				(case when trim(nombre2)<>'' then trim(nombre1) || ' ' || trim(nombre2) else trim(nombre1) end) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno) as nombre
				INTO Vnombrecte
				from bdinteg:si_cliente where numcte=Vnumcte;		
			End if;
			
			LET cod_ret ='000';			
			Return cod_ret, Vid,trim(Vnumcte),Vnombrecte,trim(Vcuenta),trim(Vproducto),trim(vcorreocte),Vfecha_corte,Vfecha_modificacion  WITH RESUME;
		END FOREACH;

END;
END PROCEDURE;