// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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
