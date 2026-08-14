package mx.scotiabank.nomina.nomina;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DetalleNominaRepository extends JpaRepository<DetalleNomina, UUID> {
    List<DetalleNomina> findByIdNomina(UUID idNomina);

    void deleteByIdNomina(UUID idNomina);
}
