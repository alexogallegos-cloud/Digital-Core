-- =============================================================================
-- db-init · crea la base de datos 'nomina' antes de que Flyway aplique migraciones.
-- Flyway crea/gestiona los objetos dentro de la BD, pero no la BD misma.
-- Solo mock. En prod la BD la aprovisiona la plataforma de datos.
-- =============================================================================
IF DB_ID('nomina') IS NULL
BEGIN
    CREATE DATABASE nomina;
END
GO
