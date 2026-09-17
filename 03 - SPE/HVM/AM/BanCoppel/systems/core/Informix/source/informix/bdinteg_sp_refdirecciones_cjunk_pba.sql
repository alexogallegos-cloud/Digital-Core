create procedure "informix".sp_refdirecciones_cjunk_pba(
                                    pempresa char(3),
                                    cTipo CHAR (1),
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
                                     pedIF smallint,
                                     pentrada smallint,
                                     pobserva char(80),
                                     puser_insert char(8),
                                     pfecha_insert date,
                                     numcte_banco char(20))
 RETURNing char(5);

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
--Realizó: Martha Aguirre
--Fecha: 31/01/2009
--Funcionalidad: Inserta en la tabla si_refdirecciones las direcciones de las referencias de los clientes solicitantes de Crédito
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Realizó: Rodolfo Tortolero Varela
--Fecha: 28/09/2011
--Funcionalidad: Cuando el cTipo = 0, Validar los campos para que no se inserten nulos.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --SET DEBUG FILE TO "/respaldosbd/Daniela/sp_refdirecciones_cjunk.out";
    --TRACE ON;
	
begin
	on exception set v_sqlerr, v_isamerr
		IF v_sqlerr != 0 then
			let v_codret=v_sqlerr;
			RETURN v_codret;
		END IF;
	END exception;

	let v_codret="000";
	let cTipo = cTipo;

	select numcte into v_numcte 
	from bdinteg:"informix".si_cliente
	where numcte = pnumcte;
	IF v_numcte is null then
		let v_codret = "104";
		RETURN v_codret;
	END IF

	IF pfuncion="A" then
	{
		select nombre into v_nombre
		from bdinteg:"informix".si_paises
		where pais = ppais;
		IF v_nombre is null then
			let v_codret="121";
			RETURN v_codret;
		END IF;

		select nombre into v_nombre
		from bdinteg:"informix".si_estados
		where pais=ppais and estado=pentidad;

		IF v_nombre is null then
			let v_codret="122";
			RETURN v_codret;
		END IF;

		select nombre into v_nombre
		from bdinteg:"informix".si_ciudades
		where pais=ppais and estado=pentidad and ciudad=plocalidad;
		IF v_nombre is null then
			let v_codret="123";
			RETURN v_codret;
		END IF;
	}
	 
		IF cTipo = '1' THEN 	
			
			UPDATE {+INDEX (si_refdirecciones idx_si_refdirecciones)} si_refdirecciones SET
				(calle,colonia,entre_calles,
				pais,estado,ciudad,municipio,cod_postal,apart_postal,
				estado_inegi,municipio_inegi,localidad_inegi,
				numerociudad,numeroextcalle,numerointcalle,departamento,
				numerocalle,numerocolonia,puntocardinal,unidadhabitac,
				manzana,otros,andador,etapa,lote,edIFicio,entrada,observaciones,
				user_insert,fecha_insert,numcte_banco) = 
				(NVL(pcalle,''), NVL(pcolonia,''), NVL(pentre_calles,''),
				NVL(ppais,''),NVL(pentidad,''),NVL(plocalidad,''), NVL(pmunicipio,''), NVL(pcodpostal,''),"",
				NVL(pestado_inegi,''),NVL(pmunicipio_inegi,''),NVL(plocalidad_inegi,''),
				NVL(pnociudad,0),NVL(pnoext,''),NVL(pnoint,''),NVL(pdepto,''),
				NVL(pnocalle,0),NVL(pnocolonia,0),NVL(ppuntocar,''),NVL(punihabi,''),
				NVL(pmanz,0),NVL(ppotros,0),NVL(pandador,0),NVL(petapa,0),NVL(plote,0),NVL(pedIF,0),NVL(pentrada,0),NVL(pobserva,''),
				NVL(puser_insert,''),pfecha_insert,NVL(numcte_banco,''))
			WHERE secuencia = psecuencia;
                          ---AND numcte = pnumcte;
			
		ELIF cTipo = '0' THEN 
			IF ptelefono1 <> '' THEN
				LET pTipoTel1 = 'P';
			END IF;

			IF ptelefono2 <> '' THEN
				LET pTipoTel2 = 'C';
			END IF;

			IF ptelefono3 <> '' THEN
				LET pTipoTel3 = 'O';
			END IF;

			--INSERT INTO bdinteg:"informix".si_refdirecciones
			--	(numcte,secuencia,tipo_dir,tipo_telef1,telefono1,tipo_telef2, telefono2,tipo_telef3, telefono3, extension)
			--VALUES
			--	(pnumcte,psecuencia,ptipodir,pTipoTel1,ptelefono1,pTipoTel2,ptelefono2,pTipoTel3,ptelefono3,pextension);

			INSERT INTO bdinteg:"informix".si_refdirecciones
				(numcte, secuencia, tipo_dir, calle, colonia, entre_calles,
				pais, estado, ciudad, municipio, cod_postal, apart_postal,
				tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3,
				extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
				numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
				entrada, observaciones, numcte_banco, user_insert, fecha_insert)
			VALUES
				(pnumcte, psecuencia, ptipodir, NVL(pcalle,''), NVL(pcolonia,''), NVL(pentre_calles,''), 
				NVL(ppais,''), NVL(pentidad,''), NVL(plocalidad,''), NVL(pmunicipio,''), NVL(pcodpostal,''), "", 
				pTipoTel1, ptelefono1, pTipoTel2, ptelefono2, pTipoTel3, ptelefono3, 
				pextension, NVL(pestado_inegi,''), NVL(pmunicipio_inegi,''), NVL(plocalidad_inegi,''), NVL(pnociudad,0), 
				NVL(pnoext,''), NVL(pnoint,''), NVL(pdepto,''), NVL(pnocalle,0), NVL(pnocolonia,0), NVL(ppuntocar,''), 
				NVL(punihabi,''), NVL(pmanz,0), NVL(ppotros,0), NVL(pandador,0), NVL(petapa,0), NVL(plote,0), NVL(pedIF,0), 
				NVL(pentrada,0), NVL(pobserva,''), NVL(numcte_banco,''), NVL(puser_insert,''), CURRENT);
			
			END IF;
		RETURN v_codret;
	END IF;
END;
END PROCEDURE;