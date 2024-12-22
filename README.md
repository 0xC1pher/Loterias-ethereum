# lottery-smart-contract

❗Fork con la idea de agregar mas funciones
**OR**

❗❗Deploy the CONTRACT DIRECTLY here: https://thirdweb.com/0x741179Acd84FeDEb7315a8ce4149f5cEF914185c/Lottery


--------

DISCLAIMER: This video is made for informational and educational purposes only. The content of this tutorial is not intended to be a lure to gambling. Instead, the information presented is meant for nothing more than learning and entertainment purposes. We are not liable for any losses that are incurred or problems that arise at online casinos or elsewhere after the reading and consideration of this tutorials content. If you are gambling online utilizing information from this tutorial, you are doing so completely and totally at your own risk.

---------

This repository was extended from its original smart contract repo: https://github.com/drord9/Lottery
# Loterias-ethrereum
### Nuevas características implementadas

#### Historial de ganadores:
- Se agregó un array `winnersHistory` para almacenar los ganadores anteriores.
- La función `getWinnersHistory` permite consultar el historial de ganadores.

#### Eventos para mejorar la transparencia:
- Se agregaron eventos como `TicketsPurchased`, `WinnerDrawn`, `LotteryRestarted` y `CommissionWithdrawn` para registrar acciones importantes.

#### Comisiones dinámicas:
- Se agregó la función `setTicketCommission` para permitir que el operador configure la comisión de manera dinámica.

#### Evitar que el operador sea ganador:
- Se agregó una validación en `BuyTickets` para evitar que el operador compre boletos.

#### Evitar retiro de comisiones antes de tiempo:
- Se agregó una validación en `WithdrawCommission` para asegurarse de que las comisiones solo se puedan retirar después de que la lotería haya expirado.
