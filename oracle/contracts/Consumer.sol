// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./OnChainOracle.sol";

contract Consumer is OnChainOracle {
    uint256 public count;

    uint256 public fee;

    struct weatherRequest {
        int256 lat;
        int256 lon;
        bool status;
        string temp;
    }

    mapping(uint256 => weatherRequest) weatherRequests;

    mapping(uint256 => uint256) ids;

    constructor(
        address _offChainOracle,
        uint256 _fee
    ) OnChainOracle(_offChainOracle, _fee) {
        fee = _fee;
    }

    function getWeather(int256 _lat, int256 _lon) external payable {
        require(msg.value >= fee, "not enough fee for request");
        require(_lat <= 90 && _lon < 180, "Invalid location given");
        uint256 requestId = makeWeatherRequest(_lat, _lon);
        weatherRequests[requestId] = weatherRequest({
            lat: _lat,
            lon: _lon,
            status: false,
            temp: "0"
        });
        ids[count] = requestId;
        count++;
    }

    function completeRequest(
        uint256 _requestId,
        string memory _temp
    ) internal virtual override {
        require(!weatherRequests[_requestId].status, "Invalid Request ID");
        weatherRequests[_requestId].temp = _temp;
        weatherRequests[_requestId].status = true;
    }

    function viewRequest(
        uint256 _countId
    ) external view returns (weatherRequest memory) {
        uint256 requestId = ids[_countId];

        return weatherRequests[requestId];
    }
}
