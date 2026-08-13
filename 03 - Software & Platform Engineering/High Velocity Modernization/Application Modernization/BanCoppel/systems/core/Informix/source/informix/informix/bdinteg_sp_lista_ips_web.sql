CREATE PROCEDURE "informix".sp_lista_ips_web(pMac CHAR(12))

--datos a retornar--               
RETURNING CHAR(5)  AS CodigoRetorno,
          CHAR(40) AS descripcionCodRet,
          CHAR(4)  AS Sucursal, 
          CHAR(16) AS IPs;

--definicion de variables--               
DEFINE sql_err           INTEGER;
DEFINE codRet            CHAR(5);
DEFINE descripcionCodRet CHAR(40);
DEFINE vSucursal         CHAR(4);
DEFINE vSucursal2        CHAR(4);
DEFINE ips               CHAR(16);
DEFINE contador          INTEGER;

-- InicializaciÃ³n de las variables.
LET codRet            = "00000";
LET descripcionCodRet = '';
LET vSucursal         = '';
LET vSucursal2        = '';
LET ips               = '';
LET contador          = 0;

   BEGIN
	 ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
	    	LET codRet = sql_err;
			LET descripcionCodRet = 'Consulta No exitosa';
			RETURN codRet, descripcionCodRet, vSucursal, ips;
         	END IF;
      END EXCEPTION;
	  
	SELECT sucursal  
			INTO vSucursal
			FROM si_sucursalesmaquina
            WHERE mac = pMac;
	  
	IF NVL(pMac,'') = '' THEN
		LET codRet = '00001';
        LET descripcionCodRet = 'Consulta No exitosa, datos nulos';
		RETURN codRet, descripcionCodRet, vSucursal, ips;
    END IF;
	
	IF LENGTH(TRIM(pMac))<12 THEN
		LET codRet = '00002';
		LET descripcionCodRet = 'Consulta No exitosa, tamaÃ±o incorrecto';
		RETURN codRet, descripcionCodRet, vSucursal, ips;
    END IF;
	
	IF NVL(vSucursal,'') = '' THEN
		LET codRet = '00003';
		LET descripcionCodRet = 'Consulta No exitosa, no se encontro MAC';
		RETURN codRet, descripcionCodRet, vSucursal, ips;
    END IF;
			 
	FOREACH
    SELECT ipmaquina, sucursal
        INTO ips, vSucursal2
        FROM bdinteg:"informix".si_sucursalesmaquina 
        WHERE sucursal = vSucursal
		LET descripcionCodRet = 'Consulta exitosa';
        RETURN codRet, descripcionCodRet, vSucursal, ips WITH resume;
	END FOREACH;
   
   END
END PROCEDURE
DOCUMENT
"DESCRIPCION: Consulta direcciones ip en base a una MAC proporcionada",
"REALIZÃ: Jorge Lara",
"FECHA: 13/Diciembre/2017",
"BD:          bdinteg";

create procedure "informix".sp_refdirecciones_web(pempresa char(3),
                             pfuncion char(1),
                             pnumcte char(20),
                             psecuencia integer,
                             ptipodir char(1),
                             pcalle char(40),
                             pcolonia char(60),
                             pmunicipio char(5),
                             pentre_calles char(40),
                             ppais char(3),
                             pentidad char(2),
                             plocalidad char(3),
                             pcodpostal char(5),
                             ptipotel1 char(1),
                             ptelefono1 char(13),
                             ptipotel2 char(1),
                             ptelefono2 char(13),
                             ptipotel3 char(1),
                             ptelefono3 char(13),
                             pextension char(5),
                             pestado_inegi char(2),
                             pmunicipio_inegi char(3),
                             plocalidad_inegi char(4),
                             pnociudad smallint,
                             pnoext char(10),
                             pnoint char(10),
                             pdepto char(6),
                             pnocalle integer,
                             pnocolonia integer,
                             ppuntocar char(1),
                             punihabi char(1),
                             pmanz smallint,
                             ppotros smallint,
                             pandador smallint,
                             petapa smallint,
                             plote smallint,
                             pedif smallint,
                             pentrada smallint,
                             pobserva char(80),
                             puser_insert char(8),
                             pfecha_insert date,
							 numcte_banco char(20))
 returning char(5);

define v_codret char(5);
define v_rowid integer;
define v_tipodir char(1);
define v_calle char(40);
define v_colonia char(60);
define v_delegacion char(20);
define v_entre_calles char(40);
define v_pais char(3);
define v_entidad char(2);
define v_localidad char(3);
define v_codpostal char(5);
define v_telefono1 char(20);
define v_telefono2 char(20);
define v_estado_inegi char(2);
define v_municipio_inegi char(3);
define v_localidad_inegi char(4);
define v_fax char(20);
define v_nombre char(40);
define v_longitud, v_longcte, v_secuencia smallint;
define v_numcte char(20);
define v_existe char(1);
define v_sqlerr, v_isamerr integer;

--DOCUMENTACION:
--RealizÃÂ³: Martha Aguirre
--Fecha: 31/01/2009
--Funcionalidad: Inserta en la tabla si_refdirecciones las direcciones de las referencias de los clientes solicitantes de CrÃÂ©dito


   --	SET DEBUG FILE TO "sp_refdirecciones_today.out";
   -- TRACE ON;
	
	
begin
   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;

   let v_codret="00000";

   select numcte into v_numcte from si_cliente
      where numcte = pnumcte;
   if v_numcte is null then
      let v_codret = "00104";
      return v_codret;
   end if

   if pfuncion="A" then
      {
      select nombre into v_nombre
         from si_paises
         where pais = ppais;
      if v_nombre is null then
         let v_codret="00121";
         return v_codret;
      end if;

      select nombre into v_nombre
         from si_estados
         where pais=ppais and estado=pentidad;

      if v_nombre is null then
         let v_codret="00122";
         return v_codret;
      end if;

      select nombre into v_nombre
         from si_ciudades
         where pais=ppais and estado=pentidad and ciudad=plocalidad;
      if v_nombre is null then
         let v_codret="00123";
         return v_codret;
      end if;
      }
         insert into si_refdirecciones
             (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
	      pais,estado,ciudad,municipio,cod_postal,apart_postal,
	      tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
	      telefono3,extension ,estado_inegi,municipio_inegi,localidad_inegi,
	      numerociudad,numeroextcalle,numerointcalle,departamento,
	      numerocalle,numerocolonia,puntocardinal,unidadhabitac,
	      manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
	      user_insert,fecha_insert,numcte_banco)
           values
             (pnumcte, psecuencia, ptipodir, pcalle, pcolonia, pentre_calles,
              ppais,pentidad,plocalidad, pmunicipio, pcodpostal,"",
              ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,
              ptelefono3, pextension ,pestado_inegi,pmunicipio_inegi,plocalidad_inegi,
              pnociudad,pnoext,pnoint,pdepto,
              pnocalle,pnocolonia,ppuntocar,punihabi,
              pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
              puser_insert,pfecha_insert,numcte_banco);

      return v_codret;
   end if;
end;
end procedure;