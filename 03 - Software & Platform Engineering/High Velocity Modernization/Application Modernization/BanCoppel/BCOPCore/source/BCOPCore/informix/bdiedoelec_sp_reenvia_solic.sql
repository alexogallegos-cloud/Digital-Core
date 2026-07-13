CREATE PROCEDURE "informix".sp_reenvia_solic(pEmpresa char(3),pId Integer, pSucursal CHAR(4), pUsuario char(20))
	
	RETURNING 	VARCHAR(5) as  codret; --Codigo de retorno

-- ****************************************************************************
-- Permite habilitar solicitudes de estados de cuenta para ser re enviadas
-- ****************************************************************************
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Realizó: Richar 
--Fecha: 03/08/2015
--Fecha de mofidicacion:
--Descripcion del cambio:
--------------------------------------------------------------------			
DEFINE iSqlErr  	   integer;	
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE cod_ret char(5);
DEFINE Vnumcte varchar(20);
DEFINE Vcuenta varchar(20);
DEFINE Vproducto varchar(4);
DEFINE Vfecha_corte date;
DEFINE Vsucursal varchar(4);

--***** Variables para el correo del cliente ***---

DEFINE vcodret_correo char(5);
DEFINE vcorreocte		  varchar(100);
DEFINE vTipoCorreocte 	  SMALLINT;
DEFINE vstatuscorreocte  CHAR(1);

--Bandera
DEFINE vErr 	SMALLINT;

			-- MANEJADOR DE ERRORES	
				ON EXCEPTION SET iSqlErr, isam_err, error_info
					--LET cod_ret = v_sql;
					LET cod_ret = iSqlErr;
					if vErr=1 then
						ROLLBACK WORK;
					End if;
					RETURN cod_ret;
				END EXCEPTION;		

	set isolation to dirty read;
				
	LET cod_ret = '001';
	LET vcorreocte = '';
	LET vErr = 0;
	--set debug file to "sp_reenvia_solic.out";
	--trace on;
	
	
	if (pEmpresa is null or trim(pEmpresa)='') or (pId=0 or pId='') or (trim(pSucursal)='' or pSucursal is null) or (trim(pUsuario)='' or pUsuario is null) then		
		return cod_ret;
	End if;
	
	LET pSucursal = lpad(trim(pSucursal),4,'0');  --Formato a la sucursal 0000

	select sucursal 
		INTO Vsucursal
		from bdinteg:si_sucursales
		where sucursal=pSucursal;
	
	If (trim(Vsucursal) = '' or Vsucursal is null) then --No existe sucursal
			LET cod_ret='003';
			return cod_ret;
		End if;
	
	select numcte,cuenta,producto,fecha_corte
			INTO Vnumcte,Vcuenta,Vproducto,Vfecha_corte
			from bdiedoelec:edelec_log_serv_solic 
			where id=pId;
			
		If (trim(Vnumcte) = '' or Vnumcte is null) or (trim(Vcuenta)='' or Vcuenta is null) then --No existe registro
			LET cod_ret='002';
			return cod_ret;
		End if;
			
		execute procedure bdinteg:"informix".sp_consulta_correos('001',Vnumcte,1,'0')
		INTO vcodret_correo,vcorreocte,vTipoCorreocte,vstatuscorreocte;
			
				BEGIN WORK;			
				
					LET vErr=1;
					update bdiedoelec:edelec_log_serv_solic set status_envio_edocta='AR' where id=pId;
					
					INSERT INTO bdiedoelec:edelec_log_serv_solic(empresa, numcte, cuenta, producto, fecha_corte, status_envio_edocta, fecha_modificacion)
														VALUES('001', Vnumcte, Vcuenta, Vproducto, Vfecha_corte,'SE', today);			
				
					update bdiedoelec:edelec_serv_solic SET fecha_vigencia= today + 5
					where numcte=Vnumcte and cuenta=Vcuenta and producto=Vproducto and fecha_corte=Vfecha_corte;
							
					if dbinfo('sqlca.sqlerrd2')=0 THEN --Si no actualizo nada, inserta el registro
					
						INSERT INTO bdiedoelec:edelec_serv_solic(empresa, numcte, cuenta, producto, fecha_corte, fecha_recepcion, fecha_vigencia)
														VALUES('001', Vnumcte, Vcuenta, Vproducto, Vfecha_corte, today, today + 5);			
					End if;		
					INSERT INTO bdiedoelec:edelec_reenvios(empresa, numcte, cuenta, producto, correo, sucursal, fecha_corte, fecha_solic, user_solic)
											  VALUES('001', Vnumcte, Vcuenta, Vproducto, vcorreocte, pSucursal, Vfecha_corte, today, pUsuario);
											  
				COMMIT WORK;
				
				LET vErr=0;
				
		    LET cod_ret='000';
			return cod_ret;		

END PROCEDURE;