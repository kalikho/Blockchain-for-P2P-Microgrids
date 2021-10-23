// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title p2p_microgrid
 * @dev 
 */
contract p2p_microgrid {

    uint256 number;
    
    struct Path{
        bytes16 tradeID;
        address hopID;
        address _in;
        address out;
        uint256 energy;
        bytes16 tradeDate;
        bytes32 upTime;
        bytes32 shutTime;
    }
    
    struct node{
        bytes32 date;
        bytes32 time;
        mapping(address=>bytes32) incomingErg;
    }
    

    mapping(address=>mapping(address=>uint256)) public availableCapacity;
    mapping(address=>mapping(address=>uint256)) public totalCapacity;
    mapping(address=>mapping(address=>uint256)) public inUse;
    mapping(address=>address[]) public neighbors;
    mapping(address=>node) public Node;
    mapping(bytes16=>mapping(address=>Path)) public path;
    mapping(address=>mapping(address=>uint256)) public energyStatus;
    
    address owner;
    
    constructor(){
        owner = msg.sender;    
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    modifier isSufficientCapacity(address inNode,address outNode, uint256 energy){
        require(availableCapacity[inNode][msg.sender] >= energy && availableCapacity[msg.sender][outNode] >=energy);
        _;
    }


    function set_date_time_erg(bytes32 date, bytes32 time, uint256 energy,address hopID ) public {
        Node[msg.sender].date = date;
        Node[msg.sender].time = time;
        energyStatus[msg.sender][hopID] = energy;
    }
    
    function getDate() public view returns (bytes32){
        return Node[msg.sender].date;    
    }
    
    function getTime() public view returns(bytes32){
        return Node[msg.sender].time;    
    }
    
    function getIncomingEnergy() public view returns (uint256){
        return energyStatus[msg.sender][msg.sender];
    }
    
    function Link_Capacity_Update() public {
        for(uint256 i=0; i<neighbors[msg.sender].length; i++){
            availableCapacity[msg.sender][neighbors[msg.sender][i]] = totalCapacity[msg.sender][neighbors[msg.sender][i]] - inUse[msg.sender][neighbors[msg.sender][i]];
        }
    }
    
    function setupLink(address hopID_1,address hopID_2, uint256 capacity) onlyOwner public {
        availableCapacity[hopID_1][hopID_2] = capacity;
        totalCapacity[hopID_1][hopID_2] = capacity;
        inUse[hopID_1][hopID_2] = 0;
    }
    
    function setNeighbors(address _neighbors) onlyOwner public {
        neighbors[msg.sender].push(_neighbors);
    }
    
    function Link_Reservation(bytes16  tradeID, address  hopID, address  inNode, address  outNode, uint256  energyUnits, bytes16 tradeDate, bytes32 upTime, bytes32 shutTime) isSufficientCapacity( inNode, outNode,  energyUnits) public {
            path[tradeID][hopID]._in = inNode;
            path[tradeID][hopID].out = outNode;
            path[tradeID][hopID].energy = energyUnits;
            path[tradeID][hopID].tradeDate = tradeDate;
            path[tradeID][hopID].upTime = upTime;
            path[tradeID][hopID].shutTime = shutTime;
    }
    
    
    function Raise_Alert(bytes16  tradeID, address  hopID) view public returns(int8){
        uint256 expectedEnergy = path[tradeID][hopID].energy;
        if(path[tradeID][hopID].tradeDate == getDate()){
            if(path[tradeID][hopID].upTime <= getTime()){
                if(path[tradeID][hopID].shutTime > getTime()){
                    if(getIncomingEnergy() < expectedEnergy){
                        return -1; //Underflow
                    }else if(getIncomingEnergy() > expectedEnergy){
                        return 1;  //Overflow
                    }else{
                        return 0;  //Normalflow
                    }
                }else{
                    return 2; // Invalid : Shut time cannot be lesser than getTime
                }
            }else{
                return 3; // upTime cannot be greater than getTime 
            }
        }else{
            return 4; // Trade date must be equal to current date or transmission won't happen
        }
    }   
}