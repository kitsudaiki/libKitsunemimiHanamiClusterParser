%{ /* -*- C++ -*- */
/**
 * @file       cluster_lexer.l
 *
 * @author     Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 * @copyright  Apache License Version 2.0
 *
 *      Copyright 2022 Tobias Anker
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *          http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */

# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include <cluster_parsing/cluster_parser_interface.h>
# include <cluster_parser.h>

# undef yywrap
# define yywrap() 1


// The location of the current token.
# ifdef YY_DECL
# undef YY_DECL
# endif
# define YY_DECL \
    Kitsunemimi::Hanami::ClusterParser::symbol_type clusterlex (Kitsunemimi::Hanami::ClusterParserInterface& driver)
YY_DECL;
Kitsunemimi::Hanami::location clusterloc;

%}


%option noyywrap nounput batch debug yylineno prefix="cluster"

id    [a-zA-Z_0-9]*
long  -?([0-9]+)
double -?([0-9]+)\.([0-9]+)
blank [ \t]

%{
    # define YY_USER_ACTION  clusterloc.columns (yyleng);
%}

%%

%{
    clusterloc.step();
%}

{blank}+       clusterloc.step();
[\n]           {clusterloc.lines(1); return Kitsunemimi::Hanami::ClusterParser::make_LINEBREAK (clusterloc); }
"version:1"    return Kitsunemimi::Hanami::ClusterParser::make_VERSION_1 (clusterloc);
"version: 1"   return Kitsunemimi::Hanami::ClusterParser::make_VERSION_1 (clusterloc);
":"            return Kitsunemimi::Hanami::ClusterParser::make_ASSIGN (clusterloc);
"->"           return Kitsunemimi::Hanami::ClusterParser::make_ARROW (clusterloc);
"out"          return Kitsunemimi::Hanami::ClusterParser::make_OUT (clusterloc);
"name"         return Kitsunemimi::Hanami::ClusterParser::make_NAME (clusterloc);
"segments"     return Kitsunemimi::Hanami::ClusterParser::make_SEGMENTS (clusterloc);

\"(\\.|[^"\\])*\" { return Kitsunemimi::Hanami::ClusterParser::make_STRING(yytext, clusterloc); }

{id}       return Kitsunemimi::Hanami::ClusterParser::make_IDENTIFIER(yytext, clusterloc);

[a-zA-Z_0-9|\-|.]* {
    return Kitsunemimi::Hanami::ClusterParser::make_STRING_PLN(yytext, clusterloc);
}

.          driver.error(clusterloc, "invalid character");
<<EOF>>    return Kitsunemimi::Hanami::ClusterParser::make_END(clusterloc);

%%


void Kitsunemimi::Hanami::ClusterParserInterface::scan_begin(const std::string &inputString)
{
    Kitsunemimi::Hanami::location newClusterloc;
    clusterloc = newClusterloc;
    yy_flex_debug = m_traceParsing;
    yy_scan_string(inputString.c_str());
}

void Kitsunemimi::Hanami::ClusterParserInterface::scan_end()
{
    yy_delete_buffer(YY_CURRENT_BUFFER);
}


