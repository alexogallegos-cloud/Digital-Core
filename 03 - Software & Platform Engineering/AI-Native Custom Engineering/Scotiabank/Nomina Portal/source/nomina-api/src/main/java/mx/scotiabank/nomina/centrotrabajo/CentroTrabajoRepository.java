package mx.scotiabank.nomina.centrotrabajo;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CentroTrabajoRepository extends JpaRepository<CentroTrabajo, UUID> {
    boolean existsByIdCentroTrabajoAndIdEmpresa(UUID idCentroTrabajo, UUID idEmpresa);

    List<CentroTrabajo> findByIdEmpresa(UUID idEmpresa);

    long countByIdEmpresa(UUID idEmpresa);
}
