package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : REPO                 ACCESS : update (writes)
//  FAN-IN    : 7    FAN-OUT : 1    LOC approx: 166
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MerRequest;
import com.openpay.dto.MerResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Repository
public class MerRepository083 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
