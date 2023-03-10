// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract OnChainOracle {
    uint256 private nonce;

    address private immutable offChainOracleAddress;

    uint256 private immutable fee;

    event newRequest(uint256 requestId, int256 lat, int256 log);
    event requestCompleted(uint256 requestId, string temp);

    constructor(address _offChainOracleAddress, uint256 _fee) {
        offChainOracleAddress = _offChainOracleAddress;
        fee = _fee;
    }

    function makeWeatherRequest(
        int256 _lat,
        int256 _lon
    ) internal returns (uint256) {
        (bool sent, ) = payable(offChainOracleAddress).call{value: fee}("");
        require(sent, "Failed to send Fee");
        uint256 requestId = uint(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        );
        emit newRequest(requestId, _lat, _lon);
        nonce++;
        return requestId;
    }

    function rawCompleteRequest(
        uint256 _requestId,
        string memory _temp
    ) external {
        require(msg.sender == offChainOracleAddress, "Only oracle can call");
        completeRequest(_requestId, _temp);
        emit requestCompleted(_requestId, _temp);
    }

    function completeRequest(
        uint256 _requestId,
        string memory _temp
    ) internal virtual;
}
