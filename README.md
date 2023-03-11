# nftMarketplace
nft marketplace with compiler and deployer
<br>
This is a nft marketplace contract that you can mint tokens by giving the token uri, and then you can set price for it and it gives you the option to buy and sell nfts with every ERC20 token that you want, if you want to sell your token with the chains native coin, don't fill the field of ERC20Address input of createToken function. If you want to use an ERC20 token as payment system(for example the ERC20 token that i created at the address of 0xBC93635A75deb824FFe89f6B99D90B9E565E73C3 on the mumbai testnet) just put the address of the contract in the ERC20Address field. <br> and for purchasing the item, you should first approve the contract from your ERC20 contract and then give the createMarketSale function, token id of the token that you want to purchase, and give the contract 0.00025 ether as fee.

<br>
lets not forget how this page helped me :)<br>
https://betterprogramming.pub/creating-an-nft-marketplace-solidity-2323abca6346
