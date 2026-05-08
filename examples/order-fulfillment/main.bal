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

// A fulfillment-readiness workflow that pulls data from three submodules
// behind a single shared Connection: sales orders (`sales`), on-hand
// inventory (`warehouse`), and product master (`product`).
//
// The point: build the connection once, then hand it to as many domain
// clients as the workflow needs. There is exactly one underlying http:Client
// regardless of how many submodules participate.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm.common;
import ballerinax/microsoft.dynamics365.scm.product;
import ballerinax/microsoft.dynamics365.scm.sales;
import ballerinax/microsoft.dynamics365.scm.warehouse;
import ballerinax/microsoft.dynamics365.scm.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    // Build the shared connection once.
    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );

    // Inject it into every domain client this workflow needs.
    sales:Client so = check new (conn);
    warehouse:Client wh = check new (conn);
    product:Client prod = check new (conn);

    io:println("Open sales orders (USMF):");
    sales:SalesOrderHeadersV2Collection orders = check so->listSalesOrderHeadersV2();
    foreach sales:SalesOrderHeaderV2 s in orders.value ?: [] {
        io:println(string `  ${s.SalesOrderNumber ?: ""}   [${s.dataAreaId ?: ""}]`);
    }

    io:println("");
    io:println("Catalogued released products:");
    product:ReleasedProductsV2Collection products = check prod->listReleasedProductsV2();
    foreach product:ReleasedProductV2 p in products.value ?: [] {
        io:println(string `  ${p.ItemNumber ?: ""}   [${p.dataAreaId ?: ""}]`);
    }

    io:println("");
    io:println("On-hand inventory snapshot:");
    warehouse:WarehousesOnHandCollection snapshot = check wh->listWarehousesOnHand();
    foreach warehouse:WarehouseOnHand r in snapshot.value ?: [] {
        decimal avail = r.AvailableOnHandQuantity ?: 0d;
        io:println(string `  ${r.ItemNumber ?: ""}   site=${r.InventorySiteId ?: ""} wh=${r.InventoryWarehouseId ?: ""}   avail=${avail}`);
    }

    check mockListener.gracefulStop();
}
