/**
 *  @file    cluster_parser_interface.h
 *
 *  @author  Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 *  @copyright MIT License
 */

#ifndef KITSUNEMIMI_HANAMI_CLUSTER_PARSER_PARSER_INTERFACE_H
#define KITSUNEMIMI_HANAMI_CLUSTER_PARSER_PARSER_INTERFACE_H

#include <iostream>
#include <mutex>

#include <libKitsunemimiCommon/logger.h>

namespace Kitsunemimi
{
namespace Hanami
{
struct ClusterMeta;
class location;

class ClusterParserInterface
{

public:
    static ClusterParserInterface* getInstance();
    ~ClusterParserInterface();

    // connection the the scanner and parser
    void scan_begin(const std::string &inputString);
    void scan_end();
    bool parse(ClusterMeta* result,
               const std::string &inputString,
               ErrorContainer &error);
    const std::string removeQuotes(const std::string &input);

    // Error handling.
    void error(const Kitsunemimi::Hanami::location &location,
               const std::string& message);

    ClusterMeta* output = nullptr;

private:
    ClusterParserInterface(const bool traceParsing = false);

    static ClusterParserInterface* m_instance;

    std::string m_errorMessage = "";
    std::string m_inputString = "";
    std::mutex m_lock;

    bool m_traceParsing = false;
};

}  // namespace Hanami
}  // namespace Kitsunemimi

#endif // KITSUNEMIMI_HANAMI_CLUSTER_PARSER_PARSER_INTERFACE_H
