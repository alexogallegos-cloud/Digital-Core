package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 4    FAN-OUT : 4    LOC approx: 239
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;

@Service
public class TrmService289 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final TrmRepository084 trmRepository084;
    private final UserService userService;
    private final ValidationUtils validationUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
