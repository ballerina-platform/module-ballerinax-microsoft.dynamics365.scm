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

// Minimal OData query application for the mock: $top, $skip, $count, $select,
// cross-company, and a small subset of $filter (eq, contains, startswith).

import ballerina/lang.regexp;

type ODataQueries record {|
    string? selectFields;
    string? filter;
    int? top;
    int? skip;
    string? orderBy;
    string? expand;
    boolean? count;
    boolean? crossCompany;
|};

isolated function parseQueries(map<string[]> params) returns ODataQueries {
    return {
        selectFields: firstOrNil(params, "$select"),
        filter: firstOrNil(params, "$filter"),
        top: parseInt(firstOrNil(params, "$top")),
        skip: parseInt(firstOrNil(params, "$skip")),
        orderBy: firstOrNil(params, "$orderby"),
        expand: firstOrNil(params, "$expand"),
        count: parseBool(firstOrNil(params, "$count")),
        crossCompany: parseBool(firstOrNil(params, "cross-company"))
    };
}

isolated function firstOrNil(map<string[]> params, string key) returns string? {
    string[]? values = params[key];
    return values is string[] && values.length() > 0 ? values[0] : ();
}

isolated function parseInt(string? s) returns int? {
    if s is () {
        return ();
    }
    int|error n = int:fromString(s);
    return n is int ? n : ();
}

isolated function parseBool(string? s) returns boolean? {
    if s is () {
        return ();
    }
    return s.toLowerAscii() == "true";
}

isolated function buildCollection(string contextBase, string entitySet, json[] data, ODataQueries q,
        string defaultCompany) returns map<json> {
    json[] filtered = data;

    if !(q.crossCompany ?: false) {
        filtered = from json row in filtered
            where !(row is map<json>) || lookupString(row, "dataAreaId") is () || lookupString(row, "dataAreaId") == defaultCompany
            select row;
    }

    string? filterExpr = q.filter;
    if filterExpr is string {
        filtered = applyFilter(filtered, filterExpr);
    }

    int totalCount = filtered.length();

    int? skipN = q.skip;
    if skipN is int && skipN >= 0 && skipN < filtered.length() {
        filtered = filtered.slice(skipN);
    } else if skipN is int && skipN >= filtered.length() {
        filtered = [];
    }

    int? topN = q.top;
    if topN is int && topN >= 0 && topN < filtered.length() {
        filtered = filtered.slice(0, topN);
    }

    string? selectExpr = q.selectFields;
    if selectExpr is string {
        string[] fields = re `,`.split(selectExpr);
        filtered = from json row in filtered
            select projectRow(row, fields);
    }

    map<json> envelope = {
        "@odata.context": string `${contextBase}$metadata#${entitySet}`,
        "value": filtered
    };
    if q.count ?: false {
        envelope["@odata.count"] = totalCount;
    }
    return envelope;
}

isolated function projectRow(json row, string[] fields) returns json {
    if !(row is map<json>) {
        return row;
    }
    map<json> projected = {};
    foreach string f in fields {
        string trimmed = f.trim();
        json? val = row[trimmed];
        if val is json {
            projected[trimmed] = val;
        }
    }
    return projected;
}

isolated function applyFilter(json[] data, string expr) returns json[] {
    string[] conjuncts = re ` and `.split(expr.trim());
    json[] result = data;
    foreach string clause in conjuncts {
        result = applyClause(result, clause.trim());
    }
    return result;
}

isolated function applyClause(json[] data, string clause) returns json[] {
    regexp:RegExp containsRe = re `^contains\((\w+),\s*'([^']*)'\)$`;
    regexp:Groups? g = containsRe.findGroups(clause);
    if g is regexp:Groups && g.length() >= 3 {
        string f = getGroup(g, 1);
        string needle = getGroup(g, 2);
        return from json row in data
            where rowContains(row, f, needle)
            select row;
    }
    regexp:RegExp eqRe = re `^(\w+)\s+eq\s+(.*)$`;
    regexp:Groups? eg = eqRe.findGroups(clause);
    if eg is regexp:Groups && eg.length() >= 3 {
        string f = getGroup(eg, 1);
        string rhs = getGroup(eg, 2).trim();
        return from json row in data
            where rowEquals(row, f, rhs)
            select row;
    }
    return data;
}

isolated function getGroup(regexp:Groups g, int i) returns string {
    regexp:Span? span = g[i];
    return span is regexp:Span ? span.substring() : "";
}

isolated function lookupString(json row, string fieldName) returns string? {
    if !(row is map<json>) {
        return ();
    }
    json? v = row[fieldName];
    return v is string ? v : ();
}

isolated function rowContains(json row, string fieldName, string needle) returns boolean {
    string? v = lookupString(row, fieldName);
    return v is string && v.toLowerAscii().includes(needle.toLowerAscii());
}

isolated function rowEquals(json row, string fieldName, string rhs) returns boolean {
    if !(row is map<json>) {
        return false;
    }
    json? val = row[fieldName];
    if val is () {
        return false;
    }
    if rhs.startsWith("'") && rhs.endsWith("'") {
        string literal = rhs.substring(1, rhs.length() - 1);
        return val is string && val == literal;
    }
    return false;
}
