/**
 *  @file    cluster_parser.y
 *
 *  @author  Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 *  @copyright MIT License
 */

%skeleton "lalr1.cc"

%defines
%require "3.0.4"

%define parser_class_name {ClusterParser}

%define api.prefix {cluster}
%define api.namespace {Kitsunemimi::Hanami}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
#include <string>
#include <iostream>
#include <vector>
#include <libKitsunemimiCommon/items/data_items.h>
#include <libKitsunemimiHanamiClusterParser/cluster_meta.h>

using Kitsunemimi::DataItem;
using Kitsunemimi::DataArray;
using Kitsunemimi::DataValue;
using Kitsunemimi::DataMap;


namespace Kitsunemimi
{
namespace Hanami
{

class ClusterParserInterface;

}  // namespace Hanami
}  // namespace Kitsunemimi
}

// The parsing context.
%param { Kitsunemimi::Hanami::ClusterParserInterface& driver }

%locations

%code
{
#include <cluster_parsing/cluster_parser_interface.h>
# undef YY_DECL
# define YY_DECL \
    Kitsunemimi::Hanami::ClusterParser::symbol_type clusterlex (Kitsunemimi::Hanami::ClusterParserInterface& driver)
YY_DECL;
}

// Token
%define api.token.prefix {Cluster_}
%token
    END  0  "end of file"
    COMMA  ","
    ASSIGN  ":"
    ARROW  "->"
    LINEBREAK "linebreak"
    VERSION_1 "version1"
    OUT "out"
    NAME "name"
    SEGMENTS "segments"
;


%token <std::string> IDENTIFIER "identifier"
%token <std::string> STRING "string"
%token <std::string> STRING_PLN "string_pln"
%token <long> NUMBER "number"
%token <double> FLOAT "float"

%type  <std::string> string_ident
%type  <std::vector<Kitsunemimi::Hanami::SegmentConnectionMeta>> segments
%type  <Kitsunemimi::Hanami::SegmentConnectionMeta> segment
%type  <std::vector<Kitsunemimi::Hanami::ClusterConnection>> outputs
%type  <Kitsunemimi::Hanami::ClusterConnection> output

%%
%start startpoint;

// example
//
// version: 1
// segments:
//     input
//         name: input
//         out:
//             -> central : test_input
//
//     example_segment
//         name: central
//         out:
//             test_output -> output
//
//     output:
//         name: output

startpoint:
    "version1" linebreaks "segments" ":" linebreaks segments
    {
        driver.output->version = 1;
        driver.output->segments = $6;
    }

segments:
    segments segment
    {
        $$ = $1;
        $$.push_back($2);
    }
|
    segment
    {
        std::vector<SegmentConnectionMeta> outputs;
        outputs.push_back($1);
        $$ = outputs;
    }

segment:
    string_ident linebreaks "name" ":" string_ident linebreaks "out" ":" outputs
    {
        SegmentConnectionMeta segment;
        segment.type = $1;
        segment.name = $5;
        segment.outputs = $9;
        $$ = segment;
    }

outputs:
    outputs output
    {
        $$ = $1;
        $$.push_back($2);
    }
|
    output
    {
        std::vector<ClusterConnection> outputs;
        outputs.push_back($1);
        $$ = outputs;
    }

output:
    "->" string_ident ":" string_ident linebreaks_eno
    {
        ClusterConnection connection;
        connection.sourceBrick = "input";
        connection.targetCluster = $2;
        connection.targetBrick = $4;
        $$ = connection;
    }
|
    string_ident "->" string_ident linebreaks_eno
    {
        ClusterConnection connection;
        connection.sourceBrick = $1;
        connection.targetCluster = $3;
        connection.targetBrick = "output";
        $$ = connection;
    }
|
    string_ident "->" string_ident ":" string_ident linebreaks_eno
    {
        ClusterConnection connection;
        connection.sourceBrick = $1;
        connection.targetCluster = $3;
        connection.targetBrick = $5;
        $$ = connection;
    }

string_ident:
    "identifier"
    {
        $$ = $1;
    }
|
    "string"
    {
        $$ = $1;
    }

linebreaks:
    linebreaks "linebreak"
    {}
|
    "linebreak"
    {}

linebreaks_eno:
    linebreaks "linebreak"
    {}
|
    "linebreak"
    {}
|
    "end of file"
    {}

%%

void Kitsunemimi::Hanami::ClusterParser::error(const Kitsunemimi::Hanami::location& location,
                                               const std::string& message)
{
    driver.error(location, message);
}
