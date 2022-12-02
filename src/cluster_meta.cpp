/**
 *  @file    cluster_meta.cpp
 *
 *  @author  Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 *  @copyright MIT License
 */

#include <libKitsunemimiHanamiClusterParser/cluster_meta.h>
#include <cluster_parsing/cluster_parser_interface.h>

namespace Kitsunemimi
{
namespace Hanami
{

struct ClusterMeta
{

};

/**
 * @brief convert a cluster-formated string into a cluster-object-tree
 *
 * @param input cluster-formated string, which should be parsed
 * @param error reference for error-message output
 *
 * @return true, if successful, else false
 */
bool
parseCluster(ClusterMeta* result,
             const std::string &input,
             ErrorContainer &error)
{
    ClusterParserInterface* parser = ClusterParserInterface::getInstance();

    if(input.size() == 0)
    {
        // TODO: error-message
        return false;
    }

    return parser->parse(result, input, error);
}

}  // namespace Hanami
}  // namespace Kitsunemimi
