// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity >=0.7.0 <0.9.0;

contract Lottery is ReentrancyGuard {
    uint256 public constant ticketPrice = 0.01 ether;
    uint256 public constant maxTickets = 100; // máximo de boletos por lotería
    uint256 public ticketCommission = 0.001 ether; // comisión por boleto (dinámica)
    uint256 public constant duration = 30 minutes; // duración establecida para la lotería

    uint256 public expiration; // tiempo de expiración en caso de que la lotería no se lleve a cabo
    address public lotteryOperator; // creador de la lotería
    uint256 public operatorTotalCommission = 0; // saldo total de comisiones
    address public lastWinner; // último ganador de la lotería
    uint256 public lastWinnerAmount; // monto del último ganador de la lotería

    mapping(address => uint256) public winnings; // mapea a los ganadores con sus ganancias
    address[] public tickets; // array de boletos comprados
    address[] public winnersHistory; // historial de ganadores

    // Eventos para mejorar la transparencia
    event TicketsPurchased(address indexed buyer, uint256 numberOfTickets);
    event WinnerDrawn(address indexed winner, uint256 amount);
    event LotteryRestarted();
    event CommissionWithdrawn(address indexed operator, uint256 amount);

    // modificador para verificar si el llamador es el operador de la lotería
    modifier isOperator() {
        require(
            (msg.sender == lotteryOperator),
            "El llamador no es el operador de la lotería"
        );
        _;
    }

    // modificador para verificar si el llamador es un ganador
    modifier isWinner() {
        require(IsWinner(), "El llamador no es un ganador");
        _;
    }

    constructor() {
        lotteryOperator = msg.sender;
        expiration = block.timestamp + duration;
    }

    // devuelve todos los boletos
    function getTickets() public view returns (address[] memory) {
        return tickets;
    }

    // devuelve el historial de ganadores
    function getWinnersHistory() public view returns (address[] memory) {
        return winnersHistory;
    }

    function getWinningsForAddress(address addr) public view returns (uint256) {
        return winnings[addr];
    }

    function BuyTickets() public payable {
        require(msg.sender != lotteryOperator, "El operador no puede comprar boletos");
        require(
            msg.value % ticketPrice == 0,
            string.concat(
                "el valor debe ser múltiplo de ",
                Strings.toString(ticketPrice),
                " Ether"
            )
        );
        uint256 numOfTicketsToBuy = msg.value / ticketPrice;

        require(
            numOfTicketsToBuy <= RemainingTickets(),
            "No hay suficientes boletos disponibles."
        );

        for (uint256 i = 0; i < numOfTicketsToBuy; i++) {
            tickets.push(msg.sender);
        }

        // Emitir evento de compra de boletos
        emit TicketsPurchased(msg.sender, numOfTicketsToBuy);
    }

    function DrawWinnerTicket() public isOperator {
        require(tickets.length > 0, "No se compraron boletos");

        bytes32 blockHash = blockhash(block.number - tickets.length);
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, blockHash))
        );
        uint256 winningTicket = randomNumber % tickets.length;

        address winner = tickets[winningTicket];
        lastWinner = winner;
        winnings[winner] += (tickets.length * (ticketPrice - ticketCommission));
        lastWinnerAmount = winnings[winner];
        operatorTotalCommission += (tickets.length * ticketCommission);
        delete tickets;
        expiration = block.timestamp + duration;

        // Guardar al ganador en el historial
        winnersHistory.push(winner);

        // Emitir evento de ganador sorteado
        emit WinnerDrawn(winner, winnings[winner]);
    }

    function restartDraw() public isOperator {
        require(tickets.length == 0, "No se puede reiniciar el sorteo porque el sorteo está en curso");

        delete tickets;
        expiration = block.timestamp + duration;

        // Emitir evento de reinicio de la lotería
        emit LotteryRestarted();
    }

    function checkWinningsAmount() public view returns (uint256) {
        address payable winner = payable(msg.sender);

        uint256 reward2Transfer = winnings[winner];

        return reward2Transfer;
    }

    function WithdrawWinnings() public nonReentrant isWinner {
        address payable winner = payable(msg.sender);

        uint256 reward2Transfer = winnings[winner];
        winnings[winner] = 0;

        winner.transfer(reward2Transfer);
    }

    function RefundAll() public {
        require(block.timestamp >= expiration, "la lotería aún no ha expirado");

        for (uint256 i = 0; i < tickets.length; i++) {
            address payable to = payable(tickets[i]);
            tickets[i] = address(0);
            to.transfer(ticketPrice);
        }
        delete tickets;
    }

    function WithdrawCommission() public nonReentrant isOperator {
        require(block.timestamp >= expiration, "No se pueden retirar comisiones antes de que la lotería expire");

        address payable operator = payable(msg.sender);

        uint256 commission2Transfer = operatorTotalCommission;
        operatorTotalCommission = 0;

        operator.transfer(commission2Transfer);

        // Emitir evento de retiro de comisiones
        emit CommissionWithdrawn(operator, commission2Transfer);
    }

    function IsWinner() public view returns (bool) {
        return winnings[msg.sender] > 0;
    }

    function CurrentWinningReward() public view returns (uint256) {
        return tickets.length * ticketPrice;
    }

    function RemainingTickets() public view returns (uint256) {
        return maxTickets - tickets.length;
    }

    // Configurar comisión dinámica
    function setTicketCommission(uint256 _commission) public isOperator {
        require(_commission < ticketPrice, "La comisión no puede ser mayor que el precio del boleto");
        ticketCommission = _commission;
    }
}
