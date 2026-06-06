package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 6    FAN-OUT : 6    LOC approx: 242
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinRequest;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class FinService267 {

    // Collaborators (match the graph call edges):
    private final FinRepository080 finRepository080;
    private final FinService291 finService291;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final TrmService037 trmService037;
    private final TrmService278 trmService278;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
