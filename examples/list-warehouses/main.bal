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

// List warehouses - showcases default-company scoping, cross-company override,
// and filtering warehouses by type.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm;
import ballerinax/microsoft.dynamics365.scm.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    scm:Client fo = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );

    io:println("Default company (USMF) warehouses:");
    scm:WarehousesCollection page = check fo->listWarehouses(queries = {top: 10});
    printWarehouses(<scm:Warehouse[]>page.value);

    io:println("");
    io:println("Transit-type warehouses across all companies:");
    scm:WarehousesCollection transit = check fo->listWarehouses(queries = {
        filter: "WarehouseTypeId eq 'Transit'",
        crossCompany: true
    });
    printWarehouses(<scm:Warehouse[]>transit.value);

    check mockListener.gracefulStop();
}

function printWarehouses(scm:Warehouse[] rows) {
    foreach scm:Warehouse w in rows {
        io:println(string `  ${w.WarehouseId ?: ""}   ${w.WarehouseName ?: ""}   site=${w.SiteId ?: ""}   type=${w.WarehouseTypeId ?: ""}   [${w.dataAreaId ?: ""}]`);
    }
}
