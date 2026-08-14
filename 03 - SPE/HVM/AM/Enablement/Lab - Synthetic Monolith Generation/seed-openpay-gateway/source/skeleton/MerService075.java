package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 1    FAN-OUT : 5    LOC approx: 451
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class MerService075 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final MerRepository029 merRepository029;
    private final MerService123 merService123;
    private final ValidationUtils validationUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
