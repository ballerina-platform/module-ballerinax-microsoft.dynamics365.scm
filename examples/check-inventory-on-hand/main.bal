// Check on-hand inventory for an item across every site/warehouse/status.
// Demonstrates $filter, cross-company, and reading quantity fields from the
// response. Typical use: answer "do we have N of item X anywhere?"

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm;
import ballerinax/microsoft.dynamics365.scm.mock.server;

const string ITEM = "ITM-1001";

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    scm:Client fo = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );

    scm:InventoryOnHandCollection snapshot = check fo->listInventoryOnHand(queries = {
        filter: "ItemNumber eq '" + ITEM + "'",
        orderBy: "AvailablePhysicalQuantity desc",
        crossCompany: true
    });

    scm:InventoryOnHand[] rows = <scm:InventoryOnHand[]>snapshot.value;
    io:println(string `On-hand snapshot for ${ITEM} (${rows.length()} locations):`);

    decimal totalAvailable = 0d;
    foreach scm:InventoryOnHand r in rows {
        decimal avail = r.AvailablePhysicalQuantity ?: 0d;
        totalAvailable += avail;
        io:println(string `  [${r.dataAreaId ?: ""}] site=${r.SiteId ?: ""} wh=${r.WarehouseId ?: ""} loc=${r.LocationId ?: ""} status=${r.InventoryStatusId ?: ""}  avail=${avail} ${r.UnitSymbol ?: ""}`);
    }

    io:println("");
    io:println(string `Total available across all locations: ${totalAvailable}`);

    check mockListener.gracefulStop();
}
