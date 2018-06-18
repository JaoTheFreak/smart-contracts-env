pragma solidity ^0.4.16;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal payable {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0x0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken, Pausable {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0x0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant whenNotPaused returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
  function increaseApproval (address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract EletronicVote is StandardToken {
    using SafeMath for uint256;

    //Information coin
    string public name = "Eletronic Vote";
    string public symbol = "EV";
    uint256 public decimals = 18;
    uint256 public totalSupply = 100 * (10 ** decimals); //100 EV
    
    address myWallet = 0xFcc928D02b580Cf2409490C474f4010610cfB32a;
    
    mapping(uint256 => address) CodigoCandidato;
    mapping(address => Voto) votoEleitor;
   
    struct Voto {
         bool votoPresidente;
         bool votoVereador;
         bool votoDeputado;
         uint256 codPresidente;
         uint256 codVereador;
         uint256 codDeputado;
    }
    
    uint256 votosNullos;
        
    constructor() public payable {
        balances[myWallet] = balances[myWallet].add(totalSupply);
        votosNullos = 0;
        CodigoCandidato[1010] = 0x1FCd3619Ec673fc97D8b8d9d6fCb938cC875D0EF;
        CodigoCandidato[2020] = 0x812569A19C2B244A68fb158c474ABBD3D22d12b7;
        CodigoCandidato[3030] = 0xf77D44af8Ae8D37EC5B1da7818325899aE48544B;
    }
    
    //function CheckWinner() public returns (uint256 codigoCandidatoVencedor){    }
    
    function newCadidate(uint256 candidateCode, address candidateAddrWallet) public constant returns (bool success){
        
        CodigoCandidato[candidateCode] = candidateAddrWallet;
        
        return true;
    }
    
    function VerificaVotosNulos() public constant returns (uint256 votosNulos){
        return votosNullos;
    }
    
    function VerificaVoto (uint256 candidateCode) public constant returns (uint256 votos) {
        return balanceOf(CodigoCandidato[candidateCode]);
    }
    
    function Votar(uint256 candidato) public returns (uint256 votos) {
        
        if (candidato == 0){
            votosNullos++;
            return 0;
        }
        
        votoEleitor[msg.sender].votoPresidente = true;
        votoEleitor[msg.sender].codPresidente = candidato; 
        
        address addrCandidato = CodigoCandidato[candidato];
        
        uint256 value = 1;
        
        //balances[msg.sender] = balances[msg.sender].sub(value);
        balances[addrCandidato] = balances[addrCandidato].add(value);
        
        return balanceOf(addrCandidato);
    }
    
    function GravarVotopresidente (uint256 candidato) public returns (bool success) {
        require(balances[msg.sender] <= 3 && balances[msg.sender] > 0);
        require(votoEleitor[msg.sender].votoPresidente == false);
        
        votoEleitor[msg.sender].votoPresidente = true;
        votoEleitor[msg.sender].codPresidente = candidato; 
        
        address addrCandidato = CodigoCandidato[candidato];
        
        uint256 value = 1;
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[addrCandidato] = balances[addrCandidato].add(value);
        
        return true;
    }
    
    
    function GravarVotoVereador (uint256 candidato)  public {
        require(balances[msg.sender] <= 3 && balances[msg.sender] > 0);
        require(votoEleitor[msg.sender].votoPresidente == false);
        
        votoEleitor[msg.sender].votoVereador = true;
        votoEleitor[msg.sender].codVereador = candidato; 
        
        address addrCandidato = CodigoCandidato[candidato];
        
        uint256 value = 1 * (10 ** decimals);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[addrCandidato] = balances[addrCandidato].add(value);
        
    }
    
    
    function GravarVotoDeputado (uint256 candidato) public {
        require(balances[msg.sender] <= 3 && balances[msg.sender] > 0);
        require(votoEleitor[msg.sender].votoPresidente == false);
        
        votoEleitor[msg.sender].votoDeputado = true;
        votoEleitor[msg.sender].codDeputado = candidato;
        
        address addrCandidato = CodigoCandidato[candidato];
        
        
        uint256 value = 1 * (10 ** decimals);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[addrCandidato] = balances[addrCandidato].add(value);
        
        
    }
}
