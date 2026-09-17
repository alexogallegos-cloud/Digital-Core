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