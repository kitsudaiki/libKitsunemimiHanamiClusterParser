/**
 *  @file    cluster_meta.h
 *
 *  @author  Tobias Anker <tobias.anker@kitsunemimi.moe>
 *
 *  @copyright MIT License
 */

#ifndef KITSUNEMIMI_HANAMI_CLUSTER_PARSER_ITEM_H
#define KITSUNEMIMI_HANAMI_CLUSTER_PARSER_ITEM_H

#include <string>
#include <vector>
#include <map>

#include <libKitsunemimiCommon/logger.h>

namespace Kitsunemimi
{
namespace Hanami
{

struct ClusterConnection
{
    std::string sourceBrick = "";
    std::string targetCluster = "";
    std::string targetBrick = "";
};

struct SegmentConnectionMeta
{
    std::string name = "";
    std::string type = "";
    std::vector<ClusterConnection> outputs;
};

struct ClusterMeta
{
    uint32_t version = 0;
    std::vector<SegmentConnectionMeta> segments;
};

bool
parseCluster(ClusterMeta* result,
             const std::string &input,
             ErrorContainer &error);

}  // namespace Hanami
}  // namespace Kitsunemimi

#endif // KITSUNEMIMI_HANAMI_CLUSTER_PARSER_ITEM_H
