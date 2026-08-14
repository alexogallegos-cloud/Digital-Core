package mx.scotiabank.nomina.empresa;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmpresaRepository extends JpaRepository<Empresa, UUID> {
}
