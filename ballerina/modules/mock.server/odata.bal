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

// Minimal OData query application — supports what the demo needs:
// $top, $skip, $count, $select, cross-company, and a subset of $filter
// (eq on string/number, contains(X,'Y'), and startswith(X,'Y')).
// Not a complete OData implementation.

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

    string? orderByExpr = q.orderBy;
    if orderByExpr is string {
        filtered = applyOrderBy(filtered, orderByExpr);
    }

    int totalCount = filtered.length();

    int? skipN = q.skip;
    if skipN is int && skipN >= 0 {
        if skipN < filtered.length() {
            filtered = filtered.slice(skipN);
        } else {
            filtered = [];
        }
    }

    int? topN = q.top;
    if topN is int && topN >= 0 {
        if topN < filtered.length() {
            filtered = filtered.slice(0, topN);
        }
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

# Very small subset of OData $filter: supports
#   Field eq 'literal' | Field eq N | contains(Field,'literal') | startswith(Field,'literal')
# and conjunctions joined by ` and `.
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
    regexp:Groups? containsGroups = containsRe.findGroups(clause);
    if containsGroups is regexp:Groups && containsGroups.length() >= 3 {
        string fieldName = getGroup(containsGroups, 1);
        string needle = getGroup(containsGroups, 2);
        return from json row in data
            where rowContains(row, fieldName, needle)
            select row;
    }

    regexp:RegExp startsWithRe = re `^startswith\((\w+),\s*'([^']*)'\)$`;
    regexp:Groups? swGroups = startsWithRe.findGroups(clause);
    if swGroups is regexp:Groups && swGroups.length() >= 3 {
        string fieldName = getGroup(swGroups, 1);
        string prefix = getGroup(swGroups, 2);
        return from json row in data
            where rowStartsWith(row, fieldName, prefix)
            select row;
    }

    regexp:RegExp eqRe = re `^(\w+)\s+eq\s+(.*)$`;
    regexp:Groups? eqGroups = eqRe.findGroups(clause);
    if eqGroups is regexp:Groups && eqGroups.length() >= 3 {
        string fieldName = getGroup(eqGroups, 1);
        string rhs = getGroup(eqGroups, 2).trim();
        return from json row in data
            where rowEquals(row, fieldName, rhs)
            select row;
    }

    return data;
}

isolated function getGroup(regexp:Groups groups, int i) returns string {
    regexp:Span? span = groups[i];
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

isolated function rowStartsWith(json row, string fieldName, string prefix) returns boolean {
    string? v = lookupString(row, fieldName);
    return v is string && v.toLowerAscii().startsWith(prefix.toLowerAscii());
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
    if rhs == "true" || rhs == "false" {
        return val is boolean && val == (rhs == "true");
    }
    // Numeric comparison: coerce both sides to decimal so `eq 250000` matches
    // a JSON-parsed 250000.00 and vice versa.
    decimal|error asDec = decimal:fromString(rhs);
    if asDec is decimal {
        decimal? valAsDec = ();
        if val is int {
            valAsDec = <decimal>val;
        } else if val is decimal {
            valAsDec = val;
        } else if val is float {
            valAsDec = <decimal>val;
        }
        return valAsDec is decimal && valAsDec == asDec;
    }
    return false;
}

isolated function applyOrderBy(json[] data, string expr) returns json[] {
    string trimmed = expr.trim();
    boolean isDesc = false;
    string fieldName = trimmed;
    if trimmed.endsWith(" desc") {
        isDesc = true;
        fieldName = trimmed.substring(0, trimmed.length() - 5).trim();
    } else if trimmed.endsWith(" asc") {
        fieldName = trimmed.substring(0, trimmed.length() - 4).trim();
    }
    // Detect whether the field is numeric by sampling; numeric fields must be
    // sorted by decimal value so `10` does not lexicographically sort before `2`.
    boolean numeric = isNumericSortField(data, fieldName);
    if numeric {
        if isDesc {
            return from json row in data
                let decimal sk = numericSortKey(row, fieldName)
                order by sk descending
                select row;
        }
        return from json row in data
            let decimal sk = numericSortKey(row, fieldName)
            order by sk ascending
            select row;
    }
    if isDesc {
        return from json row in data
            let string sk = sortKey(row, fieldName)
            order by sk descending
            select row;
    }
    return from json row in data
        let string sk = sortKey(row, fieldName)
        order by sk ascending
        select row;
}

isolated function isNumericSortField(json[] data, string fieldName) returns boolean {
    foreach json row in data {
        if !(row is map<json>) {
            continue;
        }
        json? val = row[fieldName];
        if val is int || val is float || val is decimal {
            return true;
        }
        if val is string || val is boolean {
            return false;
        }
    }
    return false;
}

isolated function numericSortKey(json row, string fieldName) returns decimal {
    if !(row is map<json>) {
        return 0d;
    }
    json? val = row[fieldName];
    if val is int {
        return <decimal>val;
    }
    if val is decimal {
        return val;
    }
    if val is float {
        return <decimal>val;
    }
    return 0d;
}

isolated function sortKey(json row, string fieldName) returns string {
    if !(row is map<json>) {
        return "";
    }
    json? val = row[fieldName];
    if val is string {
        return val;
    }
    if val is () {
        return "";
    }
    return val.toString();
}
