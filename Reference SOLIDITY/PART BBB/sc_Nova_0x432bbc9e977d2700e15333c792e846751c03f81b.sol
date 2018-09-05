/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.17;

contract NovaAccessControl {
  mapping (address => bool) managers;
  address public cfoAddress;

  function NovaAccessControl() public {
    managers[msg.sender] = true;
  }

  modifier onlyManager() {
    require(managers[msg.sender]);
    _;
  }

  function setManager(address _newManager) external onlyManager {
    require(_newManager != address(0));
    managers[_newManager] = true;
  }

  function removeManager(address mangerAddress) external onlyManager {
    require(mangerAddress != msg.sender);
    managers[mangerAddress] = false;
  }

  function updateCfo(address newCfoAddress) external onlyManager {
    require(newCfoAddress != address(0));
    cfoAddress = newCfoAddress;
  }
}

contract NovaCoin is NovaAccessControl {
  string public name;
  string public symbol;
  uint256 public totalSupply;
  address supplier;
  // 1:1 convert with currency, so to cent
  uint8 public decimals = 2;
  mapping (address => uint256) public balanceOf;
  address public novaContractAddress;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(address indexed from, uint256 value);
  event NovaCoinTransfer(address indexed to, uint256 value);

  function NovaCoin(uint256 initialSupply, string tokenName, string tokenSymbol) public {
    totalSupply = initialSupply * 10 ** uint256(decimals);
    supplier = msg.sender;
    balanceOf[supplier] = totalSupply;
    name = tokenName;
    symbol = tokenSymbol;
  }

  function _transfer(address _from, address _to, uint _value) internal {
    require(_to != 0x0);
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value > balanceOf[_to]);
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
  }

  // currently only permit NovaContract to consume
  function transfer(address _to, uint256 _value) external {
    _transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value);
  }

  function novaTransfer(address _to, uint256 _value) external onlyManager {
    _transfer(supplier, _to, _value);
    NovaCoinTransfer(_to, _value);
  }

  function updateNovaContractAddress(address novaAddress) external onlyManager {
    novaContractAddress = novaAddress;
  }

  // This is function is used for sell Nova properpty only
  // coin can only be trasfered to invoker, and invoker must be Nova contract
  function consumeCoinForNova(address _from, uint _value) external {
    require(msg.sender == novaContractAddress);
    require(balanceOf[_from] >= _value);
    var _to = novaContractAddress;
    require(balanceOf[_to] + _value > balanceOf[_to]);
    uint previousBalances = balanceOf[_from] + balanceOf[_to];
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
  }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <