#include <iostream>
#include <string>
#include <s2/s2region_coverer.h>
#include <s2/s2metrics.h>
#include <s2/s2earth.h>
#include <s2/s2latlng.h>
#include <s2/s2loop.h>
#include <nlohmann/json.hpp>
#include <vector>
#include <fstream>
using namespace std;
using json = nlohmann::json;
/*
*使用S2Loop创建单个封闭凸多边形区域
*/
json cover_single_polygone(int level, int max_cell_num, vector<S2Point> multiPointData){
    S2RegionCoverer::Options options;
    options.set_fixed_level(level);
    options.set_max_cells(max_cell_num);
    S2RegionCoverer cover(options);
    S2Loop *loop = new S2Loop(multiPointData, S2Debug::DISABLE);
//    cout<<"space Used:"<<loop->SpaceUsed()<<endl;
    if(!(loop->IsNormalized()))
        loop->Invert();
    S2CellUnion covering = cover.GetCovering(*loop);
    json result = {};
    for(auto point : covering.cell_ids())
        result.push_back({point.ToLatLng().Normalized().lng().degrees(),
                         point.ToLatLng().Normalized().lat().degrees()});
    delete loop;
    return result;
}

int main(int argc, char* argv[])
{
    if(argc < 4){
        cout<<"please input cell length in km: maximum cell number: json file path: "<<endl;
        return -1;
    }
    double cell_length_in_km = stod(argv[1]);
    auto cell_level = S2::kAvgEdge.GetClosestLevel(S2Earth::KmToRadians(cell_length_in_km));
    ifstream i(argv[3]);
    json target = json::parse(i);
    vector<S2Point> multiPointData;
    for(auto item : target["geometry"]["coordinates"][0]){
        multiPointData.clear();
        for(auto point : item)
            multiPointData.push_back(S2LatLng::FromDegrees(point[1], point[0]).ToPoint());
        json result = cover_single_polygone(cell_level, stoi(argv[2]), multiPointData);
        cout << result << endl;
    }

    return 0;
}
