CREATE PROCEDURE "informix".sp_obtenermenuoperador_bei(pIdusario INTEGER, pRegInicial INTEGER)
RETURNING CHAR(5), INTEGER, INTEGER, INTEGER, CHAR(100), CHAR(150), SMALLINT, CHAR(50), CHAR(150), CHAR(150), SMALLINT, SMALLINT;

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER; 	
 	DEFINE id_menu INTEGER; 
    DEFINE id_menu_padre INTEGER;
    DEFINE nombre CHAR(100);

    DEFINE factory CHAR(150); 
    DEFINE nivel SMALLINT; 
    DEFINE id_factory CHAR(50);    
    DEFINE contenedor CHAR(150);
    DEFINE parametros CHAR(150);
    DEFINE tipo SMALLINT;
    DEFINE TotalReg INTEGER;
	DEFINE TipoUsuario SMALLINT;
	DEFINE activo SMALLINT;

 	LET cod_ret= "00000";
    LET id_menu = NULL;
    LET id_menu_padre = NULL;
    LET nombre = NULL;
    LET factory = NULL;
    LET nivel = NULL;
    LET id_factory = NULL;    
    LET contenedor = NULL;
    LET parametros = NULL;
    LET tipo = NULL;
    LET TotalReg = 0;
	LET TipoUsuario = 0;
	LET activo = 0;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, TotalReg, id_menu, id_menu_padre, nombre, factory, 
                nivel, id_factory, contenedor, parametros, tipo, activo;
      END IF ;
    END EXCEPTION ;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT USUARIO.id_tipo_usuario
		INTO TipoUsuario
	FROM "informix".bei_usuario AS USUARIO
	WHERE USUARIO.id_usuario = pIdusario;

    SELECT COUNT(*)
    INTO TotalReg
    FROM (
			SELECT  DISTINCT ID_MENU_OPER
			FROM "informix".bei_operaciones AS operaciones
				INNER JOIN "informix".bei_usuario_perfil AS usuario_perfil ON usuario_perfil.id_perfil = operaciones.id_perfil
				INNER JOIN "informix".bei_usuario AS usuario ON usuario.id_usuario = usuario_perfil.id_usuario
			WHERE usuario.id_usuario = pIdusario
		   ) AS operaciones
		   RIGHT JOIN "informix".bei_menu_oper as menu_oper ON menu_oper.id_menu_oper = operaciones.id_menu_oper
		   INNER JOIN "informix".bei_menu AS menu ON menu.id_menu = menu_oper.id_menu
	WHERE menu_oper.tipo_menu = TipoUsuario;	

    IF(TotalReg = 0) THEN
        LET cod_ret = '00001';
        RETURN cod_ret, TotalReg, id_menu, id_menu_padre, nombre, factory, 
                nivel, id_factory, contenedor, parametros, tipo, activo;
    END IF;
        
    FOREACH
		SELECT SKIP pRegInicial FIRST 10 
				menu.id_menu, menu.id_menu_padre, menu.nombre, menu.factory, menu.nivel, 
				menu.id_factory, menu.contenedor, menu.parametros, menu.tipo,
				CASE 
					WHEN operaciones.ID_MENU_OPER IS NULL THEN 0
					ELSE 1
				END
		INTO id_menu, id_menu_padre, nombre, factory, 
            nivel, id_factory, contenedor, parametros, tipo, activo
		FROM (
				SELECT  DISTINCT ID_MENU_OPER
				FROM "informix".bei_operaciones AS operaciones
					INNER JOIN "informix".bei_usuario_perfil AS usuario_perfil ON usuario_perfil.id_perfil = operaciones.id_perfil
					INNER JOIN "informix".bei_usuario AS usuario ON usuario.id_usuario = usuario_perfil.id_usuario
				WHERE usuario.id_usuario = pIdusario
			   ) AS operaciones
			   RIGHT JOIN "informix".bei_menu_oper as menu_oper ON menu_oper.id_menu_oper = operaciones.id_menu_oper
			   INNER JOIN "informix".bei_menu AS menu ON menu.id_menu = menu_oper.id_menu
		where menu_oper.tipo_menu = TipoUsuario
		ORDER BY  menu.id_menu_padre

		RETURN cod_ret, TotalReg, id_menu, id_menu_padre, nombre, factory, 
			nivel, id_factory, contenedor, parametros, tipo, activo WITH RESUME;

    END FOREACH
END

END PROCEDURE;