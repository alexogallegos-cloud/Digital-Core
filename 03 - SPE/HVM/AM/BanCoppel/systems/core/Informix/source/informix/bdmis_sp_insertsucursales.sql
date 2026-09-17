CREATE PROCEDURE "informix".sp_insertsucursales()
    returning char(4), char(1);

	--Elaboró: Nubia Janeth Monotya
	--Actividad: Inserta Registros de una Base de Datos a otra
	--Solicito: Mauricio León
	--Fecha: 29-04-2009
	
-- Declara variables
    DEFINE vCR char(4);
    DEFINE vTipo char(1);
    DEFINE intcodret   INT;

-- Inicializa variables
    LET vCR = "";
    LET vTipo = "";
    LET intcodret = 0;

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET vCR = intcodret;
            return vCR, vTipo;
        END IF;
    END EXCEPTION;

    Foreach

        SELECT CR, tipo
        INTO vCR, vTipo
        FROM bdmis:tmp_sucursalesinfo

        IF EXISTS (Select num_sucursal From bdmis:mi_sucursalesinfo where num_sucursal = vCR) THEN
            UPDATE mi_sucursalesinfo SET Tipo_suc = vTipo WHERE num_sucursal = vCR;
        ELSE
            return vCR, vTipo WITH RESUME;
        END IF ;


    END foreach;

END;

END PROCEDURE;