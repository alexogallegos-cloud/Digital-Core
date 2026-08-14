package com.openpay.dashboard.channels;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : channels
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 6    LOC approx: 339
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ChnEntity;
import com.openpay.dto.ChnResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class ChnService237 {

    // Collaborators (match the graph call edges):
    private final ChnRepository026 chnRepository026;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final RskService251 rskService251;
    private final StringUtils stringUtils;
    private final UserService userService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
