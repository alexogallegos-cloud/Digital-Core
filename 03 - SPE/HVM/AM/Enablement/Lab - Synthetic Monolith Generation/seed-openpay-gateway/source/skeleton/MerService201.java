package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 4    FAN-OUT : 6    LOC approx: 499
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MerRequest;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class MerService201 {

    // Collaborators (match the graph call edges):
    private final BinManagerService binManagerService;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final MerRepository083 merRepository083;
    private final RbacService rbacService;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
